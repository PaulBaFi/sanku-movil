import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/core/routes/app_routes.dart';
import 'package:sanku_pro/entities/tipo_empleado/services/tipo_empleado_firebase_service.dart';
import 'package:sanku_pro/presentation/components/custom_bottom_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_fab.dart';
import 'package:sanku_pro/presentation/widgets/widget_main_layout.dart';

class TipoEmpleadoPage extends StatefulWidget {
  const TipoEmpleadoPage({super.key});

  @override
  State<TipoEmpleadoPage> createState() => _TipoEmpleadoPageState();
}

class _TipoEmpleadoPageState extends State<TipoEmpleadoPage> {
  late Future<List> _empleadosFuture;

  @override
  void initState() {
    super.initState();
    _empleadosFuture = getTiposEmpleado();
  }

  Future<void> _refresh() async {
    setState(() {
      _empleadosFuture = getTiposEmpleado();
    });
    await _empleadosFuture;
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Desea eliminar este tipo de empleado?'),
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
      await deleteTipoEmpleado(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tipo de empleado eliminado')));
        await _refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetAppBar(title: 'TIPOS DE EMPLEADO'),
      body: WidgetMainLayout(
        child: FutureBuilder(
          future: _empleadosFuture,
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
              return const Center(child: Text('No hay tipos de empleado.'));
            }

            final data = snapshot.data as List;

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final tipoEmpleado = data[index] as Map<String, dynamic>;
                final id = tipoEmpleado['id'];
                final name = "${tipoEmpleado['tipo_empleado'] ?? ''}".trim();

                return ListTile(
                  title: Text(name.isEmpty ? 'Sin nombre' : name),
                  onTap: () async {
                    await context.push(
                      AppRoutes.tipoEmpleadoEdit,
                      extra: tipoEmpleado,
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
        icon: Icons.add,
        tooltip: 'Agregar tipo de empleado',
        onPressed: () async {
          await context.push(AppRoutes.tipoEmpleadoAdd);
          await _refresh();
        },
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }
}
