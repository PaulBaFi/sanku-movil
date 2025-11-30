import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_strings.dart';
import 'package:sanku_pro/entities/empleados/services/empleados_firebase_service.dart';
import 'package:sanku_pro/entities/inscripciones/services/inscripciones_firebase_service.dart';
import 'package:sanku_pro/entities/clientes/services/clientes_firebase_service.dart';
import 'package:sanku_pro/entities/medios_pago/services/medios_pago_firebase_service.dart';
import 'package:sanku_pro/entities/paquetes/services/paquetes_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_field.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_dropdown.dart';
import 'package:sanku_pro/presentation/widgets/widget_picker.dart';

class InscripcionesEditPage extends StatefulWidget {
  final Map<String, dynamic> args;

  const InscripcionesEditPage({super.key, required this.args});

  @override
  State<InscripcionesEditPage> createState() => _InscripcionesEditPageState();
}

class _InscripcionesEditPageState extends State<InscripcionesEditPage> {
  // Controladores
  final fechaInicioController = TextEditingController();
  final fechaFinController = TextEditingController();
  final montoCanceladoController = TextEditingController();

  bool _isLoading = false;

  // Listas para dropdowns
  List<Map<String, dynamic>> clientes = [];
  List<Map<String, dynamic>> empleados = [];
  List<Map<String, dynamic>> mediosPago = [];
  List<Map<String, dynamic>> paquetes = [];

  // Variables para los nombres mostrados en dropdowns
  String? selectedClienteNombre;
  String? selectedEmpleadoNombre;
  String? selectedMedioPagoNombre;
  String? selectedPaqueteNombre;

  // IDs reales
  String? selectedClienteId;
  String? selectedEmpleadoId;
  String? selectedMedioPagoId;
  String? selectedPaqueteId;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Cargar datos básicos de la inscripción
    selectedClienteId = widget.args['clienteId'] as String?;
    selectedEmpleadoId = widget.args['empleadoId'] as String?;
    selectedPaqueteId = widget.args['paqueteId'] as String?;
    selectedMedioPagoId = widget.args['medioPagoId'] as String?;

