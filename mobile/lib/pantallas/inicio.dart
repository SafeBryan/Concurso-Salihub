import 'package:flutter/material.dart';

import '../api.dart';
import '../tema.dart';
import 'checkin.dart';
import 'historial.dart';
import 'sesion.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  final api = Api.instancia;
  late Future<_Datos> _datos = _cargar();

  Future<_Datos> _cargar() async {
    final respuestas = await Future.wait([
      api.get('perfil/'),
      api.get('indice/hoy/'),
      api.get('entrenamiento/sesion-del-dia/'),
      api.get('indice/historial/?dias=7'),
    ]);
    return _Datos(
      perfil: respuestas[0] as Map<String, dynamic>,
      indice: respuestas[1] as Map<String, dynamic>,
      sesionDelDia: respuestas[2] as Map<String, dynamic>,
      semana: (respuestas[3] as List).cast<Map<String, dynamic>>(),
    );
  }

  void _recargar() {
    if (!mounted) return;
    setState(() {
      _datos = _cargar();
    });
  }

  Future<void> _abrir(Widget pantalla) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => pantalla));
    _recargar();
  }

  void _moverDia(int dias) {
    api.diasAdelante.value = dias;
    _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SaliHub'),
        actions: [
          IconButton(
            tooltip: 'Historial',
            icon: const Icon(Icons.history),
            onPressed: () => _abrir(const PantallaHistorial()),
          ),
          PopupMenuButton<int>(
            tooltip: 'Simular otro día',
            icon: const Icon(Icons.calendar_month_outlined),
            onSelected: _moverDia,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 0, child: Text('Hoy')),
              PopupMenuItem(value: 1, child: Text('Simular mañana')),
              PopupMenuItem(value: 2, child: Text('Simular pasado mañana')),
            ],
          ),
        ],
      ),
      body: FutureBuilder<_Datos>(
        future: _datos,
        builder: (context, estado) {
          if (estado.hasError) return _SinConexion(error: '${estado.error}', reintentar: _recargar);
          if (!estado.hasData) return const Center(child: CircularProgressIndicator());
          final datos = estado.data!;
          return RefreshIndicator(
            onRefresh: () async => _recargar(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                if (api.diasAdelante.value > 0) _AvisoDiaSimulado(dias: api.diasAdelante.value),
                Text('Hola, ${datos.perfil['nombre']}', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                const Text('¡Hoy vamos por sus objetivos!', style: TextStyle(color: Colores.gris)),
                const SizedBox(height: 20),
                _TarjetaIndice(indice: datos.indice, alHacerCheckin: () => _abrir(const PantallaCheckin())),
                const SizedBox(height: 16),
                _TarjetaSesion(datos: datos.sesionDelDia, alAbrir: _abrir),
                const SizedBox(height: 16),
                _Semana(dias: datos.semana),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Datos {
  _Datos({required this.perfil, required this.indice, required this.sesionDelDia, required this.semana});
  final Map<String, dynamic> perfil;
  final Map<String, dynamic> indice;
  final Map<String, dynamic> sesionDelDia;
  final List<Map<String, dynamic>> semana;
}

class _TarjetaIndice extends StatelessWidget {
  const _TarjetaIndice({required this.indice, required this.alHacerCheckin});
  final Map<String, dynamic> indice;
  final VoidCallback alHacerCheckin;

  IconData _iconoFactor(String clave) {
    switch (clave) {
      case 'energia':
        return Icons.bolt_outlined;
      case 'estado_corporal':
        return Icons.accessibility_new_outlined;
      case 'horas_sueno':
      case 'calidad_sueno':
        return Icons.bedtime_outlined;
      case 'actividad_ayer':
        return Icons.directions_walk_outlined;
      case 'sedentarismo':
        return Icons.chair_outlined;
      default:
        return Icons.insights_outlined;
    }
  }

  Color _colorFactor(int puntaje) {
    if (puntaje >= 80) return const Color(0xFF15803D);
    if (puntaje >= 50) return Colores.azul;
    return const Color(0xFFD97706);
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    if (indice['hecho'] != true) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¿Cómo amaneció?', style: texto.titleMedium),
              const SizedBox(height: 8),
              const Text('Su check-in de hoy está pendiente. Responda solo lo necesario para conocer su Readiness.'),
              const SizedBox(height: 6),
              const Text('Toma aproximadamente 15 segundos.', style: TextStyle(color: Colores.gris)),
              const SizedBox(height: 16),
              FilledButton(onPressed: alHacerCheckin, child: const Text('Hacer check-in express')),
            ],
          ),
        ),
      );
    }

    final nivel = indice['nivel'] as Map<String, dynamic>;
    final color = Color(colorDesdeHex(nivel['color'] as String));
    final factores = ((indice['factores'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .take(3)
        .toList();
    final todosFavorables = factores.isNotEmpty && factores.every((factor) => (factor['puntaje'] as int) >= 80);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 88,
                  height: 88,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: (indice['indice'] as int) / 100,
                          strokeWidth: 9,
                          color: color,
                          backgroundColor: color.withValues(alpha: 0.15),
                        ),
                      ),
                      Text('${indice['indice']}', style: texto.headlineMedium),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Readiness Index', style: texto.labelMedium?.copyWith(color: Colores.gris)),
                      Text(nivel['nombre'] as String, style: texto.titleMedium?.copyWith(color: color)),
                      const SizedBox(height: 6),
                      Text(nivel['recomendacion'] as String),
                    ],
                  ),
                ),
              ],
            ),
            if (factores.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(Icons.insights_outlined, color: Colores.navy, size: 21),
                  const SizedBox(width: 8),
                  Expanded(child: Text('¿Qué influyó hoy?', style: texto.titleMedium)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                todosFavorables
                    ? 'Las señales principales están en un rango favorable hoy.'
                    : 'En esta demo, el índice promedia seis señales. Estas son las tres con menor puntaje.',
                style: texto.bodySmall?.copyWith(color: Colores.gris),
              ),
              const SizedBox(height: 14),
              for (final factor in factores) ...[
                _FactorReadiness(
                  factor: factor,
                  icono: _iconoFactor(factor['clave'] as String),
                  color: _colorFactor(factor['puntaje'] as int),
                ),
                if (factor != factores.last) const SizedBox(height: 12),
              ],
            ],
            const SizedBox(height: 14),
            Text(
              indice['aviso'] as String,
              style: texto.bodySmall?.copyWith(color: Colores.gris),
            ),
          ],
        ),
      ),
    );
  }
}

