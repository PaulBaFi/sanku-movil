import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_strings.dart';
import 'package:intl/date_symbol_data_local.dart';

// Inicializar Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:sanku_pro/core/theme/theme_controller.dart';
import 'package:sanku_pro/firebase_options.dart';

// Theme
import 'package:sanku_pro/core/theme/app_theme.dart';

// Sistema de navegación
import 'package:sanku_pro/core/routes/app_route_manager.dart';

// Servicio de preferencias
import 'package:sanku_pro/services/preferences_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PreferencesService.init();
  await initializeDateFormatting('es', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  ThemeController.loadInitialTheme();

  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final PreferencesService _prefsService = PreferencesService();

  @override
  Widget build(BuildContext context) {
    _prefsService.getThemeMode();

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (_, mode, __) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: AppStrings.appTitle,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode, // 👈 dinámico
          routerConfig: RouteManager.router,
        );
      },
    );
  }
}
