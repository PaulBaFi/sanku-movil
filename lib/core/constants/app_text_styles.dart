import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';

class AppTextStyles {
  // 🌞 Tema claro
  static final TextTheme textTheme = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.textLight,
      fontFamily: 'Poppins',
    ),
    titleMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textLight,
      fontFamily: 'Poppins',
    ),
    bodyMedium: TextStyle(
      fontSize: AppDimensions.fontMedium,
      color: AppColors.textMutedLight,
      fontFamily: 'Poppins',
    ),
    labelLarge: TextStyle(
      fontSize: AppDimensions.fontSmall,
      color: AppColors.textMutedLight,
      fontFamily: 'Poppins',
    ),
  );

  // 🌚 Tema oscuro
  static final TextTheme textThemeDark = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.textDark,
      fontFamily: 'Poppins',
    ),
    titleMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textDark,
      fontFamily: 'Poppins',
    ),
    bodyMedium: TextStyle(
      fontSize: AppDimensions.fontMedium,
      color: AppColors.textMutedDark,
      fontFamily: 'Poppins',
    ),
    labelLarge: TextStyle(
      fontSize: AppDimensions.fontSmall,
      color: AppColors.textMutedDark,
      fontFamily: 'Poppins',
    ),
  );
}
