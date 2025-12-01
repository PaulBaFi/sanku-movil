import 'package:flutter/material.dart';
import 'package:sanku_pro/core/theme/theme_controller.dart';
import 'package:sanku_pro/services/preferences_services.dart';

class ConfiguracionesPage extends StatefulWidget {
  const ConfiguracionesPage({super.key});

  @override
  State<ConfiguracionesPage> createState() => _ConfiguracionesPageState();
}

class _ConfiguracionesPageState extends State<ConfiguracionesPage> {
  final PreferencesService _prefsService = PreferencesService();
  String _currentTheme = 'system';

  @override
  void initState() {
    super.initState();
    _currentTheme = _prefsService.getThemeMode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Tema claro'),
            trailing: Radio<String>(
              value: 'light',
              // ignore: deprecated_member_use
              groupValue: _currentTheme,
              // ignore: deprecated_member_use
              onChanged: (value) {
                ThemeController.changeTheme(value!);
                setState(() {
                  _currentTheme = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Tema oscuro'),
            trailing: Radio<String>(
              value: 'dark',
              // ignore: deprecated_member_use
              groupValue: _currentTheme,
              // ignore: deprecated_member_use
              onChanged: (value) {
                ThemeController.changeTheme(value!);
                setState(() {
                  _currentTheme = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Tema del sistema'),
            trailing: Radio<String>(
              value: 'system',
              // ignore: deprecated_member_use
              groupValue: _currentTheme,
              // ignore: deprecated_member_uses, deprecated_member_use
              onChanged: (value) {
                ThemeController.changeTheme(value!);
                setState(() {
                  _currentTheme = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
