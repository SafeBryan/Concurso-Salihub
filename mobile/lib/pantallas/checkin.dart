import 'package:flutter/material.dart';

import '../api.dart';
import '../tema.dart';

/// Check-in de la mañana: 6 preguntas, una opción por pregunta.
class PantallaCheckin extends StatefulWidget {
  const PantallaCheckin({super.key});

  @override
  State<PantallaCheckin> createState() => _PantallaCheckinState();
}

class _PantallaCheckinState extends State<PantallaCheckin> {
  late final Future<List<dynamic>> _preguntas = Api.instancia.get('checkin/preguntas/').then((d) => d as List);
  final Map<String, int> _respuestas = {};
  bool _enviando = false;

  Future<void> _enviar(int total) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-in de hoy')),
      body: FutureBuilder<List<dynamic>>(
        future: _preguntas,
        builder: (context, estado) {
          if (estado.hasError) return Center(child: Text('${estado.error}'));
          if (!estado.hasData) return const Center(child: CircularProgressIndicator());
          final preguntas = estado.data!.cast<Map<String, dynamic>>();
          final completo = _respuestas.length == preguntas.length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              for (final pregunta in preguntas) ...[
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
                        onSelected: (_) => setState(() => _respuestas[pregunta['clave'] as String] = i),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              FilledButton(
                onPressed: completo && !_enviando ? () => _enviar(preguntas.length) : null,
                child: Text(completo ? 'Ver mi Readiness Index' : 'Responda las ${preguntas.length} preguntas'),
              ),
            ],
          );
        },
      ),
    );
  }
}
