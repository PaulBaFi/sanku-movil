import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/core/constants/app_strings.dart';
import 'package:sanku_pro/entities/empleados/services/empleados_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_dropdown.dart';
import 'package:sanku_pro/presentation/widgets/widget_field.dart';
import 'package:sanku_pro/presentation/widgets/widget_picker.dart';

class EmpleadosEditPage extends StatefulWidget {
  final Map<String, dynamic> args;

  const EmpleadosEditPage({super.key, required this.args});

  @override
  State<EmpleadosEditPage> createState() => _EmpleadosEditPageState();
}

class _EmpleadosEditPageState extends State<EmpleadosEditPage> {
  // CONTROLADORES DE TEXTO
  final nombresController = TextEditingController();
  final apellidosController = TextEditingController();
  final dniController = TextEditingController();
  final nacimientoController = TextEditingController();
  final phoneController = TextEditingController();
  final direccionController = TextEditingController();
  final emailController = TextEditingController();

  // Dropdown values
  String? selectedTipoEmpleado;
  String? selectedEspecialidad;

  List<Map<String, dynamic>> tiposEmpleado = [];
  List<Map<String, dynamic>> especialidades = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    final args = widget.args;

    // Cargar valores iniciales
    nombresController.text = args['nombres'] ?? '';
    apellidosController.text = args['apellidos'] ?? '';
    dniController.text = args['dni'] ?? '';
    nacimientoController.text = args['nacimiento'] ?? '';
    phoneController.text = args['phone'] ?? '';
    direccionController.text = args['direccion'] ?? '';
    emailController.text = args['email'] ?? '';

    selectedTipoEmpleado = args['tipo_empleado'];
    selectedEspecialidad = args['especialidad'];

    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    tiposEmpleado = await getTiposEmpleadoDesdeEmpleado();
    especialidades = await getEspecialidadesDesdeEmpleado();
    setState(() {});
  }

  Future<void> _updateEmpleado() async {
    final nombres = nombresController.text.trim();
    final apellidos = apellidosController.text.trim();
    final dni = dniController.text.trim();
    final nacimiento = nacimientoController.text.trim();
    final phone = phoneController.text.trim();
    final direccion = direccionController.text.trim();
    final email = emailController.text.trim();

    if (nombres.isEmpty ||
        apellidos.isEmpty ||
        dni.isEmpty ||
        selectedTipoEmpleado == null ||
        selectedEspecialidad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorCamposIncompletos)),
      );
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      "nombres": nombres,
      "apellidos": apellidos,
      "dni": dni,
      "nacimiento": nacimiento,
      "phone": phone,
      "direccion": direccion,
      "tipo_empleado": selectedTipoEmpleado,
      "especialidad": selectedEspecialidad,
      "email": email,
    };

    try {
      await updateEmpleado(widget.args["id"], data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Empleado actualizado correctamente")),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error al actualizar: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    nombresController.dispose();
    apellidosController.dispose();
    dniController.dispose();
    nacimientoController.dispose();
    phoneController.dispose();
    direccionController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WidgetAppBar(title: "EDITAR EMPLEADO"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Información Personal",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            WidgetField(controller: nombresController, labelText: "Nombres"),
            WidgetField(
              controller: apellidosController,
              labelText: "Apellidos",
            ),
            WidgetField(controller: dniController, labelText: "DNI"),
            WidgetFieldDatePicker(
              controller: nacimientoController,
              label: "Fecha de nacimiento",
              initialDate: DateTime(2000),
            ),
            WidgetField(controller: phoneController, labelText: "Teléfono"),
            WidgetField(
              controller: direccionController,
              labelText: "Dirección",
            ),

            const SizedBox(height: 25),

            const Text(
              "Datos Laborales",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            WidgetField(controller: emailController, labelText: "Email"),

            WidgetDropdown(
              label: "Tipo de empleado",
              value: selectedTipoEmpleado,
              items: tiposEmpleado
                  .map<String>((e) => e["tipo_empleado"].toString())
                  .toList(),
              onChanged: (value) {
                setState(() => selectedTipoEmpleado = value);
              },
            ),

            WidgetDropdown(
              label: "Especialidad",
              value: selectedEspecialidad,
              items: especialidades
                  .map<String>((e) => e["especialidad"].toString())
                  .toList(),
              onChanged: (value) {
                setState(() => selectedEspecialidad = value);
              },
            ),

            const SizedBox(height: 30),

            WidgetButton(
              isLoading: _isLoading,
              text: "Actualizar empleado",
              onPressed: _updateEmpleado,
            ),
          ],
        ),
      ),
    );
  }
}
