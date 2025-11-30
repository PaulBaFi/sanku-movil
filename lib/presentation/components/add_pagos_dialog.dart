import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sanku_pro/entities/inscripciones/services/inscripciones_firebase_service.dart';
import 'package:sanku_pro/entities/medios_pago/services/medios_pago_firebase_service.dart';

class AgregarPagoDialog extends StatefulWidget {
  final String inscripcionId;
  final Map<String, dynamic> inscripcion;
  final double saldoPendiente;

  const AgregarPagoDialog({
    super.key,
    required this.inscripcionId,
    required this.inscripcion,
    required this.saldoPendiente,
  });

  @override
  State<AgregarPagoDialog> createState() => _AgregarPagoDialogState();
}

class _AgregarPagoDialogState extends State<AgregarPagoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: 'S/ ',
    decimalDigits: 2,
  );

  String? _metodoPagoSeleccionado;
  List<Map<String, dynamic>> _metodosPago = [];
  bool _isLoading = false;
  bool _generarQR = true;

  @override
  void initState() {
    super.initState();
    _cargarMetodosPago();
  }

  Future<void> _cargarMetodosPago() async {
    try {
      final metodos = await getMediosPago();
      setState(() {
        // Cast explícito a List<Map<String, dynamic>>
        _metodosPago = metodos.cast<Map<String, dynamic>>();
        // Pre-seleccionar el método de pago de la inscripción
        _metodoPagoSeleccionado = widget.inscripcion['medioPagoId'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar métodos de pago: $e')),
        );
      }
    }
  }

  Future<void> _agregarPago() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final monto = double.parse(_montoController.text);

      await agregarPagoAInscripcion(
        widget.inscripcionId,
        monto,
        metodoPagoId: _metodoPagoSeleccionado,
        generarQR: _generarQR,
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Retornar true para indicar éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pago agregado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar pago: $e'),
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

  void _setPagoCompleto() {
    _montoController.text = widget.saldoPendiente.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Pago'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información del saldo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo Pendiente',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currencyFormat.format(widget.saldoPendiente),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Campo de monto
              TextFormField(
                controller: _montoController,
                decoration: InputDecoration(
                  labelText: 'Monto a pagar *',
                  prefixText: 'S/ ',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.account_balance_wallet),
                    tooltip: 'Pagar saldo completo',
                    onPressed: _setPagoCompleto,
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el monto';
                  }
                  final monto = double.tryParse(value);
                  if (monto == null || monto <= 0) {
                    return 'Ingrese un monto válido';
                  }
                  if (monto > widget.saldoPendiente) {
                    return 'El monto excede el saldo pendiente';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Selector de método de pago
              DropdownButtonFormField<String>(
                initialValue: _metodoPagoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Método de pago',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payment),
                ),
                items: _metodosPago.map((metodo) {
                  return DropdownMenuItem<String>(
                    value: metodo['id'],
                    child: Row(
                      children: [
                        Icon(
                          _getIconoMetodoPago(metodo['nombre']),
                          size: 20,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(metodo['nombre'] ?? 'Sin nombre'),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _metodoPagoSeleccionado = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Seleccione un método de pago';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Opción de generar QR
              CheckboxListTile(
                value: _generarQR,
                onChanged: (value) {
                  setState(() => _generarQR = value ?? true);
                },
                title: const Text('Generar código QR'),
                subtitle: const Text('Comprobante digital del pago'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _agregarPago,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Agregar Pago'),
        ),
      ],
    );
  }

  IconData _getIconoMetodoPago(String? nombre) {
    if (nombre == null) return Icons.payment;

    final nombreLower = nombre.toLowerCase();
    if (nombreLower.contains('efectivo')) return Icons.money;
    if (nombreLower.contains('tarjeta')) return Icons.credit_card;
    if (nombreLower.contains('transferencia')) return Icons.account_balance;
    if (nombreLower.contains('yape') || nombreLower.contains('plin')) {
      return Icons.phone_android;
    }
    return Icons.payment;
  }
}

/// Función helper para mostrar el diálogo
Future<bool?> mostrarDialogoAgregarPago(
  BuildContext context, {
  required String inscripcionId,
  required Map<String, dynamic> inscripcion,
  required double saldoPendiente,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AgregarPagoDialog(
      inscripcionId: inscripcionId,
      inscripcion: inscripcion,
      saldoPendiente: saldoPendiente,
    ),
  );
}
