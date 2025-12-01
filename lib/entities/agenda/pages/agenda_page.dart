import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/presentation/components/custom_bottom_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_main_layout.dart';
import 'package:intl/intl.dart';
import 'package:sanku_pro/entities/clientes/services/clientes_firebase_service.dart';
import 'package:sanku_pro/entities/empleados/services/empleados_firebase_service.dart';
import 'package:sanku_pro/entities/sesiones/services/sesiones_firebase_service.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  DateTime selectedDate = DateTime.now();
  Map<String, List<Map<String, dynamic>>> sesionesPorFecha = {};
  bool _isLoading = true;
  String _searchQuery = '';

  // Generar lista de fechas para el calendario (30 días desde hoy)
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

  bool _tieneSesiones(DateTime fecha) {
    final fechaStr = DateFormat('yyyy-MM-dd').format(fecha);
    return sesionesPorFecha.containsKey(fechaStr) &&
        sesionesPorFecha[fechaStr]!.isNotEmpty;
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
      appBar: const WidgetAppBar(title: 'AGENDA'),
      body: WidgetMainLayout(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Buscar por cliente o terapeuta',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Calendar
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: diasCalendario.length,
                itemBuilder: (context, index) {
                  final fecha = diasCalendario[index];
                  final isSelected =
                      DateFormat('yyyy-MM-dd').format(fecha) ==
                      DateFormat('yyyy-MM-dd').format(selectedDate);
                  final hasSessions = _tieneSesiones(fecha);
                  final isToday =
                      DateFormat('yyyy-MM-dd').format(fecha) ==
                      DateFormat('yyyy-MM-dd').format(DateTime.now());

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDate = fecha;
                      });
                    },
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isToday
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${fecha.day}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM', 'es').format(fecha),
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                          ),
                          if (hasSessions && !isSelected)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Header con fecha seleccionada y contador
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE, d MMMM', 'es').format(selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${currentSessions.length} sesiones',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Sessions list
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: currentSessions.length,
                        itemBuilder: (context, index) {
                          final sesion = currentSessions[index];
                          return _buildSessionCard(sesion);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomAppBar(),
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
