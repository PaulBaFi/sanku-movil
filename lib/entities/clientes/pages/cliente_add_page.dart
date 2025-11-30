import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/presentation/utils/fomatters/phone_number_formatter.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/entities/clientes/services/clientes_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_field.dart';

class ClientesAddPage extends StatefulWidget {
  const ClientesAddPage({super.key});

  @override
  State<ClientesAddPage> createState() => _ClientesAddPageState();
}

class _ClientesAddPageState extends State<ClientesAddPage> {
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

  Future<void> _saveCliente() async {
    final nombres = nombresController.text.trim();
    final apellidos = apellidosController.text.trim();
    final contacto = contactoController.text.trim();

    if (nombres.isEmpty || apellidos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nombre y apellido son obligatorios")),
      );
      return;
    }

    if (contacto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El contacto es obligatorio")),
      );
      return;
    }

    if (!isValidPeruPhone(contacto)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El contacto debe tener 9 dígitos')),
      );
      return;
    }

    final contactoEmergencia = contactoEmergenciaController.text.trim();
    if (contactoEmergencia.isNotEmpty &&
        !isValidPeruPhone(contactoEmergencia)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El contacto de emergencia debe tener 9 dígitos'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await addCliente({
        "nombres": nombres,
        "apellidos": apellidos,
        "dni": dniController.text.trim(),
        "direccion": direccionController.text.trim(),
        "email": emailController.text.trim(),
        "contacto": contacto,
        "contactoEmergencia": contactoEmergencia,
        "estado": estadoController.text.trim().isEmpty
            ? "activo"
            : estadoController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cliente agregado correctamente")),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error al agregar cliente: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
    return Scaffold(
      appBar: WidgetAppBar(title: 'Agregar cliente'),
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

            const SizedBox(height: 25),
            const Text(
              "Información Adicional",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            WidgetField(
              controller: direccionController,
              labelText: "Dirección",
            ),
            WidgetField(
              controller: contactoController,
              labelText: "Contacto principal",
              inputFormatters: [PeruPhoneNumberFormatter()],
            ),
            WidgetField(
              controller: contactoEmergenciaController,
              labelText: "Contacto de emergencia (opcional)",
              inputFormatters: [PeruPhoneNumberFormatter()],
            ),
            WidgetField(
              controller: emailController,
              labelText: "Email (opcional)",
            ),

            const SizedBox(height: 25),
            WidgetButton(
              isLoading: _isLoading,
              text: "Guardar cliente",
              onPressed: _isLoading ? null : _saveCliente,
            ),
          ],
        ),
      ),
    );
  }
}
