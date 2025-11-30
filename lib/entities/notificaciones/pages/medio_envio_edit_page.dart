import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';
import 'package:sanku_pro/entities/notificaciones/services/notificaciones_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_field.dart';
import 'package:sanku_pro/presentation/widgets/widget_main_layout.dart';

class MedioEnvioEditPage extends StatefulWidget {
  final Map<String, dynamic> args;

  const MedioEnvioEditPage({super.key, required this.args});

  @override
  State<MedioEnvioEditPage> createState() => _MedioEnvioEditPageState();
}

class _MedioEnvioEditPageState extends State<MedioEnvioEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _medioEnvioController;
  late TextEditingController _baseUrlController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _medioEnvioController = TextEditingController(
      text: widget.args['medioEnvio'] ?? '',
    );
    _baseUrlController = TextEditingController(
      text: widget.args['baseUrl'] ?? '',
    );
  }

  @override
  void dispose() {
    _medioEnvioController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  Future<void> _actualizarMedioEnvio() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await updateMedioDeEnvio(widget.args['id'], {
        "medioEnvio": _medioEnvioController.text.trim(),
        "baseUrl": _baseUrlController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medio de envío actualizado exitosamente'),
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
            backgroundColor: Colors.red,
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
        title: 'EDITAR MEDIO DE ENVÍO',
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
                controller: _medioEnvioController,
                labelText: 'Medio de Envío',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingrese el medio de envío';
                  }
                  return null;
                },
              ),

              WidgetField(
                controller: _baseUrlController,
                labelText: 'Base URL',
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingrese la URL base';
                  }
                  // Validación básica de URL
                  final urlPattern = RegExp(
                    r'^https?:\/\/',
                    caseSensitive: false,
                  );
                  if (!urlPattern.hasMatch(value)) {
                    return 'La URL debe comenzar con http:// o https://';
                  }
                  return null;
                },
              ),

              SizedBox(height: AppDimensions.marginL),

              WidgetButton(
                onPressed: _isLoading ? null : _actualizarMedioEnvio,
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
