import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/entities/sesiones/services/sesiones_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_field.dart';
import 'package:sanku_pro/presentation/widgets/widget_picker.dart';

class SesionProgramarPage extends StatefulWidget {
  final Map<String, dynamic> sesion;

  const SesionProgramarPage({super.key, required this.sesion});

  @override
  State<SesionProgramarPage> createState() => _SesionProgramarPageState();
}

class _SesionProgramarPageState extends State<SesionProgramarPage> {
  final fechaController = TextEditingController();
  final horaController = TextEditingController();

  bool _isLoading = false;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();

    // Si ya tiene fecha/hora asignada, prellenar los campos
    if (widget.sesion['fecha'] != null) {
      fechaController.text = widget.sesion['fecha'];
    }

    if (widget.sesion['hora'] != null) {
      horaController.text = widget.sesion['hora'];
      // Parsear hora para TimeOfDay
      final parts = widget.sesion['hora'].split(':');
      if (parts.length == 2) {
        _selectedTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        // Formatear a HH:mm
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        horaController.text = '$hour:$minute';
      });
    }
  }

  Future<void> _programarSesion() async {
    final fecha = fechaController.text.trim();
    final hora = horaController.text.trim();

    if (fecha.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('La fecha es obligatoria')));
      return;
    }

    if (hora.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('La hora es obligatoria')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await programarSesion(widget.sesion['id'], fecha: fecha, hora: hora);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesión programada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(true); // Retornar true para indicar que se actualizó
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al programar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    fechaController.dispose();
    horaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final numeroSesion = widget.sesion['numeroSesion'] ?? 0;
    final duracion = widget.sesion['duracionMinutos'] ?? 60;
    final estado = widget.sesion['estado'] ?? 'pendiente';

    return Scaffold(
      appBar: const WidgetAppBar(title: 'Programar Sesión'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card de información
            Card(
              elevation: 2,
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.fitness_center, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Sesión #$numeroSesion',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 18,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text('Duración: $duracion minutos'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text('Estado actual: ${estado.toUpperCase()}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Programar fecha y hora',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Campo de fecha
            WidgetFieldDatePicker(
              controller: fechaController,
              label: 'Fecha de la sesión',
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            ),

            // Campo de hora
            GestureDetector(
              onTap: _selectTime,
              child: AbsorbPointer(
                child: WidgetField(
                  controller: horaController,
                  labelText: 'Hora de la sesión',
                  hintText: 'Seleccionar hora',
                  suffixIcon: const Icon(Icons.access_time),
                  readOnly: true,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Sugerencias de horario
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 18,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Horarios sugeridos',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildHorarioChip('08:00'),
                      _buildHorarioChip('10:00'),
                      _buildHorarioChip('14:00'),
                      _buildHorarioChip('16:00'),
                      _buildHorarioChip('18:00'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            WidgetButton(
              text: 'Programar sesión',
              onPressed: _isLoading ? null : _programarSesion,
              isLoading: _isLoading,
            ),

            const SizedBox(height: 12),

            WidgetButtonNeutral(
              onPressed: () => context.pop(),
              text: 'Cancelar',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorarioChip(String hora) {
    final isSelected = horaController.text == hora;

    return ActionChip(
      label: Text(hora),
      backgroundColor: isSelected ? Colors.blue.shade100 : null,
      side: BorderSide(color: isSelected ? Colors.blue : Colors.grey.shade300),
      onPressed: () {
        setState(() {
          horaController.text = hora;
          final parts = hora.split(':');
          _selectedTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        });
      },
    );
  }
}
