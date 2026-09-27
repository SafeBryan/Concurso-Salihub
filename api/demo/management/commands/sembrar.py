"""Carga las sesiones y dos semanas de check-ins y sesiones terminadas, todo inventado.

    python manage.py sembrar           # carga todo (borra lo anterior)
    python manage.py sembrar --vacio   # solo las sesiones, sin historial
"""

import datetime
import random

from django.core.management.base import BaseCommand
from django.db import transaction
from django.utils import timezone

from demo import indice as calculo
from demo.catalogo import PREGUNTAS, SESIONES
from demo.models import CheckIn, Paso, Registro, Sesion


class Command(BaseCommand):
    help = "Carga los datos de ejemplo de la demo."

    def add_arguments(self, parser):
        parser.add_argument("--vacio", action="store_true", help="Solo sesiones, sin historial.")
        parser.add_argument("--dias", type=int, default=14)

    @transaction.atomic
    def handle(self, *args, vacio=False, dias=14, **options):
        Registro.objects.all().delete()
        CheckIn.objects.all().delete()
        Sesion.objects.all().delete()

        for datos in SESIONES:
            datos = dict(datos)
            pasos = datos.pop("pasos")
            sesion = Sesion.objects.create(**datos)
            Paso.objects.bulk_create(
                Paso(sesion=sesion, orden=i, contenido=texto, duracion_segundos=segundos)
                for i, (texto, segundos) in enumerate(pasos, start=1)
            )

        if vacio:
            self.stdout.write(self.style.SUCCESS(f"{len(SESIONES)} sesiones cargadas, sin historial."))
            return

        # Historial hasta ayer: hoy queda libre para que usted haga el check-in.
        azar = random.Random(26)
        hoy = timezone.localdate()
        checkins = registros = 0
        for atras in range(dias, 0, -1):
            fecha = hoy - datetime.timedelta(days=atras)
            if azar.random() < 0.2:  # algunos días la persona no abrió la app
                continue
            respuestas = {p["clave"]: azar.randint(1, len(p["opciones"]) - 1) for p in PREGUNTAS}
            valor = calculo.calcular(respuestas)
            nivel = calculo.nivel_de(valor)
            CheckIn.objects.create(fecha=fecha, respuestas=respuestas, indice=valor, nivel=nivel["clave"])
            checkins += 1
            if azar.random() < 0.6:
                sesion = Sesion.objects.filter(rpe_maximo__lte=nivel["rpe_maximo"]).order_by("?").first()
                if sesion:
                    Registro.objects.create(
                        sesion=sesion,
                        fecha=fecha,
                        valoracion=azar.randint(3, 5),
                        esfuerzo=azar.randint(sesion.rpe_min, sesion.rpe_maximo),
                    )
                    registros += 1

        self.stdout.write(
            self.style.SUCCESS(f"{len(SESIONES)} sesiones, {checkins} check-ins y {registros} sesiones terminadas.")
        )
