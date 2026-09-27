import 'package:flutter_test/flutter_test.dart';
import 'package:salihub_reto/api.dart';
import 'package:salihub_reto/checkin_express.dart';

void main() {
  test('convierte el color del nivel', () {
    expect(colorDesdeHex('#3B82F6'), 0xFF3B82F6);
  });

  test('el reloj de la demo empieza en hoy', () {
    expect(Api.instancia.diasAdelante.value, 0);
  });

  test('el check-in express mantiene tres señales manuales', () {
    expect(
      clavesPreguntasManuales,
      containsAll(<String>['energia', 'estado_corporal', 'calidad_sueno']),
    );
    expect(clavesPreguntasManuales.length, 3);
  });

  test('el prototipo precarga tres señales simuladas del dispositivo', () {
    expect(
      respuestasDispositivoDemo.keys,
      containsAll(<String>['horas_sueno', 'actividad_ayer', 'sedentarismo']),
    );
    expect(respuestasDispositivoDemo.length, 3);
  });
}
