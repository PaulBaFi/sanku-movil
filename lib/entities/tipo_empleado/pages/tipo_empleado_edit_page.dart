import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_strings.dart';
import 'package:sanku_pro/entities/tipo_empleado/services/tipo_empleado_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_field.dart';

class TipoEmpleadoEditPage extends StatefulWidget {
  final Map<String, dynamic> args;

  const TipoEmpleadoEditPage({super.key, required this.args});

  @override
  State<TipoEmpleadoEditPage> createState() => _TipoEmpleadoEditPageState();
}

class _TipoEmpleadoEditPageState extends State<TipoEmpleadoEditPage> {
  final tipoEmpleadoController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    final initialTipoEmpleado = (widget.args['tipo_empleado'] ?? '') as String;

    tipoEmpleadoController.text = initialTipoEmpleado;
  }

  @override
  Widget build(BuildContext context) {
    final arguments = widget.args;
    
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: WidgetAppBar(title: 'Editar tipo de empleado'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WidgetField(controller: tipoEmpleadoController, labelText: "Tipo de empleado"),

            const SizedBox(height: 20.0),

            WidgetButton(
              onPressed: () async {
                final newTipoEmpleado = tipoEmpleadoController.text.trim();

                if (newTipoEmpleado.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppStrings.errorCamposIncompletos)),
                  );
                  return;
                }

                setState(() => _isLoading = true);

                try {
                  final data = {"tipo_empleado": newTipoEmpleado};

                  await updateTipoEmpleado(arguments["id"], data);
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('Registro actualizado')),
                    );
                    navigator.pop();
                  }
                } catch (e) {
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('Error al actualizar: $e')),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
              isLoading: _isLoading,
              text: 'Actualizar',
            ),
          ],
        ),
      ),
    );
  }
}
