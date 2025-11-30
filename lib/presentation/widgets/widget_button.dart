import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';

class WidgetButton extends StatelessWidget {
  final bool isLoading;
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color? disabledBackgroundColor;
  final Color? disabledTextColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? letterSpacing;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final BorderSide? borderSide;
  final double? elevation;
  final IconData? icon;
  final IconData? suffixIcon;
  final double? iconSize;
  final double? iconSpacing;
  final double? minWidth;
  final double? minHeight;
  final bool expanded;

  const WidgetButton({
    super.key,
    this.isLoading = false,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AppColors.secondary,
    this.textColor = AppColors.surfaceLight,
    this.disabledBackgroundColor,
    this.disabledTextColor,
    this.fontSize = 14,
    this.fontWeight,
    this.letterSpacing = 0.5,
    this.padding,
    this.borderRadius,
    this.borderSide,
    this.elevation,
    this.icon,
    this.suffixIcon,
    this.iconSize = 20,
    this.iconSpacing = 8,
    this.minWidth,
    this.minHeight,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        disabledBackgroundColor:
            disabledBackgroundColor ?? backgroundColor.withAlpha(128),
        disabledForegroundColor: disabledTextColor ?? textColor.withAlpha(128),
        padding:
            padding ??
            const EdgeInsets.symmetric(
              vertical: AppDimensions.paddingM,
              horizontal: AppDimensions.paddingXL,
            ),
        textStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: letterSpacing,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          side: borderSide ?? BorderSide.none,
        ),
        elevation: elevation ?? 0,
        minimumSize: minWidth != null || minHeight != null
            ? Size(minWidth ?? 0, minHeight ?? 0)
            : null,
      ),
      child: isLoading
          ? SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: textColor,
              ),
            )
          : _buildContent(),
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _buildContent() {
    if (icon == null && suffixIcon == null) {
      return Text(text);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: iconSize),
          SizedBox(width: iconSpacing),
        ],
        Text(text),
        if (suffixIcon != null) ...[
          SizedBox(width: iconSpacing),
          Icon(suffixIcon, size: iconSize),
        ],
      ],
    );
  }
}

class WidgetButtonNeutral extends StatelessWidget {
  final bool isLoading;
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color? disabledBackgroundColor;
  final Color? disabledTextColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? letterSpacing;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final BorderSide? borderSide;
  final double? elevation;
  final IconData? icon;
  final IconData? suffixIcon;
  final double? iconSize;
  final double? iconSpacing;
  final double? minWidth;
  final double? minHeight;
  final bool expanded;

  const WidgetButtonNeutral({
    super.key,
    this.isLoading = false,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFFF5F7FB),
    this.textColor = const Color(0xFF4A5565),
    this.disabledBackgroundColor,
    this.disabledTextColor,
    this.fontSize,
    this.fontWeight,
    this.letterSpacing,
    this.padding,
    this.borderRadius,
    this.borderSide,
    this.elevation,
    this.icon,
    this.suffixIcon,
    this.iconSize,
    this.iconSpacing,
    this.minWidth,
    this.minHeight,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return WidgetButton(
      isLoading: isLoading,
      text: text,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      textColor: textColor,
      disabledBackgroundColor: disabledBackgroundColor,
      disabledTextColor: disabledTextColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      padding: padding,
      borderRadius: borderRadius,
      borderSide: borderSide,
      elevation: elevation,
      icon: icon,
      suffixIcon: suffixIcon,
      iconSize: iconSize,
      iconSpacing: iconSpacing,
      minWidth: minWidth,
      minHeight: minHeight,
      expanded: expanded,
    );
  }
}

class WidgetButtonAlert extends StatelessWidget {
  final bool isLoading;
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color? disabledBackgroundColor;
  final Color? disabledTextColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? letterSpacing;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final BorderSide? borderSide;
  final double? elevation;
  final IconData? icon;
  final IconData? suffixIcon;
  final double? iconSize;
  final double? iconSpacing;
  final double? minWidth;
  final double? minHeight;
  final bool expanded;

  const WidgetButtonAlert({
    super.key,
    this.isLoading = false,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFFFFEDF1),
    this.textColor = const Color(0xffFF2056),
    this.disabledBackgroundColor,
    this.disabledTextColor,
    this.fontSize,
    this.fontWeight,
    this.letterSpacing,
    this.padding,
    this.borderRadius,
    this.borderSide,
    this.elevation,
    this.icon,
    this.suffixIcon,
    this.iconSize,
    this.iconSpacing,
    this.minWidth,
    this.minHeight,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return WidgetButton(
      isLoading: isLoading,
      text: text,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      textColor: textColor,
      disabledBackgroundColor: disabledBackgroundColor,
      disabledTextColor: disabledTextColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      padding: padding,
      borderRadius: borderRadius,
      borderSide: borderSide,
      elevation: elevation,
      icon: icon,
      suffixIcon: suffixIcon,
      iconSize: iconSize,
      iconSpacing: iconSpacing,
      minWidth: minWidth,
      minHeight: minHeight,
      expanded: expanded,
    );
  }
}
