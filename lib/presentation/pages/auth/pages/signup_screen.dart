import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/constants/app_text_styles.dart';
import 'package:sanku_pro/presentation/pages/auth/pages/signin_screen.dart';
import 'package:sanku_pro/presentation/pages/auth/services/auth_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';
import 'package:sanku_pro/presentation/widgets/widget_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;
  String errorMessage = '';

  @override
  void dispose() {
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }

  void signup() async {
    try {
      await authService.value.createAccount(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      if (!mounted) return;
      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() => errorMessage = e.message ?? 'Ocurrió un error');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF7E4),
      body: Column(
        children: [
           Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.asset("assets/planta.png", height: 120),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25, 50, 25, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    children: [
                      Text(
                        'Crear cuenta',
                        style: AppTextStyles.textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 30),

                      WidgetField(
                        labelText: 'Correo electrónico',
                        controller: _controllerEmail,
                        validator: (value) =>
                            (value == null || value.isEmpty)
                                ? 'Ingrese un correo electrónico.'
                                : null,
                      ),

                      WidgetField(
                        labelText: 'Contraseña',
                        controller: _controllerPassword,
                        validator: (value) =>
                            (value == null || value.isEmpty)
                                ? 'Ingrese una contraseña.'
                                : null,
                        isPassword: true,
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Checkbox(
                            value: agreePersonalData,
                            onChanged: (v) => setState(() {
                              agreePersonalData = v!;
                            }),
                            activeColor: AppColors.secondary,
                          ),
                          const Expanded(
                            child: Text(
                              'Acepto el uso de mis datos personales.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: WidgetButton(
                          text: "Crear cuenta",
                          onPressed: () {
                            if (_formSignupKey.currentState!.validate() &&
                                agreePersonalData) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Procesando datos...'),
                                ),
                              );
                              signup();
                            } else if (!agreePersonalData) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Debe aceptar el uso de datos personales',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 40),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('¿Ya tienes una cuenta? ',
                              style: TextStyle(color: Colors.black45)),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SigninScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
