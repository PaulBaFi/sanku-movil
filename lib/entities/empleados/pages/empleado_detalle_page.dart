import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';
import 'package:sanku_pro/core/constants/app_text_styles.dart';
import 'package:sanku_pro/core/routes/app_routes_index.dart';
import 'package:sanku_pro/entities/empleados/services/empleados_firebase_service.dart';
import 'package:sanku_pro/presentation/utils/others/confirm_dialog.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_details_layout.dart';

class EmpleadoDetallePage extends StatefulWidget {
  final Map<String, dynamic> args;

  const EmpleadoDetallePage({super.key, required this.args});

  @override
  State<EmpleadoDetallePage> createState() => _EmpleadoDetallePageState();
}

class _EmpleadoDetallePageState extends State<EmpleadoDetallePage> {
  Future<void> _confirmDelete(String id) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Confirmar eliminación',
      content: '¿Desea eliminar este empleado?',
    );

    if (confirmed == true) {
      await deleteEmpleado(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Empleado eliminado')));
        context.pop(); // Volver a la lista
      }
    }
  }

  int calcularEdad(String fechaNacimiento) {
    try {
      final partes = fechaNacimiento.split('-'); // formato esperado: yyyy-mm-dd
      final nacimiento = DateTime(
        int.parse(partes[0]),
        int.parse(partes[1]),
        int.parse(partes[2]),
      );

      final hoy = DateTime.now();
      int edad = hoy.year - nacimiento.year;

      if (hoy.month < nacimiento.month ||
          (hoy.month == nacimiento.month && hoy.day < nacimiento.day)) {
        edad--;
      }

      return edad;
    } catch (e) {
      return 0; // si la fecha tiene formato inválido
    }
  }

  @override
  Widget build(BuildContext context) {
    final empleado = widget.args;

    return Scaffold(
      appBar: WidgetAppBar(title: 'Detalles del empleado'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            WidgetDetailsLayout(
              child: Column(
                children: [
                  // Avatar
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        empleado["avatarUrl"] ?? "",
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.marginM),

                  Text(
                    '${empleado["nombres"]} ${empleado["apellidos"]}',
                    style: AppTextStyles.textTheme.titleMedium,
                  ),
                  Text('${empleado["especialidad"]}'),

                  const SizedBox(height: AppDimensions.marginL),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _pin(empleado["dni"]),
                      const SizedBox(width: 10),
                      _pin("${calcularEdad(empleado["nacimiento"])} años"),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.marginXL),

                  _item("Teléfono", empleado["phone"]),
                  _item("Dirección", empleado["direccion"]),
                  _item("Nacimiento", empleado["nacimiento"]),
                  _item("Email", empleado["email"]),

                  const SizedBox(height: AppDimensions.marginXS),
                  const Divider(thickness: 0.7),
                  const SizedBox(height: AppDimensions.marginXS),

                  _item("Tipo de Empleado", empleado["tipo_empleado"]),

                  const SizedBox(height: AppDimensions.marginXS),
                  const Divider(thickness: 0.7),
                  const SizedBox(height: AppDimensions.marginM),

                  Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      WidgetButtonNeutral(
                        onPressed: () {
                          context.push(
                            AppRoutes.empleadosEdit,
                            extra: empleado,
                          );
                        },
                        iconSpacing: 8,
                        icon: Icons.edit,
                        text: "Editar",
                      ),
                      WidgetButtonAlert(
                        onPressed: () => _confirmDelete(empleado["id"]),
                        icon: Icons.delete,
                        iconSpacing: 8,
                        text: "Eliminar",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pin(String text) {
    return Container(
      padding: EdgeInsetsGeometry.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.radiusXL)),
      ),
      child: Text(text, style: TextStyle(color: AppColors.textMutedLight)),
    );
  }

  Widget _item(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            value?.toString() ?? "-",
            maxLines: 3,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
