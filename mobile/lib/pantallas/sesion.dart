import 'dart:async';

import 'package:flutter/material.dart';

import '../api.dart';
import '../tema.dart';

/// Detalle de la sesión, guía paso a paso y «¿Cómo le fue?».
class PantallaSesion extends StatefulWidget {
  const PantallaSesion({super.key, required this.codigo});
  final String codigo;

  @override
  State<PantallaSesion> createState() => _PantallaSesionState();
}

class _PantallaSesionState extends State<PantallaSesion> {
  late final Future<Map<String, dynamic>> _sesion =
      Api.instancia.get('entrenamiento/sesiones/${widget.codigo}/').then((d) => d as Map<String, dynamic>);

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Sesión de entrenamiento')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _sesion,
        builder: (context, estado) {
          if (estado.hasError) return Center(child: Text('${estado.error}'));
          if (!estado.hasData) return const Center(child: CircularProgressIndicator());
          final sesion = estado.data!;
          final pasos = (sesion['pasos'] as List).cast<Map<String, dynamic>>();
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(sesion['titulo'] as String, style: texto.headlineMedium),
              const SizedBox(height: 6),
              Text(sesion['objetivo'] as String),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Dato('${sesion['duracion_min']}-${sesion['duracion_max']} min'),
                  _Dato(sesion['categoria'] as String),
                  _Dato('Esfuerzo ${sesion['rpe_min']}-${sesion['rpe_maximo']} de 10'),
                  _Dato('Equipo: ${sesion['equipo']}'),
                ],
              ),
              const SizedBox(height: 20),
              Text('Mensaje del entrenador', style: texto.titleMedium),
              const SizedBox(height: 4),
              Text(sesion['mensaje'] as String),
              const SizedBox(height: 20),
              Text('Pasos', style: texto.titleMedium),
              const SizedBox(height: 8),
              for (final paso in pasos)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colores.menta,
                    foregroundColor: Colores.navy,
                    child: Text('${paso['orden']}'),
                  ),
                  title: Text(paso['contenido'] as String),
                  subtitle: Text(_duracion(paso['duracion_segundos'] as int)),
                ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => _SesionGuiada(sesion: sesion)),
                ),
                child: const Text('Empezar sesión'),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _duracion(int segundos) {
  if (segundos < 60) return '$segundos s';
  final minutos = segundos ~/ 60;
  final resto = segundos % 60;
  return resto == 0 ? '$minutos min' : '$minutos min $resto s';
}

class _Dato extends StatelessWidget {
  const _Dato(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Chip(label: Text(texto), backgroundColor: Colors.white, side: BorderSide.none);
}

class _SesionGuiada extends StatefulWidget {
  const _SesionGuiada({required this.sesion});
  final Map<String, dynamic> sesion;

  @override
  State<_SesionGuiada> createState() => _SesionGuiadaState();
}

class _SesionGuiadaState extends State<_SesionGuiada> {
  late final List<Map<String, dynamic>> _pasos = (widget.sesion['pasos'] as List).cast<Map<String, dynamic>>();
  int _actual = 0;
  int _restante = 0;
  Timer? _reloj;

  @override
  void initState() {
    super.initState();
    _irA(0);
  }

  void _irA(int indice) {
    _reloj?.cancel();
    if (indice >= _pasos.length) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => _ComoTeFue(sesion: widget.sesion)),
      );
      return;
    }
    setState(() {
      _actual = indice;
      _restante = _pasos[indice]['duracion_segundos'] as int;
    });
    _reloj = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_restante <= 1) {
        _reloj?.cancel();
        setState(() => _restante = 0);
      } else {
        setState(() => _restante--);
      }
    });
  }

  @override
  void dispose() {
    _reloj?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final paso = _pasos[_actual];
    final ultimo = _actual == _pasos.length - 1;
    return Scaffold(
      appBar: AppBar(title: const Text('Sesión guiada')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            LinearProgressIndicator(value: (_actual + 1) / _pasos.length, color: Colores.azul),
            const SizedBox(height: 8),
            Text('Paso ${_actual + 1} de ${_pasos.length}', style: const TextStyle(color: Colores.gris)),
            const Spacer(),
            Text(paso['contenido'] as String, style: texto.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Text(
              '${(_restante ~/ 60).toString().padLeft(2, '0')}:${(_restante % 60).toString().padLeft(2, '0')}',
              style: texto.displayMedium?.copyWith(color: Colores.azul, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _actual == 0 ? null : () => _irA(_actual - 1),
                    child: const Text('Anterior'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () => _irA(_actual + 1),
                    child: Text(ultimo ? 'Terminar' : (_restante == 0 ? 'Hecho' : 'Saltar')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ComoTeFue extends StatefulWidget {
  const _ComoTeFue({required this.sesion});
  final Map<String, dynamic> sesion;

  @override
  State<_ComoTeFue> createState() => _ComoTeFueState();
}

class _ComoTeFueState extends State<_ComoTeFue> {
  int _valoracion = 4;
  double _esfuerzo = 5;
  final _comentario = TextEditingController();
  bool _enviando = false;

  Future<void> _guardar() async {
    setState(() => _enviando = true);
    try {
      await Api.instancia.post('entrenamiento/registros/', {
        'sesion': widget.sesion['codigo'],
        'valoracion': _valoracion,
        'esfuerzo': _esfuerzo.round(),
        'comentario': _comentario.text,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Sesión registrada!')));
      Navigator.of(context).pop();
    } on ApiError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.mensaje)));
      setState(() => _enviando = false);
    }
  }

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  String get _etiquetaEsfuerzo {
    final valor = _esfuerzo.round();
    if (valor <= 3) return 'Suave';
    if (valor <= 6) return 'Moderado';
    return 'Exigente';
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('¿Cómo le fue?')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(widget.sesion['titulo'] as String, style: texto.titleLarge),
          const SizedBox(height: 24),
          Text('¿Qué tal estuvo la sesión?', style: texto.titleMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  iconSize: 36,
                  onPressed: () => setState(() => _valoracion = i),
                  icon: Icon(i <= _valoracion ? Icons.star_rounded : Icons.star_outline_rounded, color: Colores.azul),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Esfuerzo percibido (0–10): ${_esfuerzo.round()} · $_etiquetaEsfuerzo', style: texto.titleMedium),
          Slider(value: _esfuerzo, min: 0, max: 10, divisions: 10, onChanged: (v) => setState(() => _esfuerzo = v)),
          const SizedBox(height: 16),
          TextField(
            controller: _comentario,
            maxLength: 500,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Comentario (opcional)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _enviando ? null : _guardar, child: const Text('Guardar')),
        ],
      ),
    );
  }
}
