import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_strings.dart';
import 'package:sanku_pro/entities/especialidades/services/especialidades_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_field.dart';

class EspecialidadesEditPage extends StatefulWidget {
  final Map<String, dynamic> args;

  const EspecialidadesEditPage({super.key, required this.args});

  @override
  State<EspecialidadesEditPage> createState() => _EspecialidadesEditPageState();
}

class _EspecialidadesEditPageState extends State<EspecialidadesEditPage> {
  final especialidadController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    final initialEspecialidad = (widget.args['especialidad'] ?? '') as String;

    especialidadController.text = initialEspecialidad;
  }

  @override
  Widget build(BuildContext context) {
    final arguments = widget.args;
    
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: const WidgetAppBar(title: 'Editar especialidad'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WidgetField(
              controller: especialidadController,
              labelText: "Especialidad",
            ),

            const SizedBox(height: 20.0),

            WidgetButton(
              onPressed: () async {
                final newEspecialidad = especialidadController.text.trim();

                if (newEspecialidad.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(AppStrings.errorCamposIncompletos),
                    ),
                  );
                  return;
                }

                setState(() => _isLoading = true);

                try {
                  final data = {"especialidad": newEspecialidad};

                  await updateEspecialidad(arguments["id"], data);

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
              text: 'Actualizar',
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
