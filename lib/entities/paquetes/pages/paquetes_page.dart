import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/core/routes/app_routes.dart';
import 'package:sanku_pro/entities/paquetes/services/paquetes_firebase_service.dart';
import 'package:sanku_pro/presentation/components/custom_bottom_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_fab.dart';
import 'package:sanku_pro/presentation/widgets/widget_main_layout.dart';

class PaquetesPage extends StatefulWidget {
  const PaquetesPage({super.key});

  @override
  State<PaquetesPage> createState() => _PaquetesPageState();
}

class _PaquetesPageState extends State<PaquetesPage> {
  late Future<List> _paquetesFuture;

  @override
  void initState() {
    super.initState();
    _paquetesFuture = getPaquetes();
  }

  Future<void> _refresh() async {
    setState(() {
      _paquetesFuture = getPaquetes();
    });
    await _paquetesFuture;
  }

  Future<bool> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Desea eliminar este paquete?'),
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
      await deletePaquete(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Paquete eliminado')));
      }
      await _refresh();
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetAppBar(title: 'PAQUETES'),
      body: WidgetMainLayout(
        child: FutureBuilder(
          future: _paquetesFuture,
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
              return const Center(child: Text('No hay paquetes registrados.'));
            }

            final data = snapshot.data as List;

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final paquete = data[index] as Map<String, dynamic>;

                final id = paquete['id'];
                final nombre = "${paquete['nombre_paquete'] ?? ''}".trim();
                final sesiones = paquete['numero_sesiones'] ?? '-';
                final precio = paquete['precio'] ?? '-';
                final clientesActivos = paquete['clientes_activos'] ?? '-';

                return Dismissible(
                  key: Key(id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  confirmDismiss: (_) async {
                    return await _confirmDelete(id);
                  },
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          nombre.isEmpty ? 'Sin nombre' : nombre,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          's/.$precio',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Duración: $sesiones sesiones"),
                        Text(
                          "$clientesActivos clientes activos",
                          style: TextStyle(color: Color(0xFF5C25FF)),
                        ),
                      ],
                    ),
                    onTap: () async {
                      await context.push(AppRoutes.paqueteEdit, extra: paquete);
                      await _refresh();
                    },
                  ),
                );

                /* ListTile(
                  title: Text(nombre.isEmpty ? 'Sin nombre' : nombre),
                  subtitle: Text(
                    "Sesiones: $sesiones   |   Precio: S/. $precio",
                  ),
                  onTap: () async {
                    await context.push(
                      AppRoutes.paqueteEdit,
                      extra: paquete,
                    );
                    await _refresh();
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(id),
                  ),
                ); */
              },
            );
          }),
        ),
      ),
      floatingActionButton: WidgetFAB(
        icon: Icons.add,
        tooltip: 'Agregar paquete',
        onPressed: () async {
          await context.push(AppRoutes.paqueteAdd);
          await _refresh();
        },
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }
}
