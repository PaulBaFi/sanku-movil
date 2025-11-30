import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';

class WidgetMainLayout extends StatelessWidget {
  final Widget child;

  const WidgetMainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(AppDimensions.marginS),
      padding: EdgeInsets.symmetric(vertical: AppDimensions.marginS),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.radiusXL)),
      ),
      child: child,
    );
  }
}
