import 'package:flutter/material.dart';

class AppColors {
  // 🎯 Principales
  static const Color primary = Color(0xFFFFA726);
  static const Color secondary = Color(0xFFFFB84C);
  static const Color accent = Color(0xFFFFC107);

  // 🧱 Fondos
  static const Color backgroundLight = Color(0xFFFFFBF5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // 📝 Textos
  static const Color textLight = Color(0xFF3E2E1E);
  static const Color textMutedLight = Color(0xFF8B7765);
  static const Color textDark = Color(0xFFF5EDE0);
  static const Color textMutedDark = Color(0xFFCFC1B4);

  // ⚠️ Estados
  static const Color success = Color(0xFF1EBC48);
  static const Color warning = Color(0xFFFBBC05);
  static const Color error = Color(0xFFFF2056);
  static const Color info = Color(0xFF1877F2);

  // 🌗 Neutros
  static const Color greyLight = Color(0xFFEAE2D8);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyDark = Color(0xFF2A2A2A);

  // 💡 Sombras
  static const BoxShadow softShadowLight = BoxShadow(
    color: Colors.black12,
    blurRadius: 10,
    offset: Offset(0, 4),
  );
  static const BoxShadow softShadowDark = BoxShadow(
    color: Colors.black26,
    blurRadius: 12,
    offset: Offset(0, 6),
  );
}
