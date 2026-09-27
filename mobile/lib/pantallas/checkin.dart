import 'package:flutter/material.dart';

import '../api.dart';
import '../checkin_express.dart';
import '../tema.dart';

/// Check-in express: pregunta solo las señales que todavía no están disponibles
/// y reutiliza datos simulados del dispositivo para mantener las 6 variables del
/// Readiness Index.
class PantallaCheckin extends StatefulWidget {
  const PantallaCheckin({super.key});

  @override
  State<PantallaCheckin> createState() => _PantallaCheckinState();
}

class _PantallaCheckinState extends State<PantallaCheckin> {
  late final Future<List<dynamic>> _preguntas = Api.instancia.get('checkin/preguntas/').then((d) => d as List);
  final Map<String, int> _respuestas = {...respuestasDispositivoDemo};
  int _pasoActual = 0;
  bool _enviando = false;

  Future<void> _enviar() async {
    setState(() => _enviando = true);
    try {
      await Api.instancia.post('checkin/', {'respuestas': _respuestas});
      if (mounted) Navigator.of(context).pop();
    } on ApiError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.mensaje)));
      setState(() => _enviando = false);
    }
  }

  String _opcionSeleccionada(Map<String, dynamic> pregunta) {
    final clave = pregunta['clave'] as String;
    final indice = _respuestas[clave];
    if (indice == null) return 'Sin dato';
    return (pregunta['opciones'] as List)[indice] as String;
  }

  IconData _iconoPara(String clave) {
    switch (clave) {
      case 'horas_sueno':
        return Icons.bedtime_outlined;
      case 'actividad_ayer':
        return Icons.directions_walk_outlined;
      case 'sedentarismo':
        return Icons.chair_outlined;
      default:
        return Icons.watch_outlined;
    }
  }

  Future<void> _revisarDatosDispositivo(List<Map<String, dynamic>> preguntas) async {
    final preguntasDispositivo = preguntas
        .where((pregunta) => respuestasDispositivoDemo.containsKey(pregunta['clave'] as String))
        .toList();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, actualizarModal) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Revisar datos del dispositivo', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    const Text(
                      'En esta demo son datos simulados. En producción esta capa podría recibir señales de las integraciones de SaliHub. Puede corregirlas antes de calcular su índice.',
                      style: TextStyle(color: Colores.gris),
                    ),
                    const SizedBox(height: 20),
                    for (final pregunta in preguntasDispositivo) ...[
                      Text(pregunta['texto'] as String, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final (i, opcion) in (pregunta['opciones'] as List).indexed)
                            ChoiceChip(
                              label: Text(opcion as String),
                              selected: _respuestas[pregunta['clave']] == i,
                              selectedColor: Colores.menta,
                              onSelected: (_) {
                                setState(() => _respuestas[pregunta['clave'] as String] = i);
                                actualizarModal(() {});
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 22),
                    ],
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Guardar y continuar'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-in express')),
      body: FutureBuilder<List<dynamic>>(
        future: _preguntas,
        builder: (context, estado) {
          if (estado.hasError) return Center(child: Text('${estado.error}'));
          if (!estado.hasData) return const Center(child: CircularProgressIndicator());

          final preguntas = estado.data!.cast<Map<String, dynamic>>();
          final manuales = preguntasPendientes(preguntas);
          if (manuales.isEmpty) return const Center(child: Text('No hay preguntas disponibles.'));

          final paso = _pasoActual < manuales.length ? _pasoActual : manuales.length - 1;
          final pregunta = manuales[paso];
          final clave = pregunta['clave'] as String;
          final respondida = _respuestas.containsKey(clave);
          final esUltima = paso == manuales.length - 1;
          final preguntasDispositivo = preguntas
              .where((p) => respuestasDispositivoDemo.containsKey(p['clave'] as String))
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text('Buenos días 👋', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              const Text(
                'Ya hay señales disponibles para hoy. Solo preguntaremos la información que todavía falta.',
                style: TextStyle(color: Colores.gris),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colores.menta.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.watch_outlined, color: Colores.navy),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${preguntasDispositivo.length} señales ya disponibles',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const Icon(Icons.check_circle, color: Colores.navy, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Simuladas en esta demo. El objetivo es no volver a preguntar datos que ya estén disponibles.',
                      style: TextStyle(color: Colores.gris, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    for (final dato in preguntasDispositivo) ...[
                      Row(
                        children: [
                          Icon(_iconoPara(dato['clave'] as String), size: 20, color: Colores.gris),
                          const SizedBox(width: 10),
                          Expanded(child: Text(dato['texto'] as String)),
                          const SizedBox(width: 8),
                          Text(
                            _opcionSeleccionada(dato),
                            style: const TextStyle(fontWeight: FontWeight.w700, color: Colores.navy),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                    TextButton.icon(
                      onPressed: () => _revisarDatosDispositivo(preguntas),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Revisar o corregir estos datos'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Pregunta ${paso + 1} de ${manuales.length}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colores.gris),
                  ),
                  const Spacer(),
                  const Text('~15 s', style: TextStyle(color: Colores.gris)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (paso + 1) / manuales.length,
                minHeight: 7,
                borderRadius: BorderRadius.circular(99),
                backgroundColor: Colores.menta.withValues(alpha: 0.35),
              ),
              const SizedBox(height: 22),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pregunta['texto'] as String, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final (i, opcion) in (pregunta['opciones'] as List).indexed)
                            ChoiceChip(
                              label: Text(opcion as String),
                              selected: _respuestas[clave] == i,
                              selectedColor: Colores.menta,
                              onSelected: (_) => setState(() => _respuestas[clave] = i),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (paso > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _enviando ? null : () => setState(() => _pasoActual--),
                        child: const Text('Anterior'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: FilledButton(
                      onPressed: !respondida || _enviando
                          ? null
                          : esUltima
                              ? _enviar
                              : () => setState(() => _pasoActual++),
                      child: Text(esUltima ? 'Ver mi Readiness Index' : 'Continuar'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
