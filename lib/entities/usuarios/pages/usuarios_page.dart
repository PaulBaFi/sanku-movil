import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/routes/app_routes_index.dart';
import 'package:sanku_pro/presentation/components/custom_bottom_app_bar.dart';
import 'package:sanku_pro/entities/usuarios/services/users_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_fab.dart';
import 'package:sanku_pro/presentation/widgets/widget_main_layout.dart';
import 'package:sanku_pro/presentation/utils/others/confirm_dialog.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  late Future<List> _usuariosFuture;

  @override
  void initState() {
    super.initState();
    _usuariosFuture = getUsuarios();
  }

  Future<void> _refresh() async {
    setState(() {
      _usuariosFuture = getUsuarios();
    });
    await _usuariosFuture;
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Confirmar eliminación',
      content: '¿Desea eliminar este usuario?',
    );

    if (confirmed == true) {
      await deleteUsuario(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Usuario eliminado')));
        await _refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetAppBar(title: 'Usuarios'),
      body: WidgetMainLayout(
        child: FutureBuilder(
          future: _usuariosFuture,
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
              return const Center(child: Text('No hay usuarios'));
            }

            final data = snapshot.data as List;

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final usuario = data[index] as Map<String, dynamic>;
                final id = usuario['id'];
                final username = "${usuario['username'] ?? ''}".trim();

                return ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.backgroundLight,
                    backgroundImage:
                        (usuario['avatarUrl'] != null &&
                            usuario['avatarUrl'].toString().isNotEmpty)
                        ? NetworkImage(usuario['avatarUrl'])
                        : null,
                    child:
                        (usuario['avatarUrl'] == null ||
                            usuario['avatarUrl'].toString().isEmpty)
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  title: Text(
                    username.isEmpty ? 'Sin nombre de usuario' : username,
                  ),
                  subtitle: Text(usuario['email'] ?? ''),
                  onTap: () async {
                    await context.push(
                      AppRoutes.usuarioDetalle,
                      extra: usuario,
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
          }),
        ),
      ),
      // TODO: VALIDACION DE VISIBILIDAD SOLO PARA ADMINS
      floatingActionButton: WidgetFAB(
        icon: Icons.add,
        tooltip: 'Agregar usuario',
        onPressed: () async {
          await context.push(AppRoutes.usuariosAdd);
          await _refresh();
        },
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }
}
