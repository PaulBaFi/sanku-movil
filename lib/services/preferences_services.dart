import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  static SharedPreferences? _preferences;

  factory PreferencesService() {
    return _instance;
  }

  PreferencesService._internal();

  // Inicializar SharedPreferences
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Tema (ejemplo: 'light', 'dark', 'system')
  Future<void> setThemeMode(String theme) async {
    await _preferences?.setString('theme_mode', theme);
  }

  String getThemeMode() {
    return _preferences?.getString('theme_mode') ?? 'system';
  }

  // Ejemplo de otros datos que podrías necesitar
  Future<void> setLanguage(String language) async {
    await _preferences?.setString('language', language);
  }

  String getLanguage() {
    return _preferences?.getString('language') ?? 'es';
  }

  Future<void> setFirstTime(bool isFirstTime) async {
    await _preferences?.setBool('first_time', isFirstTime);
  }

  bool isFirstTime() {
    return _preferences?.getBool('first_time') ?? true;
  }

  // Limpiar todas las preferencias
  Future<void> clearAll() async {
    await _preferences?.clear();
  }
}