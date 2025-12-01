import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';
import 'package:sanku_pro/core/constants/app_text_styles.dart';
import 'package:sanku_pro/presentation/components/custom_scaffold.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
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
      child: Column(
        children: [
          Expanded(child: SizedBox(height: 10)),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Olvidé mi contraseña',
                    style: AppTextStyles.textTheme.headlineLarge,
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Envía un código de confirmación para reestablecer tu contraseña.',
                    style: AppTextStyles.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.0),
                  SizedBox(height: AppDimensions.marginL),
                  WidgetField(
                    controller: _emailController,
                    labelText: 'Correo electrónico',
                  ),
                  WidgetButton(
                    onPressed: () {},
                    text: 'Enviar código de confirmación',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
