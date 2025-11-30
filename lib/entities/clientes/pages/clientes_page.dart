import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/routes/app_routes_index.dart';
import 'package:sanku_pro/presentation/components/custom_bottom_app_bar.dart';
import 'package:sanku_pro/entities/clientes/services/clientes_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_fab.dart';
import 'package:sanku_pro/presentation/widgets/widget_main_layout.dart';
import 'package:sanku_pro/presentation/utils/others/confirm_dialog.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  late Future<List> _clientesFuture;

  @override
  void initState() {
    super.initState();
    _clientesFuture = getClientes();
  }

  Future<void> _refresh() async {
    setState(() {
      _clientesFuture = getClientes();
    });
    await _clientesFuture;
  }

  Future<void> confirmDelete(String id) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Confirmar eliminación',
      content: '¿Desea eliminar este cliente?',
    );

    if (confirmed == true) {
      await deleteCliente(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cliente eliminado')));
        await _refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: WidgetAppBar(title: 'Clientes'),
      body: WidgetMainLayout(
        child: FutureBuilder(
          future: _clientesFuture,
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
              return const Center(child: Text('No hay clientes'));
            }

            final data = snapshot.data as List;

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final cliente = data[index] as Map<String, dynamic>;
                final id = cliente['id'];
                final nombreCompleto =
                    "${cliente['nombres'] ?? ''} ${cliente['apellidos'] ?? ''}"
                        .trim();

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
                      content: '¿Desea eliminar este cliente?',
                    );
                  },
                  onDismissed: (direction) async {
                    await deleteCliente(id);
                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(content: Text('Cliente eliminado')),
                      );
                      await _refresh();
                    }
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.backgroundLight,
                      backgroundImage:
                          (cliente['avatarUrl'] != null &&
                              cliente['avatarUrl'].toString().isNotEmpty)
                          ? NetworkImage(cliente['avatarUrl'])
                          : null,
                      child:
                          (cliente['avatarUrl'] == null ||
                              cliente['avatarUrl'].toString().isEmpty)
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    title: Text(
                      nombreCompleto.isEmpty ? 'Sin nombre' : nombreCompleto,
                    ),
                    subtitle: Text(
                      cliente['email'] ?? cliente['contacto'] ?? '',
                    ),
                    trailing: Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      await context.push(
                        AppRoutes.clienteDetalle,
                        extra: cliente,
                      );
                      await _refresh();
                    },
                  ),
                );
              },
            );
          }),
        ),
      ),
      floatingActionButton: WidgetFAB(
        icon: Icons.add,
        tooltip: 'Agregar cliente',
        onPressed: () async {
          await context.push(AppRoutes.clienteAdd);
          await _refresh();
        },
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }
}
