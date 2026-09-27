from django.core.management import call_command
from rest_framework.test import APITestCase

from . import indice
from .catalogo import PREGUNTAS

BUENAS = {"energia": 4, "estado_corporal": 4, "horas_sueno": 3, "calidad_sueno": 4, "actividad_ayer": 3, "sedentarismo": 3}
MALAS = {"energia": 0, "estado_corporal": 0, "horas_sueno": 0, "calidad_sueno": 0, "actividad_ayer": 0, "sedentarismo": 0}


class IndiceTests(APITestCase):
    def test_mejores_respuestas_dan_100(self):
        self.assertEqual(indice.calcular(BUENAS), 100)
        self.assertEqual(indice.nivel_de(100)["clave"], "optima")

    def test_peores_respuestas_dan_alerta(self):
        self.assertEqual(indice.nivel_de(indice.calcular(MALAS))["clave"], "alerta")

    def test_falta_una_respuesta(self):
        with self.assertRaises(indice.RespuestasInvalidas):
            indice.calcular({"energia": 2})

    def test_factores_ordenan_las_senales_mas_bajas(self):
        respuestas = {**BUENAS, "energia": 0, "calidad_sueno": 1}
        factores = indice.factores_de(respuestas)

        self.assertEqual(len(factores), len(PREGUNTAS))
        self.assertEqual(factores[0]["clave"], "energia")
        self.assertEqual(factores[0]["respuesta"], "Muy baja")
        self.assertEqual(factores[0]["puntaje"], 0)
        self.assertEqual(factores[0]["componente"]["codigo"], "BSI")
        self.assertNotIn("estado", factores[0])
        self.assertLessEqual(factores[0]["puntaje"], factores[-1]["puntaje"])


class ApiTests(APITestCase):
    def setUp(self):
        call_command("sembrar", vacio=True, verbosity=0)

    def test_preguntas(self):
        r = self.client.get("/api/checkin/preguntas/")
        self.assertEqual(len(r.json()), len(PREGUNTAS))

    def test_sin_checkin_no_hay_sesion(self):
        self.assertIsNone(self.client.get("/api/entrenamiento/sesion-del-dia/").json()["sesion"])

    def test_checkin_una_vez_por_dia(self):
        r = self.client.post("/api/checkin/", {"respuestas": BUENAS}, format="json")
        self.assertEqual(r.status_code, 201)
        self.assertEqual(r.json()["indice"], 100)
        self.assertEqual(len(r.json()["factores"]), len(PREGUNTAS))
        r = self.client.post("/api/checkin/", {"respuestas": BUENAS}, format="json")
        self.assertEqual(r.status_code, 409)
        r = self.client.post("/api/checkin/?fecha=2030-01-02", {"respuestas": BUENAS}, format="json")
        self.assertEqual(r.status_code, 201)

    def test_indice_incluye_contexto_del_dia_anterior(self):
        self.client.post("/api/checkin/?fecha=2030-01-01", {"respuestas": BUENAS}, format="json")
        self.client.post(
            "/api/entrenamiento/registros/?fecha=2030-01-01",
            {"sesion": "movilidad-matutina", "valoracion": 5, "esfuerzo": 3},
            format="json",
        )

        respuesta = self.client.get("/api/indice/hoy/?fecha=2030-01-02").json()

        self.assertFalse(respuesta["hecho"])
        self.assertEqual(respuesta["anterior"]["indice"], 100)
        self.assertEqual(respuesta["anterior"]["sesion_completada"]["titulo"], "Movilidad matutina")
        self.assertEqual(respuesta["anterior"]["sesion_completada"]["esfuerzo"], 3)

    def test_dia_malo_recomienda_recuperacion(self):
        self.client.post("/api/checkin/", {"respuestas": MALAS}, format="json")
        sesion = self.client.get("/api/entrenamiento/sesion-del-dia/").json()["sesion"]
        self.assertLessEqual(sesion["rpe_maximo"], 2)

    def test_registrar_sesion(self):
        r = self.client.post(
            "/api/entrenamiento/registros/",
            {"sesion": "movilidad-matutina", "valoracion": 5, "esfuerzo": 3},
            format="json",
        )
        self.assertEqual(r.status_code, 201)
        self.assertEqual(len(self.client.get("/api/entrenamiento/registros/").json()), 1)

    def test_registro_invalido(self):
        r = self.client.post(
            "/api/entrenamiento/registros/", {"sesion": "movilidad-matutina", "valoracion": 9, "esfuerzo": 3}, format="json"
        )
        self.assertEqual(r.status_code, 400)
