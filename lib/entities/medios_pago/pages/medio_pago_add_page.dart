import 'dart:io' show File;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';
import 'package:sanku_pro/core/constants/app_strings.dart';
import 'package:sanku_pro/entities/medios_pago/services/medios_pago_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_field.dart';

class MedioPagoAddPage extends StatefulWidget {
  const MedioPagoAddPage({super.key});

  @override
  State<MedioPagoAddPage> createState() => _MedioPagoAddPageState();
}

class _MedioPagoAddPageState extends State<MedioPagoAddPage> {
  final nombreController = TextEditingController();
  final imagenController = TextEditingController();

  bool _isLoading = false;

  File? imageFile; // Para Android / iOS / Desktop
  Uint8List? webImageBytes; // Para Web

  Future<XFile?> getImage() async {
    final ImagePicker picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.gallery);
  }

  void _cargarImagen() async {
    final XFile? pickedImage = await getImage();

    if (pickedImage != null) {
      if (kIsWeb) {
        // Web → usar bytes
        final bytes = await pickedImage.readAsBytes();
        setState(() {
          webImageBytes = bytes;
        });
      } else {
        // Mobile / Desktop → usar File
        setState(() {
          imageFile = File(pickedImage.path);
        });
      }
    }
  }

  Future<void> _saveMedioPago() async {
    final nombre = nombreController.text.trim();
    final imagen = imagenController.text.trim();

    if (nombre.isEmpty || imagen.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorCamposIncompletos)),
      );
      return;
    }

    setState(() => _isLoading = true);

    await addMedioPago({"nombre": nombre, "imagen": imagen});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Medio de pago agregado correctamente")),
      );
      context.pop();
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    nombreController.dispose();
    imagenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetAppBar(title: 'AGREGAR MEDIO DE PAGO'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WidgetField(
              controller: nombreController,
              labelText: "Nombre del medio de pago",
            ),
            const SizedBox(height: 20),
            //WidgetField(controller: imagenController, labelText: "URL de la imagen"),
            ElevatedButton(
              onPressed: _cargarImagen,
              child: const Text('Cargar imagen'),
            ),
            const SizedBox(height: 20),
            if (kIsWeb && webImageBytes != null)
              Image.memory(
                webImageBytes!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.contain,
              )
            else if (!kIsWeb && imageFile != null)
              Image.file(
                imageFile!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.contain,
              )
            else
              Container(
                margin: const EdgeInsets.all(10),
                height: 200,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppDimensions.radiusS),
                  ),
                ),
              ),
            const SizedBox(height: 25),
            WidgetButton(
              isLoading: _isLoading,
              text: "Guardar medio de pago",
              onPressed: _saveMedioPago,
            ),
          ],
        ),
      ),
    );
  }
}
