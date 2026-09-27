/// Configuración del prototipo de check-in express.
///
/// La demo no está conectada a Health Connect, Samsung Health ni Apple Health.
/// Estas respuestas representan señales que, en una integración real, podrían
/// llegar desde el dispositivo y que el usuario siempre puede revisar.
const Map<String, int> respuestasDispositivoDemo = {
  'horas_sueno': 3,
  'actividad_ayer': 3,
  'sedentarismo': 2,
};

/// Devuelve solo las preguntas cuyo dato todavía no está disponible.
///
/// Así el flujo no depende de una lista fija de preguntas manuales: si mañana
/// aparece o desaparece una señal del dispositivo, el check-in se adapta.
List<Map<String, dynamic>> preguntasPendientes(
  List<Map<String, dynamic>> preguntas, {
  Map<String, int> disponibles = respuestasDispositivoDemo,
}) {
  return preguntas
      .where((pregunta) => !disponibles.containsKey(pregunta['clave'] as String))
      .toList();
}
