import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';
import 'package:sanku_pro/core/constants/app_text_styles.dart';
import 'package:sanku_pro/presentation/components/custom_scaffold.dart';
import 'package:sanku_pro/presentation/widgets/widget_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingXL),
        child: Center(
          child: Column(
            children: [
              Text(
                'Envía un código de confirmación para reestablecer tu contraseña.',
                style: AppTextStyles.textTheme.bodyMedium,
              ),
              SizedBox(height: AppDimensions.marginL),
              WidgetField(
                controller: _emailController,
                labelText: 'Correo electrónico',
              ),
              SizedBox(height: AppDimensions.marginL),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Enviar código de confirmación'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
