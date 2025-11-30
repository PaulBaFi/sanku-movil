import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/core/constants/app_strings.dart';
import 'package:sanku_pro/entities/servicios/services/servicios_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_field.dart';

class ServiciosAddPage extends StatefulWidget {
  const ServiciosAddPage({super.key});

  @override
  State<ServiciosAddPage> createState() => _ServiciosAddPageState();
}

class _ServiciosAddPageState extends State<ServiciosAddPage> {
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();

  bool _isLoading = false;

  Future<void> _saveServicio() async {
    final nombre = nombreController.text.trim();
    final descripcion = descripcionController.text.trim();

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorCamposIncompletos)),
      );
      return;
    }

    setState(() => _isLoading = true);

    await addServicio({
      "nombre_servicio": nombre,
      "descripcion": descripcion.isEmpty ? null : descripcion,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Servicio agregado correctamente")),
      );
      context.pop();
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetAppBar(title: "AGREGAR SERVICIO"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WidgetField(controller: nombreController, labelText: "Nombre del servicio"),
            WidgetField(controller: descripcionController, labelText: "Descripción (opcional)"),
            const SizedBox(height: 25),
            WidgetButton(
              text: "Guardar servicio",
              isLoading: _isLoading,
              onPressed: _saveServicio,
            ),
          ],
        ),
      ),
    );
  }
}
