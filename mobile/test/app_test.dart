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

  test('el check-in express pregunta solo las señales que faltan', () {
    final preguntas = <Map<String, dynamic>>[
      {'clave': 'energia'},
      {'clave': 'horas_sueno'},
      {'clave': 'actividad_ayer'},
      {'clave': 'calidad_sueno'},
    ];

    final pendientes = preguntasPendientes(preguntas);

    expect(
      pendientes.map((pregunta) => pregunta['clave']),
      orderedEquals(<String>['energia', 'calidad_sueno']),
    );
  });

  test('el flujo se adapta si una señal del dispositivo deja de estar disponible', () {
    final preguntas = <Map<String, dynamic>>[
      {'clave': 'energia'},
      {'clave': 'horas_sueno'},
    ];
    final disponiblesSinSueno = Map<String, int>.from(respuestasDispositivoDemo)..remove('horas_sueno');

    final pendientes = preguntasPendientes(preguntas, disponibles: disponiblesSinSueno);

    expect(
      pendientes.map((pregunta) => pregunta['clave']),
      orderedEquals(<String>['energia', 'horas_sueno']),
    );
  });

  test('el prototipo precarga tres señales simuladas del dispositivo', () {
    expect(
      respuestasDispositivoDemo.keys,
      containsAll(<String>['horas_sueno', 'actividad_ayer', 'sedentarismo']),
    );
    expect(respuestasDispositivoDemo.length, 3);
  });
}
