import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';
import 'package:sanku_pro/core/constants/app_text_styles.dart';

class WidgetButtonText extends StatelessWidget {
  const WidgetButtonText({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton.icon(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(AppDimensions.paddingS),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
          ),
          icon: const Icon(
            Icons.add,
            color: AppColors.textMutedLight,
            size: 20,
          ),
          label: Text(text, style: AppTextStyles.textTheme.bodyMedium),
          onPressed: onPressed,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
