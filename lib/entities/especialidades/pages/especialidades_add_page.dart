import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/core/constants/app_strings.dart';
import 'package:sanku_pro/entities/especialidades/services/especialidades_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_field.dart';

class EspecialidadesAddPage extends StatefulWidget {
  const EspecialidadesAddPage({super.key});

  @override
  State<EspecialidadesAddPage> createState() => _EspecialidadesAddPageState();
}

class _EspecialidadesAddPageState extends State<EspecialidadesAddPage> {
  final especialidadController = TextEditingController();

  bool _isLoading = false;

  Future<void> _saveEspecialidad() async {
    final especialidad = especialidadController.text.trim();

    if (especialidad.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorCamposIncompletos)),
      );
      return;
    }

    setState(() => _isLoading = true);

    await addEspecialidad({"especialidad": especialidad});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Especialidad agregada correctamente")),
      );
      context.pop();
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    especialidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WidgetAppBar(title: 'AGREGAR ESPECIALIDAD'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WidgetField(
              controller: especialidadController,
              labelText: "Especialidad",
            ),
            const SizedBox(height: 25),
            WidgetButton(
              isLoading: _isLoading,
              text: "Guardar especialidad",
              onPressed: _saveEspecialidad,
            ),
          ],
        ),
      ),
    );
  }
}
