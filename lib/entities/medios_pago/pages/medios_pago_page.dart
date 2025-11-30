import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';
import 'package:sanku_pro/core/routes/app_routes.dart';
import 'package:sanku_pro/entities/medios_pago/services/medios_pago_firebase_service.dart';
import 'package:sanku_pro/presentation/components/custom_bottom_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_fab.dart';
import 'package:sanku_pro/presentation/widgets/widget_main_layout.dart';

class MediosPagoPage extends StatefulWidget {
  const MediosPagoPage({super.key});

  @override
  State<MediosPagoPage> createState() => _MediosPagoPageState();
}

class _MediosPagoPageState extends State<MediosPagoPage> {
  late Future<List> _mediosPagoFuture;

  @override
  void initState() {
    super.initState();
    _mediosPagoFuture = getMediosPago();
  }

  Future<void> _refresh() async {
    setState(() {
      _mediosPagoFuture = getMediosPago();
    });
    await _mediosPagoFuture;
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Desea eliminar este medio de pago?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await deleteMedioPago(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medio de pago eliminado')),
        );
        await _refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetAppBar(title: 'MEDIOS DE PAGO'),
      body: WidgetMainLayout(
        child: FutureBuilder(
          future: _mediosPagoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
              return const Center(child: Text('No hay medios de pago.'));
            }

            final data = snapshot.data as List;

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final medioPago = data[index] as Map<String, dynamic>;
                final id = medioPago['id'];
                final nombre = "${medioPago['nombre'] ?? ''}".trim();
                final imagen = medioPago['imagen'];

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingS,
                    horizontal: AppDimensions.paddingM,
                  ),
                  leading: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F7FB),
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppDimensions.radiusS),
                      ),
                    ),
                    padding: const EdgeInsets.all(AppDimensions.paddingS),
                    child: imagen != null && imagen.toString().trim().isNotEmpty
                        ? Image.network(
                            imagen,
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          )
                        : const Icon(Icons.image_not_supported, size: 40),
                  ),
                  title: Text(nombre.isEmpty ? 'Sin nombre' : nombre),
                  onTap: () async {
                    await context.push(
                      AppRoutes.medioPagoEdit,
                      extra: medioPago,
                    );
                    await _refresh();
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(id),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: WidgetFAB(
        icon: Icons.add,
        tooltip: 'Agregar medio de pago',
        onPressed: () async {
          await context.push(AppRoutes.medioPagoAdd);
          await _refresh();
        },
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }
}
