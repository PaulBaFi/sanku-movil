// ============================================================
// INSCRIPCIONES_DETALLE_PAGE.DART - CON RESUMEN FINANCIERO
// ============================================================
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';
import 'package:sanku_pro/core/routes/app_routes.dart';
import 'package:sanku_pro/entities/inscripciones/services/inscripciones_firebase_service.dart';
import 'package:sanku_pro/presentation/components/add_pagos_dialog.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_details_layout.dart';

class InscripcionesDetallePage extends StatefulWidget {
  final Map<String, dynamic> args;

  const InscripcionesDetallePage({super.key, required this.args});

  @override
  State<InscripcionesDetallePage> createState() =>
      _InscripcionesDetallePageState();
}

class _InscripcionesDetallePageState extends State<InscripcionesDetallePage> {
  late Map<String, dynamic> inscripcion;
  Map<String, dynamic>? resumenFinanciero;
  bool _isLoadingResumen = true;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: 'S/ ',
    decimalDigits: 2,
  );
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    inscripcion = widget.args;
    _loadResumenFinanciero();
  }

  Future<void> _loadResumenFinanciero() async {
    setState(() => _isLoadingResumen = true);
    try {
      final resumen = await getResumenFinanciero(inscripcion["id"]);
      setState(() {
        resumenFinanciero = resumen;
        _isLoadingResumen = false;
      });
    } catch (e) {
      setState(() => _isLoadingResumen = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar resumen: $e')));
      }
    }
  }

  Future<void> _refresh() async {
    final id = inscripcion["id"];
    final updated = await getInscripcionCompleta(id);
    if (updated != null) {
      setState(() {
        inscripcion = updated;
      });
    }
    await _loadResumenFinanciero();
  }

  Future<void> _mostrarDialogoAgregarPago() async {
    if (resumenFinanciero == null) return;

    final saldoPendiente = resumenFinanciero!['saldo_pendiente'] as double;

    if (saldoPendiente <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La inscripción ya está pagada completamente'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    final resultado = await mostrarDialogoAgregarPago(
      context,
      inscripcionId: inscripcion["id"],
      inscripcion: inscripcion,
      saldoPendiente: saldoPendiente,
    );

    if (resultado == true) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Datos de la inscripción
    final fechaInicio = inscripcion['fechaInicio'] ?? '';
    final fechaFin = inscripcion['fechaFin'] ?? '';

    // Datos relacionados
    final cliente = inscripcion['cliente'] as Map<String, dynamic>?;
    final empleado = inscripcion['empleado'] as Map<String, dynamic>?;
    final paquete = inscripcion['paquete'] as Map<String, dynamic>?;
    final medioPago = inscripcion['medioPago'] as Map<String, dynamic>?;
    final pagos = inscripcion['pagos'] as List<dynamic>? ?? [];

    // Extraer información del cliente
    final clienteNombre = cliente != null
        ? "${cliente['nombres'] ?? ''} ${cliente['apellidos'] ?? ''}".trim()
        : 'No disponible';
    final clienteEmail = cliente?['email'] ?? '';
    final clienteContacto = cliente?['contacto'] ?? '';
    final clienteAvatarUrl = cliente?['avatarUrl'] ?? '';

    // Extraer información del empleado
    final empleadoNombre = empleado != null
        ? "${empleado['nombres'] ?? ''} ${empleado['apellidos'] ?? ''}".trim()
        : 'No disponible';
    final empleadoEmail = empleado?['email'] ?? '';

    // Extraer información del paquete
    final paqueteNombre = paquete?['nombre_paquete'] ?? 'No disponible';
    final paquetePrecio = paquete?['precio'] ?? 0.0;
    final paqueteSesiones = paquete?['numero_sesiones']?.toString() ?? '';

    // Extraer información del medio de pago
    final medioPagoNombre = medioPago?['nombre'] ?? 'No disponible';

    return Scaffold(
      appBar: AppBar(title: const Text("Detalle de Inscripción")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: WidgetDetailsLayout(
          child: Column(
            children: [
              // Avatar del cliente
              CircleAvatar(
                radius: 48,
                backgroundImage: clienteAvatarUrl.isNotEmpty
                    ? NetworkImage(clienteAvatarUrl)
                    : null,
                child: clienteAvatarUrl.isEmpty
                    ? const Icon(Icons.person, size: 48)
                    : null,
              ),
              const SizedBox(height: 16),

              Text(
                clienteNombre,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: AppDimensions.marginS),
              const Divider(thickness: 0.7),
              const SizedBox(height: AppDimensions.marginM),

              // ========== SECCIÓN RESUMEN FINANCIERO ==========
              _sectionTitle("Resumen Financiero"),

              if (_isLoadingResumen)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (resumenFinanciero != null) ...[
                _buildResumenFinanciero(),

                const SizedBox(height: 16),

                // Botón para agregar pago
                if ((resumenFinanciero!['saldo_pendiente'] as double) > 0)
                  ElevatedButton.icon(
                    onPressed: _mostrarDialogoAgregarPago,
                    icon: const Icon(Icons.add_card),
                    label: const Text('Agregar Pago'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
              ],

              const SizedBox(height: AppDimensions.marginS),
              const Divider(thickness: 0.7),
              const SizedBox(height: AppDimensions.marginM),

              // ========== HISTORIAL DE PAGOS ==========
              if (pagos.isNotEmpty) ...[
                _sectionTitle("Historial de Pagos (${pagos.length})"),
                const SizedBox(height: 12),
                ...pagos.map((pago) => _buildPagoCard(pago)),
                const SizedBox(height: AppDimensions.marginS),
                const Divider(thickness: 0.7),
                const SizedBox(height: AppDimensions.marginM),
              ],

              // SECCIÓN DATOS DEL CLIENTE
              _sectionTitle("Datos del Cliente"),
              _infoTile("Nombre", clienteNombre),
              _infoTile("Email", clienteEmail),
              _infoTile("Contacto", clienteContacto),

              const SizedBox(height: AppDimensions.marginS),
              const Divider(thickness: 0.7),
              const SizedBox(height: AppDimensions.marginM),

              // SECCIÓN DATOS DEL PAQUETE
              _sectionTitle("Información del Paquete"),
              _infoTile("Paquete", paqueteNombre),
              _infoTile(
                "Precio del paquete",
                _currencyFormat.format(paquetePrecio),
              ),
              _infoTile("Número de sesiones", paqueteSesiones),

              const SizedBox(height: AppDimensions.marginS),
              const Divider(thickness: 0.7),
              const SizedBox(height: AppDimensions.marginM),

              // SECCIÓN DATOS DE LA INSCRIPCIÓN
              _sectionTitle("Datos de la Inscripción"),
              _infoTile("Fecha de inicio", fechaInicio),
              _infoTile("Fecha de fin", fechaFin),
              _infoTile("Medio de pago inicial", medioPagoNombre),

              const SizedBox(height: AppDimensions.marginS),
              const Divider(thickness: 0.7),
              const SizedBox(height: AppDimensions.marginM),

              // SECCIÓN EMPLEADO ASIGNADO
              _sectionTitle("Empleado Asignado"),
              _infoTile("Nombre", empleadoNombre),
              _infoTile("Email", empleadoEmail),

              const SizedBox(height: AppDimensions.marginS),
              const Divider(thickness: 0.7),
              const SizedBox(height: AppDimensions.marginM),

              WidgetButton(
                text: 'Editar inscripción',
                onPressed: () async {
                  await context.push(
                    AppRoutes.inscripcionesEdit,
                    extra: inscripcion,
                  );
                  await _refresh();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResumenFinanciero() {
    final precioPaquete = resumenFinanciero!['precio_paquete'] as double;
    final totalPagado = resumenFinanciero!['total_pagado'] as double;
    final saldoPendiente = resumenFinanciero!['saldo_pendiente'] as double;
    final porcentajePagado = resumenFinanciero!['porcentaje_pagado'] as double;
    final estaPagadoCompleto =
        resumenFinanciero!['esta_pagado_completo'] as bool;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: estaPagadoCompleto
            ? Colors.green.shade50
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: estaPagadoCompleto
              ? Colors.green.shade200
              : Colors.orange.shade200,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Estado de pago
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                estaPagadoCompleto ? Icons.check_circle : Icons.pending,
                color: estaPagadoCompleto ? Colors.green : Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                estaPagadoCompleto ? 'PAGADO COMPLETO' : 'PAGO PENDIENTE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: estaPagadoCompleto
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Detalles financieros
          _financialRow('Precio del Paquete', precioPaquete, Colors.blue),
          const SizedBox(height: 8),
          _financialRow('Total Pagado', totalPagado, Colors.green),
          const SizedBox(height: 8),
          _financialRow('Saldo Pendiente', saldoPendiente, Colors.red),

          const SizedBox(height: 16),

          // Barra de progreso
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progreso de Pago: ${porcentajePagado.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: porcentajePagado / 100,
                  minHeight: 12,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    estaPagadoCompleto ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _financialRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          _currencyFormat.format(amount),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPagoCard(Map<String, dynamic> pago) {
    final monto = pago['monto'] ?? 0.0;
    final estado = pago['estado'] ?? 'completado';
    final metodoPago = pago['metodo_pago'] as Map<String, dynamic>?;
    final metodoPagoNombre = metodoPago?['nombre'] ?? 'Sin especificar';
    final fechaPago = pago['fecha_pago'];
    final qrCodeUrl = pago['qr_code_url'];

    String fechaFormateada = 'Sin fecha';
    if (fechaPago != null) {
      try {
        final timestamp = fechaPago as dynamic;
        final date = timestamp.toDate();
        fechaFormateada = _dateFormat.format(date);
      } catch (e) {
        fechaFormateada = fechaPago.toString();
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getEstadoColor(estado).withAlpha(50),
          child: Icon(
            _getIconoMetodoPago(metodoPagoNombre),
            color: _getEstadoColor(estado),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                _currencyFormat.format(monto),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (qrCodeUrl != null)
              Icon(Icons.qr_code, size: 16, color: Colors.blue.shade600),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Método: $metodoPagoNombre'),
            Text('Fecha: $fechaFormateada'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getEstadoColor(estado).withAlpha(25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getEstadoColor(estado)),
          ),
          child: Text(
            estado.toUpperCase(),
            style: TextStyle(
              color: _getEstadoColor(estado),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'completado':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconoMetodoPago(String nombre) {
    final nombreLower = nombre.toLowerCase();
    if (nombreLower.contains('efectivo')) return Icons.money;
    if (nombreLower.contains('tarjeta')) return Icons.credit_card;
    if (nombreLower.contains('transferencia')) return Icons.account_balance;
    if (nombreLower.contains('yape') || nombreLower.contains('plin')) {
      return Icons.phone_android;
    }
    return Icons.payment;
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
          Flexible(
            child: Text(
              value.isEmpty ? "—" : value,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// FUNCIÓN AUXILIAR PARA MOSTRAR EL DIÁLOGO (importar desde el archivo del diálogo)
Future<bool?> mostrarDialogoAgregarPago(
  BuildContext context, {
  required String inscripcionId,
  required Map<String, dynamic> inscripcion,
  required double saldoPendiente,
}) {
  // Esta función debe importarse desde el archivo donde creamos AgregarPagoDialog
  // import 'package:sanku_pro/presentation/dialogs/agregar_pago_dialog.dart';
  return showDialog<bool>(
    context: context,
    builder: (context) => AgregarPagoDialog(
      inscripcionId: inscripcionId,
      inscripcion: inscripcion,
      saldoPendiente: saldoPendiente,
    ),
  );
}

/*
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';
import 'package:sanku_pro/core/routes/app_routes.dart';
import 'package:sanku_pro/entities/inscripciones/services/inscripciones_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_details_layout.dart';

class InscripcionesDetallePage extends StatefulWidget {
  final Map<String, dynamic> args;

  const InscripcionesDetallePage({super.key, required this.args});

  @override
  State<InscripcionesDetallePage> createState() =>
      _InscripcionesDetallePageState();
}

class _InscripcionesDetallePageState extends State<InscripcionesDetallePage> {
  late Map<String, dynamic> inscripcion;

  @override
  void initState() {
    super.initState();
    inscripcion = widget.args;
  }

  Future<void> _refresh() async {
    final id = inscripcion["id"];
    final updated = await getInscripcionCompleta(id);
    if (updated != null) {
      setState(() {
        inscripcion = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Datos de la inscripción
    final fechaInicio = inscripcion['fechaInicio'] ?? '';
    final fechaFin = inscripcion['fechaFin'] ?? '';
    final montoCancelado = inscripcion['montoCancelado']?.toString() ?? '0';

    // Datos relacionados
    final cliente = inscripcion['cliente'] as Map<String, dynamic>?;
    final empleado = inscripcion['empleado'] as Map<String, dynamic>?;
    final paquete = inscripcion['paquete'] as Map<String, dynamic>?;
    final medioPago = inscripcion['medioPago'] as Map<String, dynamic>?;

    // Extraer información del cliente
    final clienteNombre = cliente != null
        ? "${cliente['nombres'] ?? ''} ${cliente['apellidos'] ?? ''}".trim()
        : 'No disponible';
    final clienteEmail = cliente?['email'] ?? '';
    final clienteContacto = cliente?['contacto'] ?? '';
    final clienteAvatarUrl = cliente?['avatarUrl'] ?? '';

    // Extraer información del empleado
    final empleadoNombre = empleado != null
        ? "${empleado['nombres'] ?? ''} ${empleado['apellidos'] ?? ''}".trim()
        : 'No disponible';
    final empleadoEmail = empleado?['email'] ?? '';

    // Extraer información del paquete
    final paqueteNombre = paquete?['nombre_paquete'] ?? 'No disponible';
    final paquetePrecio = paquete?['precio']?.toString() ?? '';
    final paqueteSesiones = paquete?['numero_sesiones']?.toString() ?? '';

    // Extraer información del medio de pago
    final medioPagoNombre = medioPago?['nombre'] ?? 'No disponible';

    return Scaffold(
      appBar: AppBar(title: const Text("Detalle de Inscripción")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: WidgetDetailsLayout(
          child: Column(
            children: [
              // Avatar del cliente
              CircleAvatar(
                radius: 48,
                backgroundImage: clienteAvatarUrl.isNotEmpty
                    ? NetworkImage(clienteAvatarUrl)
                    : null,
                child: clienteAvatarUrl.isEmpty
                    ? const Icon(Icons.person, size: 48)
                    : null,
              ),
              const SizedBox(height: 16),

              Text(
                clienteNombre,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: AppDimensions.marginS),
              const Divider(thickness: 0.7),
              const SizedBox(height: AppDimensions.marginM),

              // SECCIÓN DATOS DEL CLIENTE
              _sectionTitle("Datos del Cliente"),
              _infoTile("Nombre", clienteNombre),
              _infoTile("Email", clienteEmail),
              _infoTile("Contacto", clienteContacto),

              const SizedBox(height: AppDimensions.marginS),
              const Divider(thickness: 0.7),
              const SizedBox(height: AppDimensions.marginM),

              // SECCIÓN DATOS DEL PAQUETE
              _sectionTitle("Información del Paquete"),
              _infoTile("Paquete", paqueteNombre),
              _infoTile("Precio del paquete", "S/ $paquetePrecio"),
              _infoTile("Número de sesiones", paqueteSesiones),

              const SizedBox(height: AppDimensions.marginS),
              const Divider(thickness: 0.7),
              const SizedBox(height: AppDimensions.marginM),

              // SECCIÓN DATOS DE LA INSCRIPCIÓN
              _sectionTitle("Datos de la Inscripción"),
              _infoTile("Fecha de inicio", fechaInicio),
              _infoTile("Fecha de fin", fechaFin),
              _infoTile("Monto cancelado", "S/ $montoCancelado"),
              _infoTile("Medio de pago", medioPagoNombre),

              const SizedBox(height: AppDimensions.marginS),
              const Divider(thickness: 0.7),
              const SizedBox(height: AppDimensions.marginM),

              // SECCIÓN EMPLEADO ASIGNADO
              _sectionTitle("Empleado Asignado"),
              _infoTile("Nombre", empleadoNombre),
              _infoTile("Email", empleadoEmail),

              const SizedBox(height: AppDimensions.marginS),
              const Divider(thickness: 0.7),
              const SizedBox(height: AppDimensions.marginM),

              WidgetButton(
                text: 'Editar inscripción',
                onPressed: () async {
                  await context.push(
                    AppRoutes.inscripcionesEdit,
                    extra: inscripcion,
                  );
                  await _refresh(); // Recarga datos actualizados
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value.isEmpty ? "—" : value, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
*/
