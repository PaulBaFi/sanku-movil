import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_strings.dart';
import 'package:sanku_pro/entities/clientes/services/clientes_firebase_service.dart';
import 'package:sanku_pro/presentation/utils/fomatters/phone_number_formatter.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_field.dart';

class ClientesEditPage extends StatefulWidget {
  final Map<String, dynamic> args;

  const ClientesEditPage({super.key, required this.args});

  @override
  State<ClientesEditPage> createState() => _ClientesEditPageState();
}

class _ClientesEditPageState extends State<ClientesEditPage> {
  // Información del cliente
  final nombresController = TextEditingController();
  final apellidosController = TextEditingController();
  final dniController = TextEditingController();
  final direccionController = TextEditingController();
  final emailController = TextEditingController();
  final contactoController = TextEditingController();
  final contactoEmergenciaController = TextEditingController();
  final estadoController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Asignación inicial de valores (desde args)
    nombresController.text = (widget.args['nombres'] ?? '') as String;
    apellidosController.text = (widget.args['apellidos'] ?? '') as String;
    dniController.text = (widget.args['dni'] ?? '') as String;
    direccionController.text = (widget.args['direccion'] ?? '') as String;
    emailController.text = (widget.args['email'] ?? '') as String;
    contactoController.text = (widget.args['contacto'] ?? '') as String;
    contactoEmergenciaController.text =
        (widget.args['contactoEmergencia'] ?? '') as String;
    estadoController.text = (widget.args['estado'] ?? '') as String;
  }

  @override
  void dispose() {
    nombresController.dispose();
    apellidosController.dispose();
    dniController.dispose();
    direccionController.dispose();
    emailController.dispose();
    contactoController.dispose();
    contactoEmergenciaController.dispose();
    estadoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = widget.args;

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Editar cliente")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Información del Cliente",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            WidgetField(controller: nombresController, labelText: "Nombres"),
            WidgetField(
              controller: apellidosController,
              labelText: "Apellidos",
            ),
            WidgetField(controller: dniController, labelText: "DNI"),
            WidgetField(
              controller: direccionController,
              labelText: "Dirección",
            ),
            WidgetField(
              controller: emailController,
              labelText: "Email (opcional)",
            ),

            const SizedBox(height: 10),

            WidgetField(
              controller: contactoController,
              labelText: "Contacto",
              inputFormatters: [PeruPhoneNumberFormatter()],
            ),
            WidgetField(
              controller: contactoEmergenciaController,
              labelText: "Contacto de emergencia (opcional)",
              inputFormatters: [PeruPhoneNumberFormatter()],
            ),

            const SizedBox(height: 25),

            WidgetButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      final newNombres = nombresController.text.trim();
                      final newApellidos = apellidosController.text.trim();
                      final newDni = dniController.text.trim();
                      final newDireccion = direccionController.text.trim();
                      final newEmail = emailController.text.trim();
                      final newContacto = contactoController.text.trim();
                      final newContactoEmergencia = contactoEmergenciaController
                          .text
                          .trim();
                      final newEstado = estadoController.text.trim();

                      // Validación mínima
                      if (newNombres.isEmpty || newApellidos.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppStrings.errorCamposIncompletos),
                          ),
                        );
                        return;
                      }

                      if (newContacto.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('El contacto es obligatorio'),
                          ),
                        );
                        return;
                      }

                      if (!isValidPeruPhone(newContacto)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('El contacto debe tener 9 dígitos'),
                          ),
                        );
                        return;
                      }

                      if (newContactoEmergencia.isNotEmpty &&
                          !isValidPeruPhone(newContactoEmergencia)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'El contacto de emergencia debe tener 9 dígitos',
                            ),
                          ),
                        );
                        return;
                      }

                      setState(() => _isLoading = true);

                      try {
                        final clienteData = {
                          "nombres": newNombres,
                          "apellidos": newApellidos,
                          "dni": newDni,
                          "direccion": newDireccion,
                          "email": newEmail,
                          "contacto": newContacto,
                          "contactoEmergencia": newContactoEmergencia,
                          "estado": newEstado.isEmpty ? "activo" : newEstado,
                        };

                        await updateCliente(arguments["id"], clienteData);

                        if (mounted) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Cliente actualizado'),
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
