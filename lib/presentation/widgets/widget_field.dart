import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';
import 'package:sanku_pro/core/constants/app_text_styles.dart';

class WidgetField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool isPassword;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final bool readOnly;
  final EdgeInsetsGeometry? padding;

  const WidgetField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.isPassword = false,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.onTap,
    this.onChanged,
    this.readOnly = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: AppDimensions.marginM),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        inputFormatters: inputFormatters,
        validator: validator,
        maxLines: isPassword ? 1 : maxLines,
        minLines: minLines,
        keyboardType: keyboardType,
        enabled: enabled,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        style: AppTextStyles.textTheme.bodyLarge,
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelStyle: AppTextStyles.textTheme.labelLarge?.copyWith(
            color: AppColors.textMutedDark,
          ),
          hintStyle: AppTextStyles.textTheme.bodyMedium?.copyWith(
            color: AppColors.textMutedLight,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: maxLines > 1
                ? AppDimensions.paddingM
                : AppDimensions.paddingS,
            horizontal: AppDimensions.paddingM,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            borderSide: BorderSide(color: AppColors.greyLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            borderSide: BorderSide(color: AppColors.primary, width: 1.7),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            borderSide: BorderSide(color: AppColors.greyLight),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            borderSide: BorderSide(color: AppColors.greyLight.withAlpha(50)),
          ),
          errorBorder: OutlineInputBorder(  
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: enabled ? AppColors.surfaceLight : Colors.grey[100],
        ),
      ),
    );
  }
}
