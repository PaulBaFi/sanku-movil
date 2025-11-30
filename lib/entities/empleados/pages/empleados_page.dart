import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/routes/app_routes.dart';
import 'package:sanku_pro/entities/empleados/services/empleados_firebase_service.dart';
import 'package:sanku_pro/presentation/components/custom_bottom_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_fab.dart';
import 'package:sanku_pro/presentation/widgets/widget_main_layout.dart';

class EmpleadosPage extends StatefulWidget {
  const EmpleadosPage({super.key});

  @override
  State<EmpleadosPage> createState() => _EmpleadosPageState();
}

class _EmpleadosPageState extends State<EmpleadosPage> {
  late Future<List> _empleadosFuture;

  @override
  void initState() {
    super.initState();
    _empleadosFuture = getEmpleados();
  }

  Future<void> _refresh() async {
    setState(() {
      _empleadosFuture = getEmpleados();
    });
    await _empleadosFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetAppBar(title: 'EMPLEADOS'),
      body: WidgetMainLayout(
        child: FutureBuilder(
          future: _empleadosFuture,
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
              return const Center(child: Text('No hay empleados'));
            }

            final data = snapshot.data as List;

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final empleado = data[index] as Map<String, dynamic>;
                final name =
                    "${empleado['nombres'] ?? ''} ${empleado['apellidos'] ?? ''}"
                        .trim();

                return ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.backgroundLight,
                    backgroundImage:
                        (empleado['avatarUrl'] != null &&
                            empleado['avatarUrl'].toString().isNotEmpty)
                        ? NetworkImage(empleado['avatarUrl'])
                        : null,
                    child:
                        (empleado['avatarUrl'] == null ||
                            empleado['avatarUrl'].toString().isEmpty)
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  title: Text(name.isEmpty ? 'Sin nombre' : name),
                  subtitle: Text(
                    "${empleado['especialidad'] ?? ''} • ${empleado['tipo_empleado'] ?? ''}",
                  ),
                  onTap: () async {
                    await context.push(
                      AppRoutes.empleadoDetalle,
                      extra: empleado,
                    );
                    await _refresh();
                  },
                  trailing: const Icon(Icons.chevron_right_rounded),
                );
              },
            );
          }),
        ),
      ),
      floatingActionButton: WidgetFAB(
        icon: Icons.add,
        tooltip: 'Agregar empleado',
        onPressed: () async {
          await context.push(AppRoutes.empleadosAdd);
          await _refresh();
        },
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }
}
