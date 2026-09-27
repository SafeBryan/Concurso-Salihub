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

/// Señales que siguen necesitando una respuesta consciente de la persona.
const Set<String> clavesPreguntasManuales = {
  'energia',
  'estado_corporal',
  'calidad_sueno',
};

bool esPreguntaManual(String clave) => clavesPreguntasManuales.contains(clave);

List<Map<String, dynamic>> preguntasManuales(List<Map<String, dynamic>> preguntas) {
  return preguntas.where((pregunta) => esPreguntaManual(pregunta['clave'] as String)).toList();
}
