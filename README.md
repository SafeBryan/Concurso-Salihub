# Reto SaliHub · DevFest Quito 2026

**¿Qué haría usted para que una persona abra SaliHub hoy y vuelva a abrirla mañana?**

Piense en alguien que no eligió instalar la app: se la pidió su empresa o se la recomendó alguien, y
nada le obliga a volver. Este repositorio es una demo de SaliHub para que no empiece de cero: un API y
una app móvil que ya funcionan. Su trabajo es mejorarla o agregarle lo que usted crea que hace volver a
la persona.

Premio: **hasta 2 pasantías pagadas** (3 meses).
Cierre: **lunes 28 de septiembre de 2026, 23:59 (hora de Ecuador).**

---

## Qué trae

| Parte     | Tecnología                                       | Qué hace                                                                                                              |
| --------- | ------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------- |
| `api/`    | Python · Django · Django REST Framework · SQLite | Check-in de la mañana, Readiness Index de 0 a 100, sesión del día ajustada al índice, registro de sesiones terminadas |
| `mobile/` | Flutter                                          | Inicio con el índice y la sesión del día, check-in, sesión guiada con temporizador, «¿Cómo le fue?» e historial       |

Hay **una sola persona de ejemplo** y no hay inicio de sesión. Al cargar los datos quedan dos semanas de
historial inventado, y el día de hoy queda libre para que usted haga el check-in.

### Cómo funciona

1. **Check-in de la mañana:** 6 preguntas (energía, cuerpo, horas y calidad de sueño, actividad y tiempo
   sentado de ayer). Uno por día.
2. **Readiness Index:** un número de 0 a 100 que dice cómo llega la persona hoy, con 5 niveles:
   Disposición óptima, Buena disposición, Disposición moderada, Fatiga / desbalance y Alerta.
3. **Sesión del día:** cada nivel tiene un esfuerzo máximo (escala de 0 a 10), y la app recomienda una
   sesión que no lo pase.
4. **Sesión guiada:** pasos con temporizador y, al final, «¿Cómo le fue?»: estrellas y esfuerzo percibido.

---

## Cómo participar

1. **Descargue SaliHub** (App Store o Google Play), cree su cuenta y haga su primer Readiness Index.
   Úsela: la demo se inspira en ella, y el reto es sobre la persona que la usa.
2. **Cree su copia de este repositorio** con el botón **«Use this template»** de GitHub. Déjela pública.
   Hágalo al empezar: revisamos su historial de commits desde el primero.
3. **Llene el formulario** de la competencia con su hoja de vida y el enlace de su repositorio.
4. **Trabaje en su copia y haga commits a medida que avanza.** No suba todo al final.
5. **Explique su decisión** en la sección «Mi propuesta» al final de este README.

### Dónde ponerse creativo

Puede tocar el API, la app o las dos. Algunas preguntas para arrancar. No son obligatorias, y la mejor
idea puede no estar aquí:

- La app no tiene rachas ni metas. ¿Algo así haría volver a alguien, o lo cansaría?
- ¿Qué le diría la app a alguien que lleva tres días sin abrirla?
- ¿Qué le gustaría ver al día siguiente de una sesión dura, o de una mala noche?
- ¿El check-in de 6 preguntas es demasiado largo para todos los días?
- ¿La recomendación explica por qué? ¿Debería hacerlo?
- La fórmula del índice es un promedio simple. ¿Cambiaría cómo se calcula o cómo se muestra?

Para probar «volver mañana», el botón de calendario de la app simula el día siguiente. En el API,
agregue `?fecha=AAAA-MM-DD` a cualquier ruta.

---

## Cómo correrlo

Necesita Python 3.11 o más reciente y Flutter 3.35 o más reciente.

### API

```bash
cd api
python3 -m venv .venv
source .venv/bin/activate          # En Windows: .venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py sembrar           # carga las sesiones y el historial de ejemplo
python manage.py runserver
```

El API queda en `http://localhost:8000/api/`. Pruebas: `python manage.py test demo`.

### App móvil

Con el API corriendo, en otra terminal:

```bash
cd mobile
flutter pub get
flutter run -d chrome                                               # en el navegador, lo más rápido
flutter run --dart-define=API_URL=http://10.0.2.2:8000              # emulador de Android
```

En el simulador de iOS, `localhost` funciona tal cual. En un teléfono físico, use la IP de su computadora
en la red (`--dart-define=API_URL=http://192.168.x.x:8000`) y corra el API con
`python manage.py runserver 0.0.0.0:8000`.

Revisión y pruebas: `flutter analyze` y `flutter test`.

### Rutas del API

