import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/core/routes/app_routes.dart';
import 'package:sanku_pro/entities/especialidades/services/especialidades_firebase_service.dart';
import 'package:sanku_pro/presentation/components/custom_bottom_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_fab.dart';
import 'package:sanku_pro/presentation/widgets/widget_main_layout.dart';

class EspecialidadesPage extends StatefulWidget {
  const EspecialidadesPage({super.key});

  @override
  State<EspecialidadesPage> createState() => _EspecialidadesPageState();
}

class _EspecialidadesPageState extends State<EspecialidadesPage> {
  late Future<List> _especialidadesFuture;

  @override
  void initState() {
    super.initState();
    _especialidadesFuture = getEspecialidades();
  }

  Future<void> _refresh() async {
    setState(() {
      _especialidadesFuture = getEspecialidades();
    });
    await _especialidadesFuture;
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Desea eliminar esta especialidad?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await deleteEspecialidad(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Especialidad eliminado')));
        await _refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetAppBar(title: 'ESPECIALIDADES'),
      body: WidgetMainLayout(
        child: FutureBuilder(
          future: _especialidadesFuture,
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
              return const Center(child: Text('No hay especialidades.'));
            }

            final data = snapshot.data as List;

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final especialidad = data[index] as Map<String, dynamic>;
                final id = especialidad['id'];
                final name = "${especialidad['especialidad'] ?? ''}".trim();

                return ListTile(
                  title: Text(name.isEmpty ? 'Sin nombre' : name),
                  onTap: () async {
                    await context.push(
                      AppRoutes.especialidadesEdit,
                      extra: especialidad,
                    );
                    await _refresh();
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(id),
                  ),
                );
              },
            );
          }),
        ),
      ),
      floatingActionButton: WidgetFAB(
        tooltip: 'Agregar especialidad',
        onPressed: () async {
          await context.push(AppRoutes.especialidadesAdd);
          await _refresh();
        },
        icon: Icons.add,
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }
}
