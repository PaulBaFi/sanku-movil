import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/core/constants/app_strings.dart';
import 'package:sanku_pro/entities/tipo_empleado/services/tipo_empleado_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_field.dart';

class TipoEmpleadoAddPage extends StatefulWidget {
  const TipoEmpleadoAddPage({super.key});

  @override
  State<TipoEmpleadoAddPage> createState() => _TipoEmpleadoAddPageState();
}

class _TipoEmpleadoAddPageState extends State<TipoEmpleadoAddPage> {
  final tipoEmpleadoController = TextEditingController();

  bool _isLoading = false;

  Future<void> _saveTipoEmpleado() async {
    final tipoEmpleado = tipoEmpleadoController.text.trim();

    if (tipoEmpleado.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorCamposIncompletos)),
      );
      return;
    }

    setState(() => _isLoading = true);

    await addTipoEmpleado({"tipo_empleado": tipoEmpleado});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tipo de empleado agregado correctamente"),
        ),
      );
      context.pop();
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    tipoEmpleadoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetAppBar(title: 'AGREGAR TIPO DE EMPLEADO'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WidgetField(controller: tipoEmpleadoController, labelText: "Tipo de empleado"),
            const SizedBox(height: 25),
            WidgetButton(
              isLoading: _isLoading,
              text: "Guardar tipo de empleado",
              onPressed: _saveTipoEmpleado,
            ),
          ],
        ),
      ),
    );
  }
}
