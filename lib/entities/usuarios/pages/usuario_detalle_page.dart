import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';
import 'package:sanku_pro/core/routes/app_routes.dart';
import 'package:sanku_pro/entities/usuarios/services/users_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_details_layout.dart';

class UsuarioDetallePage extends StatefulWidget {
  final Map<String, dynamic> args;

  const UsuarioDetallePage({super.key, required this.args});

  @override
  State<UsuarioDetallePage> createState() => _UsuarioDetallePageState();
}

class _UsuarioDetallePageState extends State<UsuarioDetallePage> {
  late Map<String, dynamic> usuario;

  @override
  void initState() {
    super.initState();
    usuario = widget.args;
  }

  Future<void> _refresh() async {
    final id = usuario["id"];
    final updated = await getUsuarioById(id);
    if (updated != null) {
      setState(() {
        usuario = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombres = usuario['nombres'] ?? '';
    final apellidos = usuario['apellidos'] ?? '';
    final dni = usuario['dni'] ?? '';
    final nacimiento = usuario['nacimiento'] ?? '';
    final phone = usuario['phone'] ?? '';
    final direccion = usuario['direccion'] ?? '';

    final email = usuario['email'] ?? '';
    final username = usuario['username'] ?? '';
    final role = usuario['role'] ?? '';
    final avatarUrl = usuario['avatarUrl'] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text("Perfil de usuario")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: WidgetDetailsLayout(
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundImage: avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl.isEmpty
                    ? const Icon(Icons.person, size: 48)
                    : null,
              ),
              const SizedBox(height: 16),

              Text(
                "$nombres $apellidos",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: AppDimensions.marginS),
              const Divider(thickness: 0.7),
              const SizedBox(height: AppDimensions.marginM),

              // SECCIÓN DATOS PERSONALES
              _sectionTitle("Datos personales"),
              _infoTile("DNI", dni),
              _infoTile("Nacimiento", nacimiento),
              _infoTile("Teléfono", phone),
              _infoTile("Dirección", direccion),

              const SizedBox(height: AppDimensions.marginS),
              const Divider(thickness: 0.7),
              const SizedBox(height: AppDimensions.marginM),

              // SECCIÓN CUENTA
              _sectionTitle("Datos de la cuenta"),
              _infoTile("Email", email),
              _infoTile("Usuario", username),
              _infoTile("Rol", role),

              const SizedBox(height: AppDimensions.marginS),
              const Divider(thickness: 0.7),
              const SizedBox(height: AppDimensions.marginM),

              WidgetButton(
                text: 'Editar usuario',
                onPressed: () async {
                  await context.push(AppRoutes.usuariosEdit, extra: usuario);
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
