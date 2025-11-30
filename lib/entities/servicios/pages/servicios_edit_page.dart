import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_strings.dart';
import 'package:sanku_pro/entities/servicios/services/servicios_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_field.dart';

class ServiciosEditPage extends StatefulWidget {
  final Map<String, dynamic> args;

  const ServiciosEditPage({super.key, required this.args});

  @override
  State<ServiciosEditPage> createState() => _ServiciosEditPageState();
}

class _ServiciosEditPageState extends State<ServiciosEditPage> {
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    final data = widget.args;

    nombreController.text = (data['nombre_servicio'] ?? '').toString();
    descripcionController.text = (data['descripcion'] ?? '').toString();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = widget.args;
    
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: WidgetAppBar(title: 'Editar servicio'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WidgetField(
              controller: nombreController,
              labelText: "Nombre del servicio",
            ),
            WidgetField(
              controller: descripcionController,
              labelText: "Descripción (opcional)",
            ),

            const SizedBox(height: 25),

            WidgetButton(
              onPressed: () async {
                final nombre = nombreController.text.trim();
                final descripcion = descripcionController.text.trim();

                if (nombre.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(AppStrings.errorCamposIncompletos),
                    ),
                  );
                  return;
                }

                setState(() => _isLoading = true);

                try {
                  final data = {
                    "nombre_servicio": nombre,
                    "descripcion": descripcion.isEmpty ? null : descripcion,
                  };

                  await updateServicio(arguments["id"], data);

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
