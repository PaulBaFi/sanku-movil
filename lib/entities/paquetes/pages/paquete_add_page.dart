import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/core/constants/app_strings.dart';
import 'package:sanku_pro/entities/paquetes/services/paquetes_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_field.dart';

class PaquetesAddPage extends StatefulWidget {
  const PaquetesAddPage({super.key});

  @override
  State<PaquetesAddPage> createState() => _PaquetesAddPageState();
}

class _PaquetesAddPageState extends State<PaquetesAddPage> {
  final nombreController = TextEditingController();
  final sesionesController = TextEditingController();
  final precioController = TextEditingController();

  bool _isLoading = false;

  Future<void> _savePaquete() async {
    final nombre = nombreController.text.trim();
    final sesiones = sesionesController.text.trim();
    final precio = precioController.text.trim();

    if (nombre.isEmpty || sesiones.isEmpty || precio.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorCamposIncompletos)),
      );
      return;
    }

    final int? numeroSesiones = int.tryParse(sesiones);
    final double? precioValor = double.tryParse(precio);

    if (numeroSesiones == null ||
        precioValor == null ||
        numeroSesiones <= 0 ||
        precioValor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Valores inválidos en sesiones o precio."),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    await addPaquete({
      "nombre_paquete": nombre,
      "numero_sesiones": numeroSesiones,
      "precio": precioValor,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paquete agregado correctamente")),
      );
      context.pop();
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    nombreController.dispose();
    sesionesController.dispose();
    precioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetAppBar(title: "AGREGAR PAQUETE"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WidgetField(controller: nombreController, labelText: "Nombre del paquete"),
            WidgetField(
              controller: sesionesController,
              labelText: "Número de sesiones",
              // keyboardType: TextInputType.number
            ),
            WidgetField(
              controller: precioController,
              labelText: "Precio",
              // keyboardType: TextInputType.number
            ),
            const SizedBox(height: 25),
            WidgetButton(
              text: "Guardar paquete",
              isLoading: _isLoading,
              onPressed: _savePaquete,
            ),
          ],
        ),
      ),
    );
  }
}
