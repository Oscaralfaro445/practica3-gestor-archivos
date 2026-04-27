import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  // ── Tema Guinda (IPN) claro ──────────────────────────────
  static ThemeData guindaLight() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.guindaPrimary,
        primary: AppColors.guindaPrimary,
        onPrimary: AppColors.guindaOnPrimary,
        secondary: AppColors.guindaLight,
        surface: AppColors.guindaSurface,
        error: AppColors.errorColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.guindaPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.guindaPrimary,
        foregroundColor: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: AppColors.guindaLight.withOpacity(0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.guindaPrimary);
          }
          return const IconThemeData(color: Colors.grey);
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.guindaPrimary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ── Tema Guinda (IPN) oscuro ─────────────────────────────
  static ThemeData guindaDark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.guindaPrimary,
        primary: AppColors.guindaLight,
        onPrimary: Colors.white,
        secondary: AppColors.guindaPrimary,
        surface: const Color(0xFF1C1014),
        error: AppColors.errorColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.guindaDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.guindaLight,
        foregroundColor: Colors.white,
      ),
    );
  }

  // ── Tema Azul (ESCOM) claro ──────────────────────────────
  static ThemeData azulLight() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.azulPrimary,
        primary: AppColors.azulPrimary,
        onPrimary: AppColors.azulOnPrimary,
        secondary: AppColors.azulLight,
        surface: AppColors.azulSurface,
        error: AppColors.errorColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.azulPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.azulPrimary,
        foregroundColor: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: AppColors.azulLight.withOpacity(0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.azulPrimary);
          }
          return const IconThemeData(color: Colors.grey);
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.azulPrimary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ── Tema Azul (ESCOM) oscuro ─────────────────────────────
  static ThemeData azulDark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.azulPrimary,
        primary: AppColors.azulLight,
        onPrimary: Colors.white,
        secondary: AppColors.azulPrimary,
        surface: const Color(0xFF0D1520),
        error: AppColors.errorColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.azulDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.azulLight,
        foregroundColor: Colors.white,
      ),
    );
  }
}
