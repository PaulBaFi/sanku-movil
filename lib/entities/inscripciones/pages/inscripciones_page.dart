import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/routes/app_routes_index.dart';
import 'package:sanku_pro/presentation/components/custom_bottom_app_bar.dart';
import 'package:sanku_pro/entities/inscripciones/services/inscripciones_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_fab.dart';
import 'package:sanku_pro/presentation/widgets/widget_main_layout.dart';
import 'package:sanku_pro/presentation/utils/others/confirm_dialog.dart';

class InscripcionesPage extends StatefulWidget {
  const InscripcionesPage({super.key});

  @override
  State<InscripcionesPage> createState() => _InscripcionesPageState();
}

class _InscripcionesPageState extends State<InscripcionesPage> {
  late Future<List> _inscripcionesFuture;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: 'S/ ',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _inscripcionesFuture = getInscripciones();
  }

  Future<void> _refresh() async {
    setState(() {
      _inscripcionesFuture = getInscripciones();
    });
    await _inscripcionesFuture;
  }

  /// Convierte cualquier número a double de forma segura
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Future<void> confirmDelete(String id) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Confirmar eliminación',
      content: '¿Desea eliminar esta inscripción y todos sus pagos asociados?',
    );

    if (confirmed == true) {
      await deleteInscripcion(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Inscripción eliminada')));
        await _refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: WidgetAppBar(title: 'Inscripciones'),
      body: WidgetMainLayout(
        child: FutureBuilder(
          future: _inscripcionesFuture,
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              debugPrint(
                '❌ Error en FutureBuilder principal: ${snapshot.error}',
              );
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay inscripciones',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data as List;

            return ListView.builder(
              itemCount: data.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final inscripcion = data[index] as Map<String, dynamic>;
                final id = inscripcion['id'];

                return FutureBuilder<Map<String, dynamic>?>(
                  future: getInscripcionCompleta(id),
                  builder: (context, detailSnapshot) {
                    if (detailSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: const ListTile(
                          leading: CircleAvatar(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          title: Text('Cargando...'),
                        ),
                      );
                    }

                    // ✅ MEJOR MANEJO DE ERRORES
                    if (detailSnapshot.hasError) {
                      debugPrint(
                        '❌ Error al cargar inscripción $id: ${detailSnapshot.error}',
                      );
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.error, color: Colors.red),
                          title: Text('Error en inscripción $id'),
                          subtitle: Text(
                            detailSnapshot.error.toString(),
                            style: const TextStyle(fontSize: 10),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () => setState(() {}),
                          ),
                        ),
                      );
                    }

                    if (!detailSnapshot.hasData ||
                        detailSnapshot.data == null) {
                      debugPrint('⚠️ No hay datos para inscripción $id');
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.warning,
                            color: Colors.orange,
                          ),
                          title: const Text('Datos no disponibles'),
                          subtitle: Text('ID: $id'),
                          trailing: IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () => setState(() {}),
                          ),
                        ),
                      );
                    }

                    try {
                      final inscripcionCompleta = detailSnapshot.data!;
                      final cliente = inscripcionCompleta['cliente'];
                      final paquete = inscripcionCompleta['paquete'];

                      final clienteNombre = cliente != null
                          ? "${cliente['nombres'] ?? ''} ${cliente['apellidos'] ?? ''}"
                                .trim()
                          : 'Cliente no disponible';

                      final paqueteNombre = paquete != null
                          ? paquete['nombre_paquete'] ?? 'Sin paquete'
                          : 'Paquete no disponible';

                      // ✅ Conversión segura a double
                      final precioPaquete = _toDouble(paquete?['precio']);
                      final montoCancelado = _toDouble(
                        inscripcionCompleta['montoCancelado'],
                      );
                      final avatarUrl = cliente?['avatarUrl'] ?? '';

                      // Calcular estado de pago
                      final saldoPendiente = precioPaquete - montoCancelado;
                      final estaPagadoCompleto = saldoPendiente <= 0;
                      final porcentajePagado = precioPaquete > 0
                          ? (montoCancelado / precioPaquete * 100).clamp(
                              0.0,
                              100.0,
                            )
                          : 0.0;

                      return Dismissible(
                        key: Key(id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showConfirmDialog(
                            context,
                            title: 'Confirmar eliminación',
                            content:
                                '¿Desea eliminar esta inscripción y todos sus pagos?',
                          );
                        },
                        onDismissed: (direction) async {
                          await deleteInscripcion(id);
                          if (mounted) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('Inscripción eliminada'),
                              ),
                            );
                            await _refresh();
                          }
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          elevation: 2,
                          child: Column(
                            children: [
                              ListTile(
                                leading: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor:
                                          AppColors.backgroundLight,
                                      backgroundImage: (avatarUrl.isNotEmpty)
                                          ? NetworkImage(avatarUrl)
                                          : null,
                                      child: (avatarUrl.isEmpty)
                                          ? const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    // Indicador de estado de pago
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: estaPagadoCompleto
                                              ? Colors.green
                                              : (porcentajePagado > 0
                                                    ? Colors.orange
                                                    : Colors.red),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          estaPagadoCompleto
                                              ? Icons.check
                                              : (porcentajePagado > 0
                                                    ? Icons.more_horiz
                                                    : Icons.close),
                                          color: Colors.white,
                                          size: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        clienteNombre,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // Badge de estado
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: estaPagadoCompleto
                                            ? Colors.green.withAlpha(25)
                                            : Colors.orange.withAlpha(25),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: estaPagadoCompleto
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                      ),
                                      child: Text(
                                        estaPagadoCompleto
                                            ? 'PAGADO'
                                            : 'PENDIENTE',
                                        style: TextStyle(
                                          color: estaPagadoCompleto
                                              ? Colors.green
                                              : Colors.orange,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
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
                                        Icon(
                                          Icons.inventory_2_outlined,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            paqueteNombre,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      spacing: 8,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              _currencyFormat.format(
                                                montoCancelado,
                                              ),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: estaPagadoCompleto
                                                    ? Colors.green
                                                    : AppColors.primary,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              ' de ${_currencyFormat.format(precioPaquete)}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '${porcentajePagado.toStringAsFixed(0)}%',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 6),
                                    // Barra de progreso
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: porcentajePagado / 100,
                                        minHeight: 6,
                                        backgroundColor: Colors.grey.shade300,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              estaPagadoCompleto
                                                  ? Colors.green
                                                  : Colors.orange,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),

                                onTap: () async {
                                  await context.push(
                                    AppRoutes.inscripcionesDetalle,
                                    extra: inscripcionCompleta,
                                  );
                                  await _refresh();
                                },
                              ),
                              // Info adicional si hay saldo pendiente
                              if (!estaPagadoCompleto)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.warning_amber,
                                            size: 16,
                                            color: Colors.orange[700],
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Saldo pendiente:',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.orange[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        _currencyFormat.format(saldoPendiente),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    } catch (e, stackTrace) {
                      debugPrint(
                        '❌ Error al construir card de inscripción $id: $e',
                      );
                      debugPrint('Stack trace: $stackTrace');
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.error, color: Colors.red),
                          title: const Text('Error al mostrar inscripción'),
                          subtitle: Text(e.toString()),
                        ),
                      );
                    }
                  },
                );
              },
            );
          }),
        ),
      ),
      floatingActionButton: WidgetFAB(
        icon: Icons.add,
        tooltip: 'Agregar inscripción',
        onPressed: () async {
          await context.push(AppRoutes.inscripcionesAdd);
          await _refresh();
        },
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }
}
