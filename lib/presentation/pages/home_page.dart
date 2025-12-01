import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';
import 'package:sanku_pro/core/constants/app_text_styles.dart';
import 'package:sanku_pro/core/routes/app_routes_index.dart';
import 'package:sanku_pro/entities/clientes/services/clientes_firebase_service.dart';
import 'package:sanku_pro/entities/empleados/services/empleados_firebase_service.dart';
import 'package:sanku_pro/entities/sesiones/services/sesiones_firebase_service.dart';
import 'package:sanku_pro/presentation/components/custom_bottom_app_bar.dart';
import 'package:sanku_pro/presentation/pages/auth/services/auth_firebase_service.dart';
import 'package:sanku_pro/presentation/utils/others/items_colors.dart';
import 'package:sanku_pro/presentation/utils/others/menu_items.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>> futurasSesiones;
  DateTime selectedDate = DateTime.now();
  Map<String, List<Map<String, dynamic>>> sesionesPorFecha = {};
  bool _isLoading = true;
  final String _searchQuery = '';

  late List<DateTime> diasCalendario;

  @override
  void initState() {
    super.initState();
    _generarDiasCalendario();
    _loadSesiones();
  }

  void _generarDiasCalendario() {
    diasCalendario = List.generate(
      30,
      (index) => DateTime.now().add(Duration(days: index - 7)),
    );
  }

  Future<void> _loadSesiones() async {
    setState(() => _isLoading = true);

    try {
      final fechaInicio = diasCalendario.first;
      final fechaFin = diasCalendario.last;

      final sesiones = await getSesionesPorRango(
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );

      // Enriquecer sesiones con datos de cliente y empleado
      for (var fecha in sesiones.keys) {
        for (var sesion in sesiones[fecha]!) {
          // Obtener nombre del cliente
          final cliente = await getClienteById(sesion['clienteId']);
          sesion['clienteNombre'] = cliente != null
              ? '${cliente['nombres']} ${cliente['apellidos']}'
              : 'Cliente desconocido';

          // Obtener nombre del empleado
          final empleado = await getEmpleadoById(sesion['empleadoId']);
          sesion['empleadoNombre'] = empleado != null
              ? '${empleado['nombres']} ${empleado['apellidos']}'
              : 'Empleado desconocido';

          sesion['empleadoLicencia'] = empleado?['licencia'] ?? '';
        }
      }

      setState(() {
        sesionesPorFecha = sesiones;
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

  List<Map<String, dynamic>> get currentSessions {
    final selectedDateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final sesiones = sesionesPorFecha[selectedDateStr] ?? [];

    // Filtrar por búsqueda
    if (_searchQuery.isEmpty) {
      return sesiones;
    }

    return sesiones.where((sesion) {
      final clienteNombre = sesion['clienteNombre']?.toLowerCase() ?? '';
      final empleadoNombre = sesion['empleadoNombre']?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();

      return clienteNombre.contains(query) || empleadoNombre.contains(query);
    }).toList();
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'completada':
        return AppColors.success;
      case 'programada':
        return Colors.blue;
      case 'cancelada':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
          Container(
            color: AppColors.backgroundLight,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  color: Color(0xFFFFF7E4),
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "Hola, ${authService.value.currentUser!.displayName}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: List.generate(itemsHastaVerMas.length, (index) {
                    final item = itemsHastaVerMas[index];
                    return Center(
                      child: GestureDetector(
                        onTap: () {
                          if (item['action'] != null) {
                            item['action'](context); // usa la lista correcta
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingL,
                                vertical: AppDimensions.paddingS,
                              ),
                              decoration: BoxDecoration(
                                color: ItemsColors.bgThreeLight,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusM,
                                ),
                              ),
                              child: Icon(
                                item['icon'],
                                size: 24,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              item['label'],
                              textAlign: TextAlign.center,
                              style: AppTextStyles.textTheme.labelLarge,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Agenda del día',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : currentSessions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'No hay sesiones programadas'
                                      : 'No se encontraron sesiones',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadSesiones,
                            child: ListView.builder(
                              itemCount: currentSessions.length,
                              itemBuilder: (context, index) {
                                final sesion = currentSessions[index];
                                return _buildSessionCard(sesion);
                              },
                            ),
                          ),
                  ),
                  Row(
                    spacing: 6,
                    children: [
                      Expanded(
                        child: WidgetButtonNeutral(
                          icon: Icons.add,
                          iconSpacing: 6,
                          text: 'Inscribir',
                          onPressed: () {
                            context.push(AppRoutes.inscripcionesAdd);
                          },
                        ),
                      ),
                      Expanded(
                        child: WidgetButton(
                          icon: Icons.calendar_month,
                          text: 'Ver agenda',
                          onPressed: () {
                            context.push(AppRoutes.agenda);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> sesion) {
    final hora = sesion['hora'] ?? 'Sin hora';
    final clienteNombre = sesion['clienteNombre'] ?? 'Cliente desconocido';
    final empleadoNombre = sesion['empleadoNombre'] ?? 'Empleado desconocido';
    final empleadoLicencia = sesion['empleadoLicencia'] ?? '';
    final estado = sesion['estado'] ?? 'pendiente';
    final numeroSesion = sesion['numeroSesion'] ?? 0;
    final duracion = sesion['duracionMinutos'] ?? 60;

    // Calcular sesiones totales (esto requeriría más lógica, por ahora simplificado)
    final sessionInfo = 'Sesión #$numeroSesion';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hora
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hora,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$duracion min',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Información principal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cliente
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        clienteNombre,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Terapeuta
                Row(
                  children: [
                    Icon(
                      Icons.medical_services,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        empleadoLicencia.isNotEmpty
                            ? '$empleadoLicencia - $empleadoNombre'
                            : empleadoNombre,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Info de sesión
                Text(
                  sessionInfo,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Estado
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getEstadoColor(estado).withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getEstadoColor(estado), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _getEstadoColor(estado),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      estado == 'programada'
                          ? 'Programada'
                          : estado == 'completada'
                          ? 'Completada'
                          : 'Cancelada',
                      style: TextStyle(
                        fontSize: 10,
                        color: _getEstadoColor(estado),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
