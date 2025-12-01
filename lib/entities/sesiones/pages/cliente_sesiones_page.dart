import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/routes/app_routes_index.dart';
import 'package:sanku_pro/entities/sesiones/services/sesiones_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_button_text.dart';

class ClienteSesionesPage extends StatefulWidget {
  final String clienteId;
  final String clienteNombre;

  const ClienteSesionesPage({
    super.key,
    required this.clienteId,
    required this.clienteNombre,
  });

  @override
  State<ClienteSesionesPage> createState() => _ClienteSesionesPageState();
}

class _ClienteSesionesPageState extends State<ClienteSesionesPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _resumen;

  @override
  void initState() {
    super.initState();
    _loadSesiones();
  }

  Future<void> _loadSesiones() async {
    setState(() => _isLoading = true);

    try {
      final resumen = await getResumenSesionesCliente(widget.clienteId);
      setState(() {
        _resumen = resumen;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar sesiones: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'completada':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado.toLowerCase()) {
      case 'completada':
        return Icons.check_circle;
      case 'pendiente':
        return Icons.schedule;
      case 'cancelada':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetAppBar(title: 'Sesiones'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _resumen == null
          ? const Center(child: Text('No se pudo cargar la información'))
          : RefreshIndicator(
              onRefresh: _loadSesiones,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cliente: ${widget.clienteNombre}",
                      style: TextStyle(
                        color: AppColors.textMutedLight,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),

                    // Tarjetas de resumen
                    _buildResumenCards(),

                    const SizedBox(height: 24),

                    // Lista de sesiones
                    _buildSesionesList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildResumenCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total',
                _resumen!['totalSesiones'].toString(),
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Completadas',
                _resumen!['completadas'].toString(),
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Pendientes',
                _resumen!['pendientes'].toString(),
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Canceladas',
                _resumen!['canceladas'].toString(),
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(75)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildSesionesList() {
    final sesiones = _resumen!['sesiones'] as List<Map<String, dynamic>>;

    if (sesiones.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No hay sesiones registradas',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historial de Sesiones',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sesiones.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final sesion = sesiones[index];
            return _buildSesionCard(sesion);
          },
        ),
      ],
    );
  }

  Widget _buildSesionCard(Map<String, dynamic> sesion) {
    final estado = sesion['estado'] ?? 'pendiente';
    final fechaRaw = sesion['fecha'];
    final hora = sesion['hora'];
    final numeroSesion = sesion['numeroSesion'] ?? 0;
    final duracionMinutos = sesion['duracionMinutos'] ?? 60;
    final notas = sesion['notas'] ?? '';

    // Manejar correctamente el tipo de fecha
    String fechaFormateada = 'Sin programar';
    if (fechaRaw != null) {
      try {
        if (fechaRaw is Timestamp) {
          fechaFormateada = DateFormat('dd/MM/yyyy').format(fechaRaw.toDate());
        } else if (fechaRaw is String && fechaRaw.isNotEmpty) {
          // Si es string en formato yyyy-MM-dd, convertir a formato dd/MM/yyyy
          try {
            final date = DateTime.parse(fechaRaw);
            fechaFormateada = DateFormat('dd/MM/yyyy').format(date);
          } catch (e) {
            fechaFormateada = fechaRaw; // Usar tal cual si no se puede parsear
          }
        }
      } catch (e) {
        fechaFormateada = 'Fecha inválida';
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getEstadoColor(estado).withAlpha(75),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          // Navegar a programar sesión
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SesionProgramarPage(sesion: sesion),
            ),
          );

          // Si se programó, recargar
          if (result == true) {
            _loadSesiones();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getEstadoColor(estado).withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getEstadoColor(estado),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getEstadoIcon(estado),
                          color: _getEstadoColor(estado),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          estado.toUpperCase(),
                          style: TextStyle(
                            color: _getEstadoColor(estado),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Sesión #$numeroSesion',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Fecha y hora
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    fechaFormateada,
                    style: TextStyle(color: Colors.grey[800], fontSize: 14),
                  ),
                  if (hora != null && hora.toString().isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      hora.toString(),
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 8),

              // Duración
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Duración: $duracionMinutos min',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),

              // Notas si existen
              if (notas.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.note, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          notas,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Botón de acción según estado
              const SizedBox(height: 12),
              _buildAccionButton(sesion),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccionButton(Map<String, dynamic> sesion) {
    final estado = sesion['estado'] ?? 'pendiente';

    switch (estado) {
      case 'pendiente':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SesionProgramarPage(sesion: sesion),
                ),
              );
              if (result == true) _loadSesiones();
            },
            icon: const Icon(Icons.schedule, size: 18),
            label: const Text('Programar sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        );

      case 'programada':
        return Row(
          children: [
            Expanded(
              child: WidgetButtonNeutral(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SesionProgramarPage(sesion: sesion),
                    ),
                  );
                  if (result == true) _loadSesiones();
                },
                icon: Icons.edit,
                iconSpacing: 6,
                textColor: AppColors.primary,
                text: 'Modificar',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _confirmarCompletarSesion(sesion['id']),
                icon: const Icon(Icons.check_circle, size: 18),
                label: const Text('Completar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        );

      case 'completada':
        return Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              'Sesión completada',
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _confirmarCompletarSesion(String sesionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Completar sesión'),
        content: const Text('¿Marcar esta sesión como completada?'),
        actions: [
          WidgetButtonNeutral(
            onPressed: () => Navigator.pop(context, false),
            text: 'Cancelar',
          ),
          WidgetButton(
            onPressed: () => Navigator.pop(context, true),
            text: 'Completar',
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await completarSesion(sesionId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesión completada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _loadSesiones();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
