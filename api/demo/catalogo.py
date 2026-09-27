"""Contenido fijo de la demo: preguntas del check-in, niveles del índice y sesiones.

Todo está escrito para esta demo. Las sesiones son ejercicios genéricos, no el catálogo de SaliHub.
"""

# --- Check-in matutino --------------------------------------------------------------------------
# Cada pregunta tiene sus opciones ordenadas de peor a mejor, salvo las horas de sueño,
# donde lo mejor está en el medio (7-9 h). El puntaje de cada opción va de 0 a 1.

PREGUNTAS = [
    {
        "clave": "energia",
        "texto": "¿Cómo está su energía esta mañana?",
        "opciones": ["Muy baja", "Baja", "Normal", "Buena", "Muy buena"],
        "puntajes": [0.0, 0.25, 0.5, 0.75, 1.0],
    },
    {
        "clave": "estado_corporal",
        "texto": "¿Cómo siente el cuerpo?",
        "opciones": ["Muy tenso", "Tenso", "Normal", "Relajado", "Muy relajado"],
        "puntajes": [0.0, 0.25, 0.5, 0.75, 1.0],
    },
    {
        "clave": "horas_sueno",
        "texto": "¿Cuántas horas durmió?",
        "opciones": ["Menos de 5h", "5-6h", "6-7h", "7-9h", "Más de 9h"],
        "puntajes": [0.0, 0.35, 0.7, 1.0, 0.8],
    },
    {
        "clave": "calidad_sueno",
        "texto": "¿Cómo durmió?",
        "opciones": ["Muy mal", "Mal", "Regular", "Bien", "Muy bien"],
        "puntajes": [0.0, 0.25, 0.5, 0.75, 1.0],
    },
    {
        "clave": "actividad_ayer",
        "texto": "¿Qué tan activo estuvo ayer?",
        "opciones": ["Muy poco", "Poco", "Normal", "Activo", "Muy activo"],
        "puntajes": [0.2, 0.4, 0.7, 1.0, 0.8],
    },
    {
        "clave": "sedentarismo",
        "texto": "Ayer, ¿cuánto tiempo pasó sentado?",
        "opciones": ["Casi todo el día", "Varias horas", "Con pausas", "Poco"],
        "puntajes": [0.0, 0.35, 0.75, 1.0],
    },
]

PREGUNTAS_POR_CLAVE = {p["clave"]: p for p in PREGUNTAS}

# --- Niveles del índice -------------------------------------------------------------------------
# De mayor a menor. `desde` es el puntaje mínimo (0-100) para caer en el nivel.
# `rpe_maximo` es el esfuerzo más alto (escala 0-10) que la demo recomienda ese día.

NIVELES = [
    {
        "clave": "optima",
        "nombre": "Disposición óptima",
        "desde": 80,
        "color": "#3B82F6",
        "rpe_maximo": 9,
        "recomendacion": "Buen día para exigirse. Aproveche la energía, sin saltarse el calentamiento.",
    },
    {
        "clave": "buena",
        "nombre": "Buena disposición",
        "desde": 65,
        "color": "#22C55E",
        "rpe_maximo": 8,
        "recomendacion": "Puede entrenar con normalidad.",
    },
    {
        "clave": "moderada",
        "nombre": "Disposición moderada",
        "desde": 50,
        "color": "#6B7280",
        "rpe_maximo": 6,
        "recomendacion": "Entrene, pero baje un poco la intensidad.",
    },
    {
        "clave": "fatiga",
        "nombre": "Fatiga / desbalance",
        "desde": 35,
        "color": "#F59E0B",
        "rpe_maximo": 4,
        "recomendacion": "Hoy conviene algo suave: movilidad o una caminata.",
    },
    {
        "clave": "alerta",
        "nombre": "Alerta",
        "desde": 0,
        "color": "#EF4444",
        "rpe_maximo": 2,
        "recomendacion": "Priorice la recuperación. Si se siente mal, consulte a un profesional.",
    },
]

AVISO = "Este índice es orientativo y no reemplaza la opinión de un profesional de la salud."

# --- Sesiones de entrenamiento ------------------------------------------------------------------
# Cada paso tiene un texto y una duración en segundos. La dosis va dentro del texto.

