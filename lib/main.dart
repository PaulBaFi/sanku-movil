import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_strings.dart';

// Inicializar Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:sanku_pro/firebase_options.dart';

// Theme
import 'package:sanku_pro/core/theme/app_theme.dart';

// Sistema de navegación
import 'package:sanku_pro/core/routes/app_route_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key}); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appTitle,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: RouteManager.router,
    );
  }
}
