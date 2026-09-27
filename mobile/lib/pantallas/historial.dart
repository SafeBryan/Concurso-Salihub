import 'package:flutter/material.dart';

import '../api.dart';
import '../tema.dart';

class PantallaHistorial extends StatelessWidget {
  const PantallaHistorial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: FutureBuilder<dynamic>(
        future: Api.instancia.get('entrenamiento/registros/'),
        builder: (context, estado) {
          if (estado.hasError) return Center(child: Text('${estado.error}'));
          if (!estado.hasData) return const Center(child: CircularProgressIndicator());
          final registros = (estado.data as List).cast<Map<String, dynamic>>();
          if (registros.isEmpty) return const Center(child: Text('Aún no hay sesiones.'));
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: registros.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              if (i == 0) {
                return Text('Sesiones completadas', style: Theme.of(context).textTheme.titleMedium);
              }
              final registro = registros[i - 1];
              return Card(
                child: ListTile(
                  title: Text(registro['titulo'] as String),
                  subtitle: Text('${registro['fecha']} · Esfuerzo ${registro['esfuerzo']} de 10'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${registro['valoracion']}'),
                      const Icon(Icons.star_rounded, color: Colores.azul),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