SESIONES = [
    {
        "codigo": "respiracion-recuperacion",
        "titulo": "Respiración y recuperación",
        "categoria": "Recuperación",
        "objetivo": "Bajar el estrés y soltar el cuerpo.",
        "duracion_min": 8,
        "duracion_max": 10,
        "intensidad": "Muy suave",
        "rpe_min": 1,
        "rpe_maximo": 2,
        "equipo": "Ninguno",
        "mensaje": "Hoy el objetivo es recuperarse. Vaya despacio.",
        "pasos": [
            ("Siéntese cómodo y respire por la nariz: 4 segundos inhalar, 6 exhalar", 120),
            ("Rotaciones suaves de cuello, 5 por lado", 60),
            ("Círculos de hombros hacia atrás, 10 repeticiones", 45),
            ("Estiramiento de espalda sentado, brazos al frente", 60),
            ("Respiración en caja: 4-4-4-4", 120),
        ],
    },
    {
        "codigo": "movilidad-matutina",
        "titulo": "Movilidad matutina",
        "categoria": "Movilidad",
        "objetivo": "Despertar las articulaciones antes del día.",
        "duracion_min": 10,
        "duracion_max": 12,
        "intensidad": "Suave",
        "rpe_min": 2,
        "rpe_maximo": 3,
        "equipo": "Ninguno",
        "mensaje": "Movimientos amplios y sin dolor.",
        "pasos": [
            ("Gato-camello en cuatro apoyos, 10 repeticiones", 60),
            ("Rotación de cadera de pie, 8 por lado", 60),
            ("Estocada con giro de tronco, 6 por lado", 90),
            ("Sentadilla profunda sostenida", 45),
            ("Estiramiento de pantorrillas en la pared", 60),
            ("Apertura de pecho en el marco de la puerta", 60),
        ],
    },
    {
        "codigo": "caminata-activa",
        "titulo": "Caminata activa",
        "categoria": "Cardio",
        "objetivo": "Moverse sin cansarse de más.",
        "duracion_min": 20,
        "duracion_max": 25,
        "intensidad": "Suave",
        "rpe_min": 3,
        "rpe_maximo": 4,
        "equipo": "Zapatos cómodos",
        "mensaje": "Debería poder conversar mientras camina.",
        "pasos": [
            ("Camine a ritmo tranquilo", 300),
            ("Suba el ritmo: paso rápido", 600),
            ("Vuelva al ritmo tranquilo", 300),
            ("Estire piernas de pie", 120),
        ],
    },
    {
        "codigo": "activacion-10",
        "titulo": "Activación de 10 minutos",
        "categoria": "Activación",
        "objetivo": "Subir la energía en poco tiempo.",
        "duracion_min": 10,
        "duracion_max": 10,
        "intensidad": "Moderada",
        "rpe_min": 4,
        "rpe_maximo": 5,
        "equipo": "Ninguno",
        "mensaje": "Corto y constante.",
        "pasos": [
            ("Trote en el sitio", 60),
            ("Sentadillas al aire, 12 repeticiones", 45),
            ("Plancha con apoyo de rodillas", 30),
            ("Saltos de tijera suaves, 20 repeticiones", 45),
            ("Puente de glúteo, 12 repeticiones", 45),
            ("Repita la vuelta una vez más", 225),
        ],
    },
    {
        "codigo": "fuerza-basica",
        "titulo": "Fuerza básica en casa",
        "categoria": "Fuerza",
        "objetivo": "Trabajar todo el cuerpo con su propio peso.",
        "duracion_min": 25,
        "duracion_max": 30,
        "intensidad": "Moderada",
        "rpe_min": 5,
        "rpe_maximo": 6,
        "equipo": "Una silla",
        "mensaje": "Controle la bajada en cada repetición.",
        "pasos": [
            ("Calentamiento: movilidad general", 240),
            ("Sentadilla a la silla, 3 series de 12", 300),
            ("Flexiones con manos en la silla, 3 series de 10", 300),
            ("Zancada hacia atrás, 3 series de 8 por pierna", 300),
            ("Plancha, 3 series de 30 segundos", 240),
            ("Vuelta a la calma y estiramientos", 180),
        ],
    },
    {
        "codigo": "circuito-completo",
        "titulo": "Circuito completo",
        "categoria": "Circuito",
        "objetivo": "Fuerza y resistencia en la misma sesión.",
        "duracion_min": 25,
        "duracion_max": 30,
        "intensidad": "Alta",
        "rpe_min": 6,
        "rpe_maximo": 8,
        "equipo": "Ninguno",
        "mensaje": "40 segundos de trabajo y 20 de descanso.",
        "pasos": [
            ("Calentamiento dinámico", 300),
            ("Sentadilla con salto", 60),
            ("Flexiones", 60),
            ("Escaladores", 60),
            ("Zancadas alternas", 60),
            ("Descanso y repita 3 vueltas en total", 720),
            ("Vuelta a la calma", 180),
        ],
    },
    {
        "codigo": "intervalos-cardio",
        "titulo": "Intervalos de cardio",
        "categoria": "Cardio",
        "objetivo": "Mejorar la capacidad aeróbica.",
        "duracion_min": 20,
        "duracion_max": 25,
        "intensidad": "Alta",
        "rpe_min": 7,
        "rpe_maximo": 9,
        "equipo": "Bicicleta, cuerda o espacio para trotar",
        "mensaje": "Los intervalos fuertes son de verdad fuertes. Los suaves, de verdad suaves.",
        "pasos": [
            ("Calentamiento progresivo", 360),
            ("1 minuto fuerte, 1 minuto suave: 6 veces", 720),
            ("Vuelta a la calma", 240),
            ("Estiramientos", 120),
        ],
    },
]
