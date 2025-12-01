import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/core/routes/app_routes.dart';
import 'package:sanku_pro/presentation/widgets/widget_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/sala.png', fit: BoxFit.contain),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),

                Image.asset(
                  'assets/logo_sanku.png',
                  height: 80,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 20),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: WidgetButton(
                          onPressed: () => context.push(AppRoutes.signin),
                          text: "Ingresar",
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: WidgetButton(
                          onPressed: () => context.push(AppRoutes.signup),
                          text: "Registrarse",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
