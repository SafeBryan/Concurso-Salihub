import 'package:flutter/material.dart';

import 'pantallas/inicio.dart';
import 'tema.dart';

void main() => runApp(const SaliHubReto());

class SaliHubReto extends StatelessWidget {
  const SaliHubReto({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaliHub · Demo del reto',
      debugShowCheckedModeBanner: false,
      theme: temaSaliHub(),
      home: const PantallaInicio(),
    );
  }
}