    fechaInicioController.text = (widget.args['fechaInicio'] ?? '') as String;
    fechaFinController.text = (widget.args['fechaFin'] ?? '') as String;
    montoCanceladoController.text =
        (widget.args['montoCancelado']?.toString() ?? '');
  }

  Future<void> _loadDropdownData() async {
    clientes = (await getClientes()).cast<Map<String, dynamic>>();
    empleados = (await getEmpleados()).cast<Map<String, dynamic>>();
    mediosPago = (await getMediosPago()).cast<Map<String, dynamic>>();
    paquetes = (await getPaquetes()).cast<Map<String, dynamic>>();

    setState(() {
      // Establecer los nombres seleccionados basados en los IDs
      if (selectedClienteId != null) {
        final cliente = clientes.firstWhere(
          (c) => c['id'] == selectedClienteId,
          orElse: () => {},
        );
        if (cliente.isNotEmpty) {
          selectedClienteNombre =
              "${cliente['nombres']} ${cliente['apellidos']}";
        }
      }

      if (selectedEmpleadoId != null) {
        final empleado = empleados.firstWhere(
          (e) => e['id'] == selectedEmpleadoId,
          orElse: () => {},
        );
        if (empleado.isNotEmpty) {
          selectedEmpleadoNombre =
              "${empleado['nombres']} ${empleado['apellidos']}";
        }
      }

      if (selectedPaqueteId != null) {
        final paquete = paquetes.firstWhere(
          (p) => p['id'] == selectedPaqueteId,
          orElse: () => {},
        );
        if (paquete.isNotEmpty) {
          selectedPaqueteNombre = paquete['nombre_paquete'].toString();
        }
      }

      if (selectedMedioPagoId != null) {
        final medioPago = mediosPago.firstWhere(
          (m) => m['id'] == selectedMedioPagoId,
          orElse: () => {},
        );
        if (medioPago.isNotEmpty) {
          selectedMedioPagoNombre = medioPago['nombres'].toString();
        }
      }
    });
  }

  Future<void> _updateInscripcion() async {
    final fechaInicio = fechaInicioController.text.trim();
    final fechaFin = fechaFinController.text.trim();
    final montoCancelado = montoCanceladoController.text.trim();

    // Validaciones
    if (selectedClienteId == null ||
        selectedEmpleadoId == null ||
        selectedMedioPagoId == null ||
        selectedPaqueteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.errorCamposIncompletos),
        ),
      );
      return;
    }

    if (fechaInicio.isEmpty || fechaFin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fecha de inicio y fin son obligatorias")),
      );
      return;
    }

    if (montoCancelado.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El monto cancelado es obligatorio")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await updateInscripcion(widget.args['id'], {
        "clienteId": selectedClienteId!,
        "empleadoId": selectedEmpleadoId!,
        "paqueteId": selectedPaqueteId!,
        "fechaInicio": fechaInicio,
        "fechaFin": fechaFin,
        "medioPagoId": selectedMedioPagoId!,
        "montoCancelado": double.tryParse(montoCancelado) ?? 0.0,
      });

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text("Inscripción actualizada")),
        );
        navigator.pop();
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text("Error al actualizar: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    fechaInicioController.dispose();
    fechaFinController.dispose();
    montoCanceladoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WidgetAppBar(title: 'Editar Inscripción'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Datos de la Inscripción",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Dropdown de clientes
            WidgetDropdown(
              label: "Cliente",
              value: selectedClienteNombre,
              items: clientes
                  .map<String>(
                    (cliente) =>
                        "${cliente['nombres']} ${cliente['apellidos']}",
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedClienteNombre = value;
                  final index = clientes.indexWhere(
                    (cliente) =>
                        "${cliente['nombres']} ${cliente['apellidos']}" ==
                        value,
                  );
                  selectedClienteId =
                      index != -1 ? clientes[index]['id'] : null;
                });
              },
            ),

            WidgetDropdown(
              label: "Empleado",
              value: selectedEmpleadoNombre,
              items: empleados
                  .map<String>(
                    (empleado) =>
                        "${empleado['nombres']} ${empleado['apellidos']}",
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedEmpleadoNombre = value;
                  final index = empleados.indexWhere(
                    (empleado) =>
                        "${empleado['nombres']} ${empleado['apellidos']}" ==
                        value,
                  );
                  selectedEmpleadoId =
                      index != -1 ? empleados[index]['id'] : null;
                });
              },
            ),

            WidgetDropdown(
              label: "Paquete",
              value: selectedPaqueteNombre,
              items: paquetes
                  .map<String>((paquete) => paquete['nombre_paquete'].toString())
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedPaqueteNombre = value;
                  final index = paquetes.indexWhere(
                    (paquete) => paquete['nombre_paquete'].toString() == value,
                  );
                  selectedPaqueteId =
                      index != -1 ? paquetes[index]['id'] : null;
                });
              },
            ),

            WidgetDropdown(
              label: "Medio de pago",
              value: selectedMedioPagoNombre,
              items: mediosPago
                  .map<String>((medioPago) => medioPago['nombres'].toString())
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedMedioPagoNombre = value;
                  final index = mediosPago.indexWhere(
                    (medioPago) => medioPago['nombres'].toString() == value,
                  );
                  selectedMedioPagoId =
                      index != -1 ? mediosPago[index]['id'] : null;
                });
              },
            ),

            WidgetFieldDatePicker(
              controller: fechaInicioController,
              label: "Fecha de inicio",
            ),

            WidgetFieldDatePicker(
              controller: fechaFinController,
              label: "Fecha de fin",
            ),

            WidgetField(
              controller: montoCanceladoController,
              labelText: "Monto cancelado",
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 25),

            WidgetButton(
              isLoading: _isLoading,
              text: "Actualizar",
              onPressed: _isLoading ? null : _updateInscripcion,
            ),
          ],
        ),
      ),
    );
  }
}