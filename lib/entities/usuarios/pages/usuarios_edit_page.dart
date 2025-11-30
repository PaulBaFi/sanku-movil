import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_strings.dart';
import 'package:sanku_pro/entities/usuarios/services/users_firebase_service.dart';
import 'package:sanku_pro/presentation/utils/fomatters/phone_number_formatter.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_field.dart';
import 'package:sanku_pro/presentation/widgets/widget_picker.dart';

class UsuariosEditPage extends StatefulWidget {
  final Map<String, dynamic> args;

  const UsuariosEditPage({super.key, required this.args});

  @override
  State<UsuariosEditPage> createState() => _UsuariosEditPageState();
}

class _UsuariosEditPageState extends State<UsuariosEditPage> {
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

  @override
  void initState() {
    super.initState();

    // Asignación inicial de valores (desde args)
    nombresController.text = (widget.args['nombres'] ?? '') as String;
    apellidosController.text = (widget.args['apellidos'] ?? '') as String;
    dniController.text = (widget.args['dni'] ?? '') as String;
    nacimientoController.text = (widget.args['nacimiento'] ?? '') as String;
    phoneController.text = (widget.args['phone'] ?? '') as String;
    direccionController.text = (widget.args['direccion'] ?? '') as String;

    emailController.text = (widget.args['email'] ?? '') as String;
    claveController.text = (widget.args['clave'] ?? '') as String;
    usernameController.text = (widget.args['username'] ?? '') as String;
    roleController.text = (widget.args['role'] ?? '') as String;
  }

  @override
  Widget build(BuildContext context) {
    final arguments = widget.args;

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Editar usuario")),
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
              onPressed: _isLoading
                  ? null
                  : () async {
                      final newEmail = emailController.text.trim();
                      final newClave = claveController.text.trim();
                      final newUsername = usernameController.text.trim();
                      final newRole = roleController.text.trim();

                      final newNombres = nombresController.text.trim();
                      final newApellidos = apellidosController.text.trim();
                      final newDni = dniController.text.trim();
                      final newNacimiento = nacimientoController.text.trim();
                      final newTelefono = phoneController.text.trim();
                      final newDireccion = direccionController.text.trim();

                      // Validación mínima
                      if (newEmail.isEmpty ||
                          newClave.isEmpty ||
                          newNombres.isEmpty ||
                          newApellidos.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppStrings.errorCamposIncompletos),
                          ),
                        );
                        return;
                      }

                      setState(() => _isLoading = true);

                      try {
                        /// ACTUALIZAR CUENTA
                        final cuentaData = {
                          "email": newEmail,
                          "clave": newClave,
                          "role": newRole,
                          "username": newUsername,
                        };
                        await updateUsuarioCuenta(arguments["id"], cuentaData);

                        /// ACTUALIZAR INFORMACIÓN PERSONAL
                        final personalData = {
                          "nombres": newNombres,
                          "apellidos": newApellidos,
                          "dni": newDni,
                          "nacimiento": newNacimiento,
                          "phone": newTelefono,
                          "direccion": newDireccion,
                        };
                        await updateUsuarioPersonal(
                          arguments["id"],
                          personalData,
                        );

                        if (mounted) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Registro actualizado'),
                            ),
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
