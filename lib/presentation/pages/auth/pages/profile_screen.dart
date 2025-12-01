import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';
import 'package:sanku_pro/core/routes/app_routes_index.dart';
import 'package:sanku_pro/presentation/pages/auth/services/auth_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  String errorMessage = '';

  void logout() async {
    try {
      await authService.value.signOut();
      if (!mounted) return;
      context.go(AppRoutes.welcome);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.message ?? 'Ocurrió un error';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.value.currentUser;

    return Scaffold(
      appBar: WidgetAppBar(title: 'Volver'),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(AppDimensions.marginM),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con avatar y nombre
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Perfil de usuario',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          // Avatar con iniciales
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey[300],
                            child: Text(
                              _getInitials(user?.displayName ?? 'Usuario'),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          // Nombre y rol
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.displayName ?? 'Usuario',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Administrador',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Menú de opciones
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert),
                            onSelected: (value) {
                              if (value == 'cerrar_sesion') {
                                logout();
                              } else if (value == 'cambiar_cuenta') {
                                // Implementar cambio de cuenta
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'cerrar_sesion',
                                child: Text('Cerrar sesión'),
                              ),
                              PopupMenuItem(
                                value: 'cambiar_cuenta',
                                child: Text('Cambiar de cuenta'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 8),

                // Mi cuenta
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sectionTitle(title: "Mi cuenta"),
                      SizedBox(height: 16),
                      _buildInfoRow('Correo', user?.email ?? 'No definido'),
                      SizedBox(height: 12),
                      _buildInfoRow('Contraseña', '**********'),
                      SizedBox(height: 16),
                      sectionTitle(title: "Configuración"),
                      SizedBox(height: 16),
                      _textButton(() {
                        context.push(AppRoutes.changePassword);
                      }, 'Cambiar contraseña'),
                      SizedBox(height: 12),
                      _textButton(() {
                        context.push(AppRoutes.forgetPassword);
                      }, 'Olvidé mi contraseña'),
                      SizedBox(height: 12),
                      _textButton(() {
                        context.push(AppRoutes.resetPassword);
                      }, 'Reestablecer mi contraseña'),
                      SizedBox(height: 12),
                      _textButton(() {
                        context.push(AppRoutes.updateUsername);
                      }, 'Actualizar mi nombre de usuario'),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Botones de acción
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () {
                          context.push(AppRoutes.deleteAccount);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Eliminar mi cuenta permanentemente',
                          style: TextStyle(color: Colors.pink, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),

                // Footer
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Versión 1.13.0',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'SANKU © 2025  Todos los derechos reservados',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 20),
                      InkWell(
                        onTap: logout,
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Cerrar sesión',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 14,
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
          ),
        ),
      ),
    );
  }

  SizedBox _textButton(onPressed, String text) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textMutedLight, // Color del texto e ícono
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(text, style: TextStyle(fontSize: 14),), const Icon(Icons.arrow_forward_ios_rounded)],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    List<String> names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'U';
  }
}

// ignore: camel_case_types
class sectionTitle extends StatelessWidget {
  const sectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';
import 'package:sanku_pro/presentation/pages/auth/pages/change_password_screen.dart';
import 'package:sanku_pro/presentation/pages/auth/pages/delete_account_screen.dart';
import 'package:sanku_pro/presentation/pages/auth/pages/reset_password_screen.dart';
import 'package:sanku_pro/presentation/pages/auth/pages/update_username_screen.dart';
import 'package:sanku_pro/presentation/pages/auth/pages/welcome_screen.dart';
import 'package:sanku_pro/presentation/pages/auth/services/auth_firebase_service.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_main_layout.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  String errorMessage = '';

  void popPage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen()),
      (route) => false,
    );
  }

  void logout() async {
    try {
      await authService.value.signOut();
      // AppData.navBarCurrentIndexNotifier.value = 0;
      // AppData.onboardingCurrentIndexNotifier.value = 0;
      if (!mounted) return;

      popPage();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.message ?? 'An error occurred';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetAppBar(title: 'Perfil de usuario'),
      body: WidgetMainLayout(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            children: [
              Text(
                authService.value.currentUser!.displayName ?? "Nombre de usuario indefinido",
              ),
              Text(authService.value.currentUser!.email ?? "Email indefinido"),
              SizedBox(height: 20.0),
              ElevatedButton(onPressed: logout, child: Text('Cerrar sesión')),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (e) => const ResetPasswordScreen(),
                    ),
                  );
                },
                child: Text('Reset password'),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (e) => const ChangePasswordScreen(),
                    ),
                  );
                },
                child: Text('Change password'),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (e) => const UpdateUsernameScreen(),
                    ),
                  );
                },
                child: Text('Update username'),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (e) => const DeleteAccountScreen(),
                    ),
                  );
                },
                child: Text('Delete account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