class _FactorReadiness extends StatelessWidget {
  const _FactorReadiness({required this.factor, required this.icono, required this.color});

  final Map<String, dynamic> factor;
  final IconData icono;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icono, color: color, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(factor['nombre'] as String, style: texto.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(factor['respuesta'] as String, style: texto.bodySmall?.copyWith(color: Colores.gris)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            factor['estado'] as String,
            style: texto.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _TarjetaSesion extends StatelessWidget {
  const _TarjetaSesion({required this.datos, required this.alAbrir});
  final Map<String, dynamic> datos;
  final Future<void> Function(Widget) alAbrir;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final sesion = datos['sesion'] as Map<String, dynamic>?;
    return Card(
      color: Colores.navy,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('HOY RECOMENDAMOS', style: texto.labelMedium?.copyWith(color: Colores.menta, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            if (sesion == null)
              Text(datos['motivo'] as String, style: const TextStyle(color: Colors.white))
            else ...[
              Text(sesion['titulo'] as String, style: texto.titleLarge?.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              Text(
                '${sesion['categoria']} · ${sesion['duracion_min']}-${sesion['duracion_max']} min · ${sesion['intensidad']}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              Text(datos['mensaje'] as String, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colores.menta, foregroundColor: Colores.navy),
                onPressed: () => alAbrir(PantallaSesion(codigo: sesion['codigo'] as String)),
                child: Text(datos['terminada_hoy'] == true ? 'Ya la hizo hoy · Ver sesión' : 'Ver sesión'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Semana extends StatelessWidget {
  const _Semana({required this.dias});
  final List<Map<String, dynamic>> dias;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Últimos 7 días', style: texto.titleMedium),
            const SizedBox(height: 12),
            if (dias.isEmpty)
              const Text('Todavía no hay check-ins esta semana.')
            else
              SizedBox(
                height: 90,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final dia in dias)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 60 * (dia['indice'] as int) / 100 + 4,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colores.azul,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              (dia['fecha'] as String).substring(8),
                              style: texto.bodySmall?.copyWith(color: Colores.gris),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AvisoDiaSimulado extends StatelessWidget {
  const _AvisoDiaSimulado({required this.dias});
  final int dias;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colores.menta, borderRadius: BorderRadius.circular(12)),
      child: Text(
        dias == 1 ? 'Está viendo el día de mañana (simulado).' : 'Está viendo un día simulado: dentro de $dias días.',
        style: const TextStyle(color: Colores.navy, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SinConexion extends StatelessWidget {
  const _SinConexion({required this.error, required this.reintentar});
  final String error;
  final VoidCallback reintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colores.gris),
            const SizedBox(height: 12),
            const Text('No se pudo conectar con el API.', textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('¿Está corriendo en $apiUrl?', textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colores.gris, fontSize: 12)),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: reintentar, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
