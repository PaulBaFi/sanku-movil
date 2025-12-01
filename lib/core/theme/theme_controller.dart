import 'package:flutter/material.dart';
import 'package:sanku_pro/services/preferences_services.dart';

class ThemeController {
  static final themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

  static void loadInitialTheme() {
    final prefs = PreferencesService();
    final mode = prefs.getThemeMode();

    switch (mode) {
      case 'light':
        themeMode.value = ThemeMode.light;
        break;
      case 'dark':
        themeMode.value = ThemeMode.dark;
        break;
      default:
        themeMode.value = ThemeMode.system;
    }
  }

  static Future<void> changeTheme(String mode) async {
    final prefs = PreferencesService();
    await prefs.setThemeMode(mode);

    switch (mode) {
      case 'light':
        themeMode.value = ThemeMode.light;
        break;
      case 'dark':
        themeMode.value = ThemeMode.dark;
        break;
      default:
        themeMode.value = ThemeMode.system;
    }
  }
}
