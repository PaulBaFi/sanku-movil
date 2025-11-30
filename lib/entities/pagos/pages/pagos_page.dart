import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/routes/app_routes.dart';
import 'package:sanku_pro/presentation/components/custom_bottom_app_bar.dart';
import 'package:sanku_pro/entities/pagos/services/pagos_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_main_layout.dart';
import 'package:sanku_pro/presentation/utils/others/confirm_dialog.dart';

class PagosPage extends StatefulWidget {
  const PagosPage({super.key});

  @override
  State<PagosPage> createState() => _PagosPageState();
}

class _PagosPageState extends State<PagosPage> {
  late Future<List<Map<String, dynamic>>> _pagosFuture;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: 'S/ ',
    decimalDigits: 2,
  );
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _pagosFuture = getPagos();
  }

  Future<void> _refresh() async {
    setState(() {
      _pagosFuture = getPagos();
    });
    await _pagosFuture;
  }

  Future<void> confirmDelete(String id) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Confirmar eliminación',
      content: '¿Desea eliminar este pago?',
    );

    if (confirmed == true) {
      await deletePago(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Pago eliminado')));
        await _refresh();
      }
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

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: WidgetAppBar(title: 'Pagos'),
      body: WidgetMainLayout(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _pagosFuture,
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No hay pagos registrados',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data!;

            return ListView.builder(
              itemCount: data.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final pago = data[index];
                final id = pago['id'] as String;
                final monto = pago['monto'] ?? 0.0;
                final estado = pago['estado'] ?? 'pendiente';
                final metodoPago = pago['metodo_pago'] ?? 'efectivo';
                final fechaPago = pago['fecha_pago'];
                final inscripcion =
                    pago['inscripcion'] as Map<String, dynamic>?;
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

                return Dismissible(
                  key: Key(id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: AppColors.error,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showConfirmDialog(
                      context,
                      title: 'Confirmar eliminación',
                      content: '¿Desea eliminar este pago?',
                    );
                  },
                  onDismissed: (direction) async {
                    await deletePago(id);
                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(content: Text('Pago eliminado')),
                      );
                      await _refresh();
                    }
                  },
                  child: ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _currencyFormat.format(monto),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getEstadoColor(estado).withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getEstadoColor(estado),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            estado.toUpperCase(),
                            style: TextStyle(
                              color: _getEstadoColor(estado),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    fechaFormateada,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('•'),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.payment,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    metodoPago.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (inscripcion != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Inscripción: ${inscripcion['id']?.toString().substring(0, 8) ?? 'N/A'}...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (qrCodeUrl != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.qr_code,
                                    size: 14,
                                    color: AppColors.info,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'QR generado',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.info,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),

                    onTap: () async {
                      await context.push(AppRoutes.pagoDetalle, extra: pago);
                      await _refresh();
                    },
                  ),
                );
              },
            );
          }),
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }
}
