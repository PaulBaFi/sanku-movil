import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// App styling constants are used inside the reusable SearchWidget.
import 'package:sanku_pro/core/routes/app_routes.dart';
import 'package:sanku_pro/entities/servicios/services/servicios_firebase_service.dart';
import 'package:sanku_pro/presentation/components/custom_bottom_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_fab.dart';
import 'package:sanku_pro/presentation/widgets/widget_main_layout.dart';
import 'package:sanku_pro/presentation/widgets/search_widget.dart';

class ServiciosPage extends StatefulWidget {
  const ServiciosPage({super.key});

  @override
  State<ServiciosPage> createState() => _ServiciosPageState();
}

class _ServiciosPageState extends State<ServiciosPage> {
  late Future<List> _serviciosFuture;

  List _serviciosOriginal = [];
  List _serviciosFiltrados = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _serviciosFuture = getServicios().then((list) {
      _serviciosOriginal = list;
      _serviciosFiltrados = List.from(_serviciosOriginal);
      return list;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        _serviciosFiltrados = List.from(_serviciosOriginal);
      } else {
        _serviciosFiltrados = _serviciosOriginal.where((item) {
          final nombre = (item["nombre_servicio"] ?? "")
              .toString()
              .toLowerCase();
          final descripcion = (item["descripcion"] ?? "")
              .toString()
              .toLowerCase();

          return nombre.contains(query) || descripcion.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _refresh() async {
    final list = await getServicios();
    setState(() {
      _serviciosOriginal = list;
      _applyFilter();
    });
  }

  Future<bool> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Desea eliminar este servicio?'),
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
      await deleteServicio(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Servicio eliminado')));
      }
      await _refresh();
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetAppBar(title: 'SERVICIOS'),
      body: WidgetMainLayout(
        child: FutureBuilder(
          future: _serviciosFuture,
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                SearchWidget(
                  controller: _searchController,
                  hintText: 'Buscar servicio...',
                  onChanged: (_) => _applyFilter(),
                  onClear: () => _applyFilter(),
                  prefixIcon: Icons.search,
                ),

                Expanded(
                  child: _serviciosFiltrados.isEmpty
                      ? const Center(
                          child: Text('No se encontraron resultados.'),
                        )
                      : ListView.builder(
                          itemCount: _serviciosFiltrados.length,
                          itemBuilder: (context, index) {
                            final servicio =
                                _serviciosFiltrados[index]
                                    as Map<String, dynamic>;

                            final id = servicio['id'];
                            final nombre =
                                "${servicio['nombre_servicio'] ?? ''}".trim();
                            final descripcion = servicio['descripcion'] ?? '';

                            return Dismissible(
                              key: Key(id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
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
                                title: Text(
                                  nombre.isEmpty ? 'Sin nombre' : nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  descripcion.isEmpty
                                      ? 'Sin descripción'
                                      : descripcion,
                                ),
                                onTap: () async {
                                  await context.push(
                                    AppRoutes.servicioEdit,
                                    extra: servicio,
                                  );
                                  await _refresh();
                                },
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }),
        ),
      ),
      floatingActionButton: WidgetFAB(
        icon: Icons.add,
        tooltip: 'Agregar servicio',
        onPressed: () async {
          await context.push(AppRoutes.servicioAdd);
          await _refresh();
        },
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }
}
