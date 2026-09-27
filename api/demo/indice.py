"""Cálculo del índice de disposición de la demo.

⚠️ Es una fórmula de juguete: el promedio simple de las respuestas. No es la fórmula de SaliHub.
Si su idea necesita otra forma de calcularlo, cámbiela.
"""

from .catalogo import NIVELES, PREGUNTAS, PREGUNTAS_POR_CLAVE


class RespuestasInvalidas(ValueError):
    pass


def validar(respuestas):
    """Revisa que vengan todas las preguntas y que cada respuesta sea una opción válida (su índice)."""
    if not isinstance(respuestas, dict):
        raise RespuestasInvalidas("Las respuestas tienen que ser un objeto {clave: opción}.")
    faltan = [p["clave"] for p in PREGUNTAS if p["clave"] not in respuestas]
    if faltan:
        raise RespuestasInvalidas(f"Faltan respuestas: {', '.join(faltan)}.")
    for clave, valor in respuestas.items():
        pregunta = PREGUNTAS_POR_CLAVE.get(clave)
        if pregunta is None:
            raise RespuestasInvalidas(f"No existe la pregunta «{clave}».")
        if not isinstance(valor, int) or isinstance(valor, bool) or not 0 <= valor < len(pregunta["opciones"]):
            raise RespuestasInvalidas(f"La respuesta de «{clave}» tiene que ser un número de 0 a {len(pregunta['opciones']) - 1}.")


def calcular(respuestas):
    """Devuelve el índice de 0 a 100."""
    validar(respuestas)
    puntajes = [PREGUNTAS_POR_CLAVE[clave]["puntajes"][valor] for clave, valor in respuestas.items()]
    return round(sum(puntajes) / len(puntajes) * 100)


def _estado_factor(puntaje):
    if puntaje >= 80:
        return "Favorable"
    if puntaje >= 50:
        return "Intermedia"
    return "A revisar"


def factores_de(respuestas):
    """Explica las señales del índice sin atribuir causalidad entre ellas."""
    validar(respuestas)
    factores = []
    for pregunta in PREGUNTAS:
        valor = respuestas[pregunta["clave"]]
        puntaje = round(pregunta["puntajes"][valor] * 100)
        factores.append(
            {
                "clave": pregunta["clave"],
                "nombre": pregunta["nombre"],
                "respuesta": pregunta["opciones"][valor],
                "puntaje": puntaje,
                "estado": _estado_factor(puntaje),
            }
        )
    return sorted(factores, key=lambda factor: factor["puntaje"])


def nivel_de(indice):
    for nivel in NIVELES:
        if indice >= nivel["desde"]:
            return nivel
    return NIVELES[-1]


def nivel_por_clave(clave):
    return next(n for n in NIVELES if n["clave"] == clave)
