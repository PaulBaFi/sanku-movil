import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';
import 'package:sanku_pro/core/constants/app_text_styles.dart';

class WidgetDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const WidgetDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        onChanged: onChanged,
        items: items
            .map(
              (e) => DropdownMenuItem<String>(
                value: e,
                child: Text(e, style: AppTextStyles.textTheme.labelLarge),
              ),
            )
            .toList(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.textTheme.labelLarge?.copyWith(
            color: AppColors.textMutedDark,
          ),

          filled: true,
          fillColor: AppColors.surfaceLight,

          contentPadding: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingS,
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
        ),
      ),
    );
  }
}