| Método     | Ruta                                    | Qué hace                                                                                                               |
| ---------- | --------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| GET        | `/api/perfil/`                          | La persona de ejemplo                                                                                                  |
| GET        | `/api/checkin/preguntas/`               | Las 6 preguntas con sus opciones                                                                                       |
| POST       | `/api/checkin/`                         | Guarda el check-in de hoy. Cuerpo: `{"respuestas": {"energia": 3, ...}}`, con el número de la opción elegida (desde 0) |
| GET        | `/api/indice/hoy/`                      | El índice de hoy, o `hecho: false` si falta el check-in                                                                |
| GET        | `/api/indice/historial/?dias=14`        | El índice de los últimos días                                                                                          |
| GET        | `/api/entrenamiento/sesion-del-dia/`    | La sesión recomendada según el índice de hoy                                                                           |
| GET        | `/api/entrenamiento/sesiones/`          | Todas las sesiones                                                                                                     |
| GET        | `/api/entrenamiento/sesiones/<codigo>/` | Una sesión con sus pasos                                                                                               |
| GET / POST | `/api/entrenamiento/registros/`         | Sesiones terminadas. Cuerpo: `{"sesion": "movilidad-matutina", "valoracion": 1-5, "esfuerzo": 0-10, "comentario": ""}` |

El contenido fijo (preguntas, niveles y sesiones) está en `api/demo/catalogo.py`, y la fórmula del índice
en `api/demo/indice.py`.

---

## Qué evaluamos

| Qué miramos             | Qué quiere decir                                                           |
| ----------------------- | -------------------------------------------------------------------------- |
| Entendió al usuario     | Piensa en alguien que no eligió instalar la app, no en un usuario genérico |
| Funciona                | Lo que construyó corre. Importa que funcione, no que se vea bonito         |
| Cómo lo construyó       | El historial de commits: si avanzó con orden o subió todo el último día    |
| El código se puede leer | Nombres, estructura y un README que explique la decisión                   |

## Reglas

- La participación es individual.
- Use solo datos inventados. No suba datos personales reales, ni suyos ni de otras personas.
- Puede usar herramientas de IA. En la entrevista le pediremos que explique en vivo las decisiones de su
  código.
- Su código es suyo. SaliHub no lo publica ni lo usa sin su permiso escrito.
- Cuenta el último commit hasta el lunes 28 de septiembre a las 23:59 (hora de Ecuador).

## Fechas

| Hito                     | Fecha                                                       |
| ------------------------ | ----------------------------------------------------------- |
| Apertura                 | Sábado 26 de septiembre, en el stand de SaliHub del DevFest |
| Cierre                   | Lunes 28 de septiembre, 23:59 (hora de Ecuador)             |
| Revisión de repositorios | Martes 29 de septiembre a jueves 1 de octubre               |
| Entrevistas              | Semana del 5 de octubre                                     |
| Anuncio de ganadores     | Viernes 9 de octubre, por correo                            |

---

## Mi propuesta

### Qué problema vi al usar la app

Probé SaliHub pensando en la persona del reto: alguien que no eligió instalar la aplicación y que, por lo tanto, no tiene una motivación previa para volver cada mañana.

Encontré tres fricciones en el flujo diario. La primera fue descubrir cómo iniciar el Readiness: el acceso no era evidente para una primera experiencia. La segunda fue la repetición del check-in; pedir las mismas seis respuestas todos los días puede sentirse como otra tarea, especialmente cuando parte de esa información podría estar disponible desde el dispositivo. La tercera apareció después de responder: obtener un número es útil, pero por sí solo no crea una razón clara para regresar al día siguiente.

Por eso decidí no agregar gamificación, puntos o una racha únicamente para forzar recurrencia. Mi objetivo fue reducir la fricción y convertir el Readiness en un ciclo de retroalimentación diario.

### Hipótesis

Si SaliHub pregunta únicamente lo que todavía necesita saber, explica de forma transparente qué señales influyeron en el Readiness y al día siguiente muestra qué cambió respecto a ayer, la experiencia puede sentirse menos como una obligación y más como información personal que vale la pena consultar.

El ciclo propuesto es:

**entrar → responder solo lo necesario → entender el Readiness → realizar una acción → volver mañana → ver qué cambió**

### Qué construí y por qué creo que hace volver a la persona

#### 1. Check-in adaptativo

El flujo ya no depende de una cantidad fija de preguntas manuales. Antes de preguntar, la app separa las señales que ya están disponibles de las que todavía necesitan una respuesta de la persona.

En esta demo se simulan tres señales disponibles —horas de sueño, actividad del día anterior y sedentarismo— usando datos inventados. La persona puede revisarlas y corregirlas antes de continuar. Las demás señales se preguntan de forma progresiva.

El Readiness sigue utilizando las seis variables originales; el cambio está en **quién aporta cada dato**, no en eliminar información del cálculo. Si una señal dejara de estar disponible, el check-in la vuelve a preguntar automáticamente.

