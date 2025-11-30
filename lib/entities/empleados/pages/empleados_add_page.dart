import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/core/constants/app_strings.dart';
import 'package:sanku_pro/entities/empleados/services/empleados_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_dropdown.dart';
import 'package:sanku_pro/presentation/widgets/widget_field.dart';
import 'package:sanku_pro/presentation/widgets/widget_picker.dart';

class EmpleadosAddPage extends StatefulWidget {
  const EmpleadosAddPage({super.key});

  @override
  State<EmpleadosAddPage> createState() => _EmpleadosAddPageState();
}

class _EmpleadosAddPageState extends State<EmpleadosAddPage> {
  final nombresController = TextEditingController();
  final apellidosController = TextEditingController();
  final emailController = TextEditingController();
  final dniController = TextEditingController();
  final nacimientoController = TextEditingController();
  final phoneController = TextEditingController();
  final direccionController = TextEditingController();
  final avatarUrlController = TextEditingController();

  String? selectedTipoEmpleado;
  String? selectedEspecialidad;

  bool _isLoading = false;

  List<Map<String, dynamic>> tiposEmpleado = [];
  List<Map<String, dynamic>> especialidades = [];

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    tiposEmpleado = await getTiposEmpleadoDesdeEmpleado();
    especialidades = await getEspecialidadesDesdeEmpleado();

    setState(() {});
  }

  Future<void> _saveEmpleado() async {
    final nombres = nombresController.text.trim();
    final apellidos = apellidosController.text.trim();
    final email = emailController.text.trim();
    final dni = dniController.text.trim();
    final nacimiento = nacimientoController.text.trim();
    final phone = phoneController.text.trim();
    final direccion = direccionController.text.trim();
    final avatarUrl = avatarUrlController.text.trim();

    if (nombres.isEmpty ||
        apellidos.isEmpty ||
        email.isEmpty ||
        dni.isEmpty ||
        phone.isEmpty ||
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
      "email": email,
      "dni": dni,
      "nacimiento": nacimiento,
      "phone": phone,
      "direccion": direccion,
      "avatarUrl": avatarUrl.isEmpty ? null : avatarUrl,
      "tipo_empleado": selectedTipoEmpleado,
      "especialidad": selectedEspecialidad,
    };

    final ref = await db.collection('empleados').add({});

    await addEmpleado(ref.id, data);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Empleado agregado correctamente")),
      );
      context.pop();
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    nombresController.dispose();
    apellidosController.dispose();
    emailController.dispose();
    dniController.dispose();
    nacimientoController.dispose();
    phoneController.dispose();
    direccionController.dispose();
    avatarUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WidgetAppBar(title: 'AGREGAR EMPLEADO'),
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
            WidgetField(controller: emailController, labelText: "Email"),
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

            WidgetField(
              controller: avatarUrlController,
              labelText: "Avatar URL (opcional)",
            ),

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
              text: "Guardar empleado",
              onPressed: _saveEmpleado,
            ),
          ],
        ),
      ),
    );
  }
}
