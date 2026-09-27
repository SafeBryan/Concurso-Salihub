"""Rutas del API de demo.

No hay usuarios ni inicio de sesión: toda la demo es de una sola persona de ejemplo.
Para simular otro día, agregue `?fecha=AAAA-MM-DD` a cualquier ruta.
"""

import datetime

from django.shortcuts import get_object_or_404
from django.utils import timezone
from rest_framework import serializers, status
from rest_framework.decorators import api_view
from rest_framework.response import Response

from . import indice as calculo
from .catalogo import AVISO, PREGUNTAS
from .models import CheckIn, Registro, Sesion

PERSONA = {"nombre": "Persona demo", "enfoque": "Bienestar general"}


def hoy(request):
    texto = request.query_params.get("fecha")
    if texto:
        try:
            return datetime.date.fromisoformat(texto)
        except ValueError:
            pass
    return timezone.localdate()


def nivel_publico(clave):
    nivel = calculo.nivel_por_clave(clave)
    return {k: nivel[k] for k in ("clave", "nombre", "color", "recomendacion", "rpe_maximo")}


def checkin_publico(checkin):
    return {
        "fecha": checkin.fecha,
        "indice": checkin.indice,
        "nivel": nivel_publico(checkin.nivel),
        "respuestas": checkin.respuestas,
    }


class PasoSerializer(serializers.Serializer):
    orden = serializers.IntegerField()
    contenido = serializers.CharField()
    duracion_segundos = serializers.IntegerField()


class SesionSerializer(serializers.ModelSerializer):
    pasos = PasoSerializer(many=True, read_only=True)

    class Meta:
        model = Sesion
        exclude = ["id"]


class SesionResumenSerializer(serializers.ModelSerializer):
    class Meta:
        model = Sesion
        fields = ["codigo", "titulo", "categoria", "duracion_min", "duracion_max", "intensidad", "rpe_min", "rpe_maximo"]


class RegistroSerializer(serializers.ModelSerializer):
    sesion = serializers.SlugRelatedField(slug_field="codigo", queryset=Sesion.objects.all())
    titulo = serializers.CharField(source="sesion.titulo", read_only=True)

    class Meta:
        model = Registro
        fields = ["id", "sesion", "titulo", "fecha", "valoracion", "esfuerzo", "comentario"]
        read_only_fields = ["id", "fecha"]


@api_view(["GET"])
def perfil(request):
    return Response(PERSONA)


@api_view(["GET"])
def preguntas(request):
    return Response([{k: p[k] for k in ("clave", "texto", "opciones")} for p in PREGUNTAS])


@api_view(["POST"])
def checkin(request):
    fecha = hoy(request)
    if CheckIn.objects.filter(fecha=fecha).exists():
        return Response(
            {"detalle": "Ya hizo su check-in de hoy. Podrá hacer uno nuevo mañana."},
            status=status.HTTP_409_CONFLICT,
        )
    respuestas = request.data.get("respuestas")
    try:
        valor = calculo.calcular(respuestas)
    except calculo.RespuestasInvalidas as error:
        return Response({"detalle": str(error)}, status=status.HTTP_400_BAD_REQUEST)
    nuevo = CheckIn.objects.create(
        fecha=fecha, respuestas=respuestas, indice=valor, nivel=calculo.nivel_de(valor)["clave"]
    )
    return Response(checkin_publico(nuevo), status=status.HTTP_201_CREATED)


@api_view(["GET"])
def indice_hoy(request):
    fecha = hoy(request)
    del_dia = CheckIn.objects.filter(fecha=fecha).first()
    if del_dia is None:
        return Response({"fecha": fecha, "hecho": False, "aviso": AVISO})
    return Response({"hecho": True, "aviso": AVISO, **checkin_publico(del_dia)})


@api_view(["GET"])
def indice_historial(request):
    try:
        dias = max(1, min(int(request.query_params.get("dias", 14)), 90))
    except ValueError:
        dias = 14
    desde = hoy(request) - datetime.timedelta(days=dias - 1)
    filas = CheckIn.objects.filter(fecha__gte=desde, fecha__lte=hoy(request)).order_by("fecha")
    return Response([{"fecha": c.fecha, "indice": c.indice, "nivel": c.nivel} for c in filas])


@api_view(["GET"])
def sesion_del_dia(request):
    fecha = hoy(request)
    del_dia = CheckIn.objects.filter(fecha=fecha).first()
    if del_dia is None:
        return Response({"sesion": None, "motivo": "Haga su check-in para que le recomendemos una sesión."})

    nivel = calculo.nivel_por_clave(del_dia.nivel)
    permitidas = list(Sesion.objects.filter(rpe_maximo__lte=nivel["rpe_maximo"]).order_by("-rpe_maximo", "codigo"))
    if not permitidas:
        permitidas = list(Sesion.objects.order_by("rpe_maximo", "codigo")[:1])
    if not permitidas:
        return Response({"sesion": None, "motivo": "No hay sesiones cargadas. Corra `python manage.py sembrar`."})

    # Entre las dos sesiones más exigentes que el día permite, alterna según la fecha.
    candidatas = permitidas[:2]
    elegida = candidatas[fecha.toordinal() % len(candidatas)]
    return Response(
        {
            "sesion": SesionSerializer(elegida).data,
            "nivel": nivel_publico(del_dia.nivel),
            "mensaje": f"Ajustamos su sesión: {nivel['recomendacion']}",
            "terminada_hoy": Registro.objects.filter(fecha=fecha, sesion=elegida).exists(),
        }
    )


@api_view(["GET"])
def sesiones(request):
    return Response(SesionResumenSerializer(Sesion.objects.all(), many=True).data)


@api_view(["GET"])
def sesion_detalle(request, codigo):
    return Response(SesionSerializer(get_object_or_404(Sesion, codigo=codigo)).data)


@api_view(["GET", "POST"])
def registros(request):
    if request.method == "GET":
        return Response(RegistroSerializer(Registro.objects.select_related("sesion")[:50], many=True).data)
    datos = RegistroSerializer(data=request.data)
    datos.is_valid(raise_exception=True)
    datos.save(fecha=hoy(request))
    return Response(datos.data, status=status.HTTP_201_CREATED)
