import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';
import 'package:sanku_pro/core/constants/app_text_styles.dart';
import 'package:sanku_pro/entities/notificaciones/services/notificaciones_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_field.dart';
import 'package:sanku_pro/presentation/widgets/widget_main_layout.dart';

class ClasificacionesEditPage extends StatefulWidget {
  final Map<String, dynamic> args;

  const ClasificacionesEditPage({super.key, required this.args});

  @override
  State<ClasificacionesEditPage> createState() =>
      _ClasificacionesEditPageState();
}

class _ClasificacionesEditPageState extends State<ClasificacionesEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _clasificacionController;
  late TextEditingController _mensajeController;
  late bool _envioAutomatico;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _clasificacionController = TextEditingController(
      text: widget.args['clasificacion'] ?? '',
    );
    _mensajeController = TextEditingController(
      text: widget.args['mensaje'] ?? '',
    );
    _envioAutomatico = widget.args['envioAutomatico'] ?? false;
  }

  @override
  void dispose() {
    _clasificacionController.dispose();
    _mensajeController.dispose();
    super.dispose();
  }

  Future<void> _actualizarClasificacion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await updateClasificacionDeNotificacion(widget.args['id'], {
        "clasificacion": _clasificacionController.text.trim(),
        "mensaje": _mensajeController.text.trim(),
        "envioAutomatico": _envioAutomatico,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clasificación actualizada exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetAppBar(
        title: 'EDITAR CLASIFICACIÓN',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: WidgetMainLayout(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            children: [
              WidgetField(
                controller: _clasificacionController,
                labelText: 'Clasificación',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingrese una clasificación';
                  }
                  return null;
                },
              ),

              // Campo Mensaje usando WidgetField
              WidgetField(
                controller: _mensajeController,
                labelText: 'Mensaje',
                maxLines: 5,
                minLines: 3,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingrese un mensaje';
                  }
                  return null;
                },
              ),

              // Switch Envío Automático
              SwitchListTile(
                title: const Text('Envío automático'),
                subtitle: Text(
                  'Las notificaciones se enviarán automáticamente cuando se active este evento',
                  style: AppTextStyles.textTheme.labelLarge,
                ),

                value: _envioAutomatico,
                onChanged: (value) {
                  setState(() {
                    _envioAutomatico = value;
                  });
                },
              ),

              const SizedBox(height: AppDimensions.marginM),

              WidgetButton(
                onPressed: _isLoading ? null : _actualizarClasificacion,
                isLoading: _isLoading,
                text: 'Guardar cambios',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
