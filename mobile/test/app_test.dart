import 'package:flutter_test/flutter_test.dart';
import 'package:salihub_reto/api.dart';

void main() {
  test('convierte el color del nivel', () {
    expect(colorDesdeHex('#3B82F6'), 0xFF3B82F6);
  });

  test('el reloj de la demo empieza en hoy', () {
    expect(Api.instancia.diasAdelante.value, 0);
  });
}
