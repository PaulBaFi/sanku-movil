import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';

class WidgetDetailsLayout extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color backgroundColor;
  final BoxShadow? shadow;
  final BorderRadius? borderRadius;

  const WidgetDetailsLayout({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.paddingXL),
    this.margin = EdgeInsets.zero,
    this.backgroundColor = AppColors.surfaceLight,
    this.shadow,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [shadow ?? AppColors.softShadowLight],
        borderRadius: borderRadius ??
            const BorderRadius.all(
              Radius.circular(AppDimensions.radiusXL),
            ),
      ),
      child: child,
    );
  }
}
