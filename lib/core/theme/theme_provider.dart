import 'package:flutter/material.dart';
import 'app_theme.dart';

// Enum para los dos temas disponibles
enum AppThemeMode { guinda, azul }

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _currentTheme = AppThemeMode.guinda;
  bool _isDarkMode = false;

  AppThemeMode get currentTheme => _currentTheme;
  bool get isDarkMode => _isDarkMode;

  // Devuelve el ThemeData activo según selección y modo claro/oscuro
  ThemeData get themeData {
    switch (_currentTheme) {
      case AppThemeMode.guinda:
        return _isDarkMode ? AppTheme.guindaDark() : AppTheme.guindaLight();
      case AppThemeMode.azul:
        return _isDarkMode ? AppTheme.azulDark() : AppTheme.azulLight();
    }
  }

  String get themeName =>
      _currentTheme == AppThemeMode.guinda ? 'Guinda (IPN)' : 'Azul (ESCOM)';

  // Cambia entre Guinda y Azul
  void setTheme(AppThemeMode theme) {
    _currentTheme = theme;
    notifyListeners(); // Avisa a todos los widgets que el tema cambió
  }

  // Alterna entre claro y oscuro
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
