import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/presentation/utils/fomatters/phone_number_formatter.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/entities/usuarios/services/users_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_field.dart';
import 'package:sanku_pro/presentation/widgets/widget_picker.dart';

class UsuariosAddPage extends StatefulWidget {
  const UsuariosAddPage({super.key});

  @override
  State<UsuariosAddPage> createState() => _UsuariosAddPageState();
}

class _UsuariosAddPageState extends State<UsuariosAddPage> {
  // Información personal
  final nombresController = TextEditingController();
  final apellidosController = TextEditingController();
  final dniController = TextEditingController();
  final nacimientoController = TextEditingController();
  final phoneController = TextEditingController();
  final direccionController = TextEditingController();

  // Información de cuenta
  final emailController = TextEditingController();
  final claveController = TextEditingController();
  final usernameController = TextEditingController();
  final roleController = TextEditingController();

  bool _isLoading = false;

  Future<void> _saveUser() async {
    final nombres = nombresController.text.trim();
    final apellidos = apellidosController.text.trim();
    final email = emailController.text.trim();
    final clave = claveController.text.trim();

    if (nombres.isEmpty || apellidos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nombre y apellido son obligatorios")),
      );
      return;
    }

    if (email.isEmpty || clave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email y clave son obligatorios")),
      );
      return;
    }

    if (!isValidPeruPhone(phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El teléfono debe tener 9 dígitos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    /// 1️⃣ Crear documento vacío
    final ref = await db.collection('usuarios').add({});

    /// 2️⃣ Guardar cuenta
    await addUsuarioCuenta(ref.id, {
      "email": email,
      "clave": clave,
      "role": roleController.text.trim().isEmpty
          ? "user"
          : roleController.text.trim(),
      "username": usernameController.text.trim().isEmpty
          ? "$nombres $apellidos"
          : usernameController.text.trim(),
    });

    /// 3️⃣ Guardar datos personales + avatar generado automáticamente (API)
    await addUsuarioPersonal(ref.id, {
      "nombres": nombres,
      "apellidos": apellidos,
      "dni": dniController.text.trim(),
      "nacimiento": nacimientoController.text.trim(),
      "phone": phoneController.text.trim(),
      "direccion": direccionController.text.trim(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario agregado correctamente")),
      );
      context.pop();
    }

    setState(() => _isLoading = false);
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
    claveController.dispose();
    usernameController.dispose();
    roleController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetAppBar(title: 'Agregar usuario'),
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
            WidgetField(
              controller: phoneController,
              labelText: "Teléfono",
              inputFormatters: [PeruPhoneNumberFormatter()],
            ),

            WidgetField(
              controller: direccionController,
              labelText: "Dirección",
            ),

            const SizedBox(height: 25),
            const Text(
              "Información de Cuenta",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            WidgetField(controller: emailController, labelText: "Email"),
            WidgetField(
              controller: claveController,
              labelText: "Clave",
              isPassword: true,
            ),
            WidgetField(
              controller: usernameController,
              labelText: "Username (opcional)",
            ),
            WidgetField(
              controller: roleController,
              labelText: "Rol (default: user)",
            ),

            const SizedBox(height: 25),
            WidgetButton(
              isLoading: _isLoading,
              text: "Guardar usuario",
              onPressed: _isLoading ? null : _saveUser,
            ),
          ],
        ),
      ),
    );
  }
}