> La demo no lee Health Connect, Apple Health ni un wearable real. Las señales preparadas son ficticias y representan el punto de integración que, en producción, podría alimentarse con la capa de datos de salud/dispositivo disponible en SaliHub.

#### 2. Readiness explicable

Después del check-in no se muestra solamente el índice. El API descompone el resultado por señal y la app presenta las tres de menor aporte al promedio, asociadas a los componentes BSI, SI y AI.

En lugar de inventar etiquetas clínicas como “riesgo” o “alerta”, se muestra el aporte numérico de cada señal sobre 100 y la respuesta que lo produjo. La intención es responder una pregunta sencilla: **“¿por qué hoy obtuve este Readiness?”**

La fórmula original de la demo se mantiene: un promedio simple. El prototipo mejora la explicación del resultado, no pretende convertirlo en un diagnóstico.

#### 3. Contexto de ayer y comparación con hoy

Al simular el día siguiente, la pantalla recuerda el Readiness del día anterior y, si existe, la sesión que la persona completó. Después del nuevo check-in se muestra la diferencia entre ambos índices.

Por ejemplo:

```text
AYER        HOY
 58    →     67
          +9
```

La app no afirma que una sesión, una noche de sueño o una acción específica **causó** ese cambio. Solo conecta temporalmente lo que ocurrió ayer con el estado de hoy. Esto permite observar evolución sin presentar correlación como causalidad.

### Por qué creo que esto hace volver a la persona

La propuesta intenta que la recurrencia nazca de una pregunta abierta: **“¿cómo cambié desde ayer?”**

El primer día la persona obtiene valor con menos esfuerzo, entiende mejor su resultado y recibe una recomendación. El segundo día SaliHub ya tiene contexto: puede mostrarle de dónde viene y qué cambió. Así, cada check-in deja información útil para el siguiente en lugar de ser un formulario aislado que vuelve a empezar desde cero.

### Qué cambié en el API y qué en la app

| Parte | Cambio |
|---|---|
| API | Expone el aporte de cada señal al Readiness para poder explicar el resultado. |
| API | Devuelve contexto del día anterior, incluyendo su Readiness y una sesión completada cuando existe. |
| API | Añade pruebas para los factores del índice y el contexto entre días. |
| Flutter | Implementa un check-in adaptativo que pregunta únicamente las señales faltantes. |
| Flutter | Muestra y permite revisar las señales simuladas que ya están disponibles. |
| Flutter | Explica las señales de menor aporte utilizando BSI, SI y AI como contexto. |
| Flutter | Muestra el estado del día anterior antes del nuevo check-in y compara ayer contra hoy después de responder. |
| Flutter | Añade pruebas del comportamiento adaptativo del check-in. |

### Cómo probar mi propuesta en 2 minutos

Para empezar desde un estado conocido, cargue nuevamente los datos ficticios de la demo:

```bash
cd api
python manage.py sembrar
python manage.py runserver
```

En otra terminal inicie la app:

```bash
cd mobile
flutter pub get
flutter run -d chrome
```

Luego siga este recorrido:

1. En Inicio, pulse **Hacer check-in express**.
2. Observe las señales que la demo ya tiene preparadas, entre a **Revisar** si desea comprobar que pueden corregirse y continúe.
3. Responda únicamente las preguntas pendientes y finalice el check-in.
4. En Inicio, revise el Readiness y la sección **¿Qué influyó hoy?**.
5. Abra la sesión recomendada, iníciela y use **Saltar** para avanzar rápidamente por los pasos. Registre la valoración y el esfuerzo al terminar.
6. Desde el calendario, seleccione **Simular mañana**. Antes del nuevo check-in verá el contexto de ayer.
7. Complete el check-in del nuevo día con respuestas distintas y observe la comparación **AYER → HOY**.

Ese recorrido concentra la propuesta completa: **menos fricción hoy, más contexto mañana**.

### Decisiones y límites del prototipo

- Todos los datos utilizados son ficticios.
- Las señales preparadas no provienen de un dispositivo real; simulan disponibilidad de datos para demostrar el comportamiento adaptativo.
- Se conserva la fórmula de Readiness entregada con la demo.
- Los aportes de las señales se muestran para explicar el promedio, no como diagnóstico médico.
- La comparación entre días muestra evolución y contexto, pero no atribuye causalidad.

### Qué haría con más tiempo

Con más tiempo reemplazaría las señales simuladas por disponibilidad real de la capa de integración de salud/dispositivo, manteniendo el mismo fallback: **si SaliHub conoce el dato, no lo pregunta; si falta, lo solicita**.

También probaría el flujo con usuarios reales para medir tiempo de check-in, abandono y retorno al día siguiente; añadiría una experiencia específica para quien vuelve después de varios días sin abrir la app; y estudiaría explicaciones personalizadas basadas en el historial individual, manteniendo separados los datos informativos de cualquier interpretación clínica.
