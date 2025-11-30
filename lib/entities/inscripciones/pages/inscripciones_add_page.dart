// ============================================================
// 1. INSCRIPCIONES_ADD_PAGE.DART - ADAPTADO
// ============================================================
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/constants/app_strings.dart';
import 'package:sanku_pro/core/constants/app_text_styles.dart';
import 'package:sanku_pro/core/routes/app_routes_index.dart';
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

class InscripcionesAddPage extends StatefulWidget {
  const InscripcionesAddPage({super.key});

  @override
  State<InscripcionesAddPage> createState() => _InscripcionesAddPageState();
}

class _InscripcionesAddPageState extends State<InscripcionesAddPage> {
  // Controladores
  final fechaInicioController = TextEditingController();
  final fechaFinController = TextEditingController();
  final montoCanceladoController = TextEditingController();

  bool _isLoading = false;
  bool _generarQR = true; // NUEVO: Opción para generar QR

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

  // NUEVO: Precio del paquete seleccionado
  double? precioPaqueteSeleccionado;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    clientes = (await getClientes()).cast<Map<String, dynamic>>();
    empleados = (await getEmpleados()).cast<Map<String, dynamic>>();
    mediosPago = (await getMediosPago()).cast<Map<String, dynamic>>();
    paquetes = (await getPaquetes()).cast<Map<String, dynamic>>();

