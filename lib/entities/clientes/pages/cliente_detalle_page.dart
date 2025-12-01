import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';
import 'package:sanku_pro/core/routes/app_routes.dart';
import 'package:sanku_pro/entities/clientes/services/clientes_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_details_layout.dart';

class ClienteDetallePage extends StatefulWidget {
  final Map<String, dynamic> args;

  const ClienteDetallePage({super.key, required this.args});

  @override
  State<ClienteDetallePage> createState() => _ClienteDetallePageState();
}

class _ClienteDetallePageState extends State<ClienteDetallePage> {
  late Map<String, dynamic> cliente;

  @override
  void initState() {
    super.initState();
    cliente = widget.args;
  }

  Future<void> _refresh() async {
    final id = cliente["id"];
    final updated = await getClienteById(id);
    if (updated != null) {
      setState(() {
        cliente = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombres = cliente['nombres'] ?? '';
    final apellidos = cliente['apellidos'] ?? '';
    final dni = cliente['dni'] ?? '';
    final direccion = cliente['direccion'] ?? '';
    final email = cliente['email'] ?? '';
    final contacto = cliente['contacto'] ?? '';
    final contactoEmergencia = cliente['contactoEmergencia'] ?? '';
    final estado = cliente['estado'] ?? '';
    final avatarUrl = cliente['avatarUrl'] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text("Perfil del cliente")),
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
              _infoTile("Dirección", direccion),
              _infoTile("Email", email),

              const SizedBox(height: AppDimensions.marginS),
              const Divider(thickness: 0.7),
              const SizedBox(height: AppDimensions.marginM),

              // SECCIÓN CONTACTO
              _sectionTitle("Información de contacto"),
              _infoTile("Contacto", contacto),
              _infoTile("Contacto de emergencia", contactoEmergencia),

              const SizedBox(height: AppDimensions.marginS),
              const Divider(thickness: 0.7),

              // SECCIÓN ESTADO
              _infoTile("Estado actual", estado),

              const SizedBox(height: AppDimensions.marginM),
              const Divider(thickness: 0.7),
              const SizedBox(height: AppDimensions.marginM),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  WidgetButtonNeutral(
                    text: 'Editar cliente',
                    onPressed: () async {
                      await context.push(AppRoutes.clienteEdit, extra: cliente);
                      await _refresh();
                    },
                  ),
                  WidgetButton(
                    text: 'Sesiones',
                    onPressed: () {
                      context.pushNamed(
                        'cliente-sesiones',
                        pathParameters: {'id': cliente['id']},
                        queryParameters: {
                          'nombre':
                              '${cliente['nombres']} ${cliente['apellidos']}',
                        },
                      );
                    },
                  ),
                ],
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
