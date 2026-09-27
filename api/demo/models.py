from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models


class Sesion(models.Model):
    """Una sesión de entrenamiento. Se carga desde `catalogo.SESIONES` con `manage.py sembrar`."""

    codigo = models.SlugField(unique=True)
    titulo = models.CharField(max_length=120)
    categoria = models.CharField(max_length=40)
    objetivo = models.CharField(max_length=200)
    duracion_min = models.PositiveSmallIntegerField()
    duracion_max = models.PositiveSmallIntegerField()
    intensidad = models.CharField(max_length=40)
    rpe_min = models.PositiveSmallIntegerField()
    rpe_maximo = models.PositiveSmallIntegerField()
    equipo = models.CharField(max_length=120)
    mensaje = models.CharField(max_length=200)

    class Meta:
        ordering = ["rpe_maximo", "codigo"]

    def __str__(self):
        return self.titulo


class Paso(models.Model):
    sesion = models.ForeignKey(Sesion, related_name="pasos", on_delete=models.CASCADE)
    orden = models.PositiveSmallIntegerField()
    contenido = models.CharField(max_length=200)
    duracion_segundos = models.PositiveIntegerField()

    class Meta:
        ordering = ["orden"]


class CheckIn(models.Model):
    """El check-in de una mañana. Hay uno por día como máximo."""

    fecha = models.DateField(unique=True)
    respuestas = models.JSONField()
    indice = models.PositiveSmallIntegerField()
    nivel = models.CharField(max_length=20)
    creado = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-fecha"]


class Registro(models.Model):
    """Una sesión terminada, con lo que la persona contestó en «¿Cómo le fue?»."""

    sesion = models.ForeignKey(Sesion, on_delete=models.PROTECT)
    fecha = models.DateField()
    valoracion = models.PositiveSmallIntegerField(validators=[MinValueValidator(1), MaxValueValidator(5)])
    esfuerzo = models.PositiveSmallIntegerField(validators=[MaxValueValidator(10)])
    comentario = models.CharField(max_length=500, blank=True)
    creado = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-fecha", "-creado"]
