import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/routes/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/sala.png',
              fit: BoxFit.cover,
            ),
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

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 70,
                        child: ElevatedButton(
                          onPressed: () => context.push(AppRoutes.signin),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: AppColors.surfaceLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20.0),
                              ), // Adjust the value for desired roundness
                            ),
                          ),
                          child: const Text(
                            "Ingresar",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SizedBox(
                        height: 70,
                        child: ElevatedButton(
                          onPressed: () => context.push(AppRoutes.signup),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20.0),
                              ), // Adjust the value for desired roundness
                            ),
                          ),
                          child: const Text(
                            "Registrarse",
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
