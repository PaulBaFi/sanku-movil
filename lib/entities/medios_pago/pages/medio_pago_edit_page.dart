import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_strings.dart';
import 'package:sanku_pro/entities/medios_pago/services/medios_pago_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_field.dart';

class MedioPagoEditPage extends StatefulWidget {
  final Map<String, dynamic> args;

  const MedioPagoEditPage({super.key, required this.args});

  @override
  State<MedioPagoEditPage> createState() => _MedioPagoEditPageState();
}

class _MedioPagoEditPageState extends State<MedioPagoEditPage> {
  final nombreController = TextEditingController();
  final imagenController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    final initialNombre = (widget.args['nombre'] ?? '') as String;
    final initialImagen = (widget.args['imagen'] ?? '') as String;

    nombreController.text = initialNombre;
    imagenController.text = initialImagen;
  }

  @override
  Widget build(BuildContext context) {
    final arguments = widget.args;

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: WidgetAppBar(title: 'Editar medio de pago'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WidgetField(controller: nombreController, labelText: "Nombre"),

            const SizedBox(height: 20),

            WidgetField(
              controller: imagenController,
              labelText: "URL de la imagen",
            ),
            const SizedBox(height: 20),

            WidgetButton(
              onPressed: () async {
                final newNombre = nombreController.text.trim();
                final newImagen = imagenController.text.trim();

                if (newNombre.isEmpty || newImagen.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(AppStrings.errorCamposIncompletos),
                    ),
                  );
                  return;
                }

                setState(() => _isLoading = true);

                try {
                  final data = {"nombre": newNombre, "imagen": newImagen};

                  await updateMedioPago(arguments["id"], data);
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
