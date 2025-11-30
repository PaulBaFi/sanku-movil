import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';
import 'package:sanku_pro/core/constants/app_text_styles.dart';
import 'package:sanku_pro/entities/notificaciones/services/notificaciones_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_field.dart';
import 'package:sanku_pro/presentation/widgets/widget_main_layout.dart';

class ClasificacionesAddPage extends StatefulWidget {
  const ClasificacionesAddPage({super.key});

  @override
  State<ClasificacionesAddPage> createState() =>
      _ClasificacionesAddPageState();
}

class _ClasificacionesAddPageState extends State<ClasificacionesAddPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clasificacionController =
      TextEditingController();
  final TextEditingController _mensajeController = TextEditingController();
  bool _envioAutomatico = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _clasificacionController.dispose();
    _mensajeController.dispose();
    super.dispose();
  }

  Future<void> _guardarClasificacion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await addClasificacionDeNotificacion({
        "clasificacion": _clasificacionController.text.trim(),
        "mensaje": _mensajeController.text.trim(),
        "envioAutomatico": _envioAutomatico,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clasificación agregada exitosamente'),
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
            content: Text('Error al guardar: $e'),
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
        title: 'AÑADIR CLASIFICACIÓN',
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

              Expanded(
                flex: 2,
                child: WidgetButton(
                  onPressed: _isLoading ? null : _guardarClasificacion,
                  isLoading: _isLoading,
                  text: 'Guardar clasificación',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