    setState(() {});
  }

  Future<void> _saveInscripcion() async {
    final fechaInicio = fechaInicioController.text.trim();
    final fechaFin = fechaFinController.text.trim();
    final montoCancelado = montoCanceladoController.text.trim();

    // Validaciones
    if (selectedClienteId == null ||
        selectedEmpleadoId == null ||
        selectedMedioPagoId == null ||
        selectedPaqueteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorCamposIncompletos)),
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

    try {
      // CAMBIO PRINCIPAL: Usar addInscripcion con los nuevos parámetros
      await addInscripcion(
        {
          "clienteId": selectedClienteId!,
          "empleadoId": selectedEmpleadoId!,
          "paqueteId": selectedPaqueteId!,
          "fechaInicio": fechaInicio,
          "fechaFin": fechaFin,
          "medioPagoId": selectedMedioPagoId!,
          "montoCancelado": double.tryParse(montoCancelado) ?? 0.0,
        },
        generarQR: _generarQR, // Generar QR automáticamente
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _generarQR
                  ? "Inscripción y pago con QR creados correctamente"
                  : "Inscripción agregada correctamente",
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al agregar inscripción: $e"),
            backgroundColor: Colors.red,
          ),
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
      appBar: const WidgetAppBar(title: 'Nueva Inscripción'),
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
                  selectedClienteId = index != -1
                      ? clientes[index]['id']
                      : null;
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
                  selectedEmpleadoId = index != -1
                      ? empleados[index]['id']
                      : null;
                });
              },
            ),

            WidgetDropdown(
              label: "Paquete",
              value: selectedPaqueteNombre,
              items: paquetes
                  .map<String>(
                    (paquete) => paquete['nombre_paquete'].toString(),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedPaqueteNombre = value;
                  final index = paquetes.indexWhere(
                    (paquete) => paquete['nombre_paquete'].toString() == value,
                  );
                  if (index != -1) {
                    selectedPaqueteId = paquetes[index]['id'];
                    // NUEVO: Guardar el precio del paquete seleccionado
                    precioPaqueteSeleccionado =
                        paquetes[index]['precio'] ?? 0.0;
                  } else {
                    selectedPaqueteId = null;
                    precioPaqueteSeleccionado = null;
                  }
                });
              },
            ),

            // NUEVO: Mostrar precio del paquete seleccionado
            if (precioPaqueteSeleccionado != null)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Precio del paquete: S/ ${precioPaqueteSeleccionado!.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            WidgetDropdown(
              label: "Medio de pago",
              value: selectedMedioPagoNombre,
              items: mediosPago
                  .map<String>((medioPago) => medioPago['nombre'].toString())
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedMedioPagoNombre = value;
                  final index = mediosPago.indexWhere(
                    (medioPago) => medioPago['nombre'].toString() == value,
                  );
                  selectedMedioPagoId = index != -1
                      ? mediosPago[index]['id']
                      : null;
                });
              },
            ),

            WidgetFieldDatePicker(
              controller: fechaInicioController,
              initialDate: DateTime.now(),
              label: "Fecha de inicio",
            ),

            WidgetFieldDatePicker(
              controller: fechaFinController,
              initialDate: DateTime.now(),
              label: "Fecha de fin",
            ),

            WidgetField(
              controller: montoCanceladoController,
              labelText: "Monto cancelado (pago inicial)",
              keyboardType: TextInputType.number,
              hintText: "0.00",
            ),

            const SizedBox(height: 16),

            // NUEVO: Opción para generar QR
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CheckboxListTile(
                value: _generarQR,
                onChanged: (value) {
                  setState(() => _generarQR = value ?? true);
                },
                title: const Text('Generar código QR del pago'),
                subtitle: const Text('Crea un comprobante digital con QR'),
                secondary: const Icon(Icons.qr_code),
              ),
            ),

            const SizedBox(height: 25),

            WidgetButton(
              isLoading: _isLoading,
              text: "Guardar inscripción",
              onPressed: _isLoading ? null : _saveInscripcion,
            ),

            const SizedBox(height: 25),

            Row(
              children: [
                Text(
                  'Si el cliente aún no existe, debes ',
                  style: AppTextStyles.textTheme.labelLarge,
                ),
                TextButton(
                  onPressed: () async {
                    await context.push(AppRoutes.clienteAdd);
                    await _loadDropdownData(); // Recargar clientes
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    "Crear un cliente.",
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/constants/app_strings.dart';
import 'package:sanku_pro/core/constants/app_text_styles.dart';
import 'package:sanku_pro/core/routes/app_routes_index.dart';
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

class InscripcionesAddPage extends StatefulWidget {
  const InscripcionesAddPage({super.key});

  @override
  State<InscripcionesAddPage> createState() => _InscripcionesAddPageState();
}

class _InscripcionesAddPageState extends State<InscripcionesAddPage> {
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
  }

  Future<void> _loadDropdownData() async {
    clientes = (await getClientes()).cast<Map<String, dynamic>>();
    empleados = (await getEmpleados()).cast<Map<String, dynamic>>();
    mediosPago = (await getMediosPago()).cast<Map<String, dynamic>>();
    paquetes = (await getPaquetes()).cast<Map<String, dynamic>>();

    setState(() {});
  }

  Future<void> _saveInscripcion() async {
    final fechaInicio = fechaInicioController.text.trim();
    final fechaFin = fechaFinController.text.trim();
    final montoCancelado = montoCanceladoController.text.trim();

    // Validaciones
    if (selectedClienteId == null ||
        selectedEmpleadoId == null ||
        selectedMedioPagoId == null ||
        selectedPaqueteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorCamposIncompletos)),
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

    try {
      await addInscripcion({
        "clienteId": selectedClienteId!,
        "empleadoId": selectedEmpleadoId!,
        "paqueteId": selectedPaqueteId!,
        "fechaInicio": fechaInicio,
        "fechaFin": fechaFin,
        "medioPagoId": selectedMedioPagoId!,
        "montoCancelado": double.tryParse(montoCancelado) ?? 0.0,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Inscripción agregada correctamente")),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al agregar inscripción: $e")),
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
      appBar: const WidgetAppBar(title: 'Nueva Inscripción'),
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
                  selectedClienteId = index != -1
                      ? clientes[index]['id']
                      : null;
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
                  selectedEmpleadoId = index != -1
                      ? empleados[index]['id']
                      : null;
                });
              },
            ),

            WidgetDropdown(
              label: "Paquete",
              value: selectedPaqueteNombre,
              items: paquetes
                  .map<String>(
                    (paquete) => paquete['nombre_paquete'].toString(),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedPaqueteNombre = value;
                  final index = paquetes.indexWhere(
                    (paquete) => paquete['nombre_paquete'].toString() == value,
                  );
                  selectedPaqueteId = index != -1
                      ? paquetes[index]['id']
                      : null;
                });
              },
            ),

            WidgetDropdown(
              label: "Medio de pago",
              value: selectedMedioPagoNombre,
              items: mediosPago
                  .map<String>((medioPago) => medioPago['nombre'].toString())
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedMedioPagoNombre = value;
                  final index = mediosPago.indexWhere(
                    (medioPago) => medioPago['nombre'].toString() == value,
                  );
                  selectedMedioPagoId = index != -1
                      ? mediosPago[index]['id']
                      : null;
                });
              },
            ),

            WidgetFieldDatePicker(
              controller: fechaInicioController,
              initialDate: DateTime.now(),
              label: "Fecha de inicio",
            ),

            WidgetFieldDatePicker(
              controller: fechaFinController,
              initialDate: DateTime.now(),
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
              text: "Guardar inscripción",
              onPressed: _isLoading ? null : _saveInscripcion,
            ),

            const SizedBox(height: 25),

            Row(
              children: [
                Text(
                  'Si el cliente aún no existe, debes ',
                  style: AppTextStyles.textTheme.labelLarge,
                ),
                TextButton(
                  onPressed: () async {
                    await context.push(AppRoutes.clienteAdd);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    "Crear un cliente.",
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
*/
