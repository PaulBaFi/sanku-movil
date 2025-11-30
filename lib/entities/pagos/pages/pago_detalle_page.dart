import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';
import 'package:sanku_pro/core/routes/app_routes.dart';
import 'package:sanku_pro/entities/pagos/services/pagos_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_details_layout.dart';
import 'package:sanku_pro/presentation/utils/others/confirm_dialog.dart';

class PagoDetallePage extends StatefulWidget {
  final Map<String, dynamic> args;

  const PagoDetallePage({super.key, required this.args});

  @override
  State<PagoDetallePage> createState() => _PagoDetallePageState();
}

class _PagoDetallePageState extends State<PagoDetallePage> {
  late Map<String, dynamic> pago;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: 'S/ ',
    decimalDigits: 2,
  );
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  bool _isRegeneratingQR = false;

  @override
  void initState() {
    super.initState();
    pago = widget.args;
  }

  Future<void> _refresh() async {
    final id = pago["id"];
    final updated = await getPagoById(id);
    if (updated != null) {
      setState(() {
        pago = updated;
      });
    }
  }

  Future<void> _regenerarQR() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Regenerar Código QR',
      content: '¿Desea regenerar el código QR de este pago?',
    );

    if (confirmed != true) return;

    setState(() => _isRegeneratingQR = true);

    try {
      await regenerarQRPago(pago["id"]);
      await _refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Código QR regenerado exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al regenerar QR: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRegeneratingQR = false);
      }
    }
  }

  Future<void> _copiarIdPago() async {
    await Clipboard.setData(ClipboardData(text: pago["id"]));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID del pago copiado al portapapeles'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'completado':
        return AppColors.success;
      case 'pendiente':
        return AppColors.accent;
      case 'cancelado':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  IconData _getMetodoPagoIcon(String? nombre) {
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

  @override
  Widget build(BuildContext context) {
    // Datos del pago
    final id = pago['id'] as String;
    final monto = pago['monto'] ?? 0.0;
    final estado = pago['estado'] ?? 'completado';
    final fechaPago = pago['fecha_pago'];
    final fechaCreacion = pago['creadoEn'];
    final qrCodeUrl = pago['qr_code_url'];

    // Datos relacionados
    final inscripcion = pago['inscripcion'] as Map<String, dynamic>?;
    final metodoPago = pago['metodo_pago'] as Map<String, dynamic>?;

    // Formatear fechas
    String fechaPagoFormateada = 'Sin fecha';
    if (fechaPago != null) {
      try {
        final timestamp = fechaPago as dynamic;
        final date = timestamp.toDate();
        fechaPagoFormateada = _dateFormat.format(date);
      } catch (e) {
        fechaPagoFormateada = fechaPago.toString();
      }
    }

    String fechaCreacionFormateada = 'Sin fecha';
    if (fechaCreacion != null) {
      try {
        final timestamp = fechaCreacion as dynamic;
        final date = timestamp.toDate();
        fechaCreacionFormateada = _dateFormat.format(date);
      } catch (e) {
        fechaCreacionFormateada = fechaCreacion.toString();
      }
    }

    // Datos del método de pago
    final metodoPagoNombre = metodoPago?['nombre'] ?? 'No especificado';
    final metodoPagoImagen = metodoPago?['imagen'];

    // Datos de la inscripción
    final inscripcionId = inscripcion?['id'];

    return Scaffold(
      appBar: WidgetAppBar(
        title: 'DETALLE DEL PAGO',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: _refresh,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: WidgetDetailsLayout(
          child: Column(
            children: [
              // ========== CÓDIGO QR ==========
              if (qrCodeUrl != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: Column(
                    children: [
                      const Text(
                        'Comprobante de Pago',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          qrCodeUrl,
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              width: 250,
                              height: 250,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 250,
                              height: 250,
                              color: Colors.grey[200],
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: AppColors.error,
                                  ),
                                  SizedBox(height: 8),
                                  Text('Error al cargar QR'),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isRegeneratingQR ? null : _regenerarQR,
                        icon: _isRegeneratingQR
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh),
                        label: Text(
                          _isRegeneratingQR ? 'Regenerando...' : 'Regenerar QR',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.info,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.marginM),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Sin código QR',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Este pago no tiene un código QR generado',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isRegeneratingQR ? null : _regenerarQR,
                        icon: _isRegeneratingQR
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.qr_code),
                        label: Text(
                          _isRegeneratingQR ? 'Generando...' : 'Generar QR',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.marginM),
              ],

              // ========== INFORMACIÓN DEL MONTO ==========
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getEstadoColor(estado).withAlpha(25),
                      _getEstadoColor(estado).withAlpha(50),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(
                    color: _getEstadoColor(estado).withAlpha(75),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          estado.toLowerCase() == 'completado'
                              ? Icons.check_circle
                              : estado.toLowerCase() == 'pendiente'
                              ? Icons.pending
                              : Icons.cancel,
                          color: _getEstadoColor(estado),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          estado.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getEstadoColor(estado),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      textAlign: TextAlign.start,
                      _currencyFormat.format(monto),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _getEstadoColor(estado),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      fechaPagoFormateada,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.marginM),

              // ========== MÉTODO DE PAGO ==========
              _sectionTitle("Método de Pago"),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    if (metodoPagoImagen != null && metodoPagoImagen.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          metodoPagoImagen,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getMetodoPagoIcon(metodoPagoNombre),
                                color: Colors.grey[600],
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getMetodoPagoIcon(metodoPagoNombre),
                          color: Colors.blue.shade700,
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        metodoPagoNombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.marginS),
              const Divider(thickness: 0.7),
              const SizedBox(height: AppDimensions.marginM),

              // ========== INFORMACIÓN DE LA INSCRIPCIÓN ==========
              if (inscripcion != null) ...[
                _sectionTitle("Inscripción Asociada"),
                const SizedBox(height: 12),
                InkWell(
                  onTap: inscripcionId != null
                      ? () async {
                          final inscripcionCompleta =
                              await getInscripcionCompleta(inscripcionId);
                          if (inscripcionCompleta != null && mounted) {
                            // ignore: use_build_context_synchronously
                            context.push(
                              AppRoutes.inscripcionesDetalle,
                              extra: inscripcionCompleta,
                            );
                          }
                        }
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.assignment, color: AppColors.info, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ID: ${inscripcionId?.substring(0, 8) ?? 'N/A'}...',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.info,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Toca para ver detalles',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.blue.shade700),
                      ],
                    ),
                  ),
                ),
              ],

              // ========== INFORMACIÓN TÉCNICA ==========
              _sectionTitle("Información Técnica"),
              _infoTile(
                "ID del Pago",
                '${id.substring(0, 12)}...',
                onTap: _copiarIdPago,
              ),
              _infoTile("Fecha de Creación", fechaCreacionFormateada),
              _infoTile("Fecha de Pago", fechaPagoFormateada),
              if (qrCodeUrl != null)
                _infoTile(
                  "QR Generado",
                  "Sí",
                  trailing: const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 20,
                  ),
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

  Widget _infoTile(
    String label,
    String value, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
            const SizedBox(width: 16),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      value.isEmpty ? "—" : value,
                      style: TextStyle(
                        fontSize: 14,
                        color: onTap != null ? AppColors.info : Colors.black,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  if (trailing != null) ...[const SizedBox(width: 8), trailing],
                  if (onTap != null) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.copy, size: 16, color: AppColors.info),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Función auxiliar para obtener inscripción completa
  Future<Map<String, dynamic>?> getInscripcionCompleta(String id) async {
    // Esta función debe importarse desde el servicio de inscripciones
    // import 'package:sanku_pro/entities/inscripciones/services/inscripciones_firebase_service.dart';
    try {
      return await getInscripcionCompleta(id);
    } catch (e) {
      debugPrint('Error al obtener inscripción: $e');
      return null;
    }
  }
}
