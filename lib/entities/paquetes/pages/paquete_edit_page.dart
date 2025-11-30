import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_strings.dart';
import 'package:sanku_pro/entities/paquetes/services/paquetes_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_field.dart';

class PaquetesEditPage extends StatefulWidget {
  final Map<String, dynamic> args;

  const PaquetesEditPage({super.key, required this.args});

  @override
  State<PaquetesEditPage> createState() => _PaquetesEditPageState();
}

class _PaquetesEditPageState extends State<PaquetesEditPage> {
  final nombreController = TextEditingController();
  final sesionesController = TextEditingController();
  final precioController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    final data = widget.args;

    nombreController.text = (data['nombre_paquete'] ?? '').toString();
    sesionesController.text = (data['numero_sesiones'] ?? '').toString();
    precioController.text = (data['precio'] ?? '').toString();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = widget.args;

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: WidgetAppBar(title: 'Editar paquete'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WidgetField(controller: nombreController, labelText: "Nombre del paquete"),
            WidgetField(
              controller: sesionesController,
              labelText: "Número de sesiones",
              // keyboardType: TextInputType.number,
            ),
            WidgetField(
              controller: precioController,
              labelText: "Precio",
              // keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 25),

            WidgetButton(
              onPressed: () async {
                final nombre = nombreController.text.trim();
                final sesiones = sesionesController.text.trim();
                final precio = precioController.text.trim();

                if (nombre.isEmpty || sesiones.isEmpty || precio.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(AppStrings.errorCamposIncompletos),
                    ),
                  );
                  return;
                }

                final int? numeroSesiones = int.tryParse(sesiones);
                final double? precioValor = double.tryParse(precio);

                if (numeroSesiones == null || precioValor == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Valores inválidos en sesiones o precio."),
                    ),
                  );
                  return;
                }

                setState(() => _isLoading = true);

                try {
                  final data = {
                    "nombre_paquete": nombre,
                    "numero_sesiones": numeroSesiones,
                    "precio": precioValor,
                  };

                  await updatePaquete(arguments["id"], data);

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
