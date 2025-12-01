import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';
import 'package:sanku_pro/core/constants/app_text_styles.dart';

class WidgetFieldDatePicker extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onDateChanged; // opcional

  const WidgetFieldDatePicker({
    super.key,
    required this.controller,
    required this.label,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateChanged,
  });

  @override
  State<WidgetFieldDatePicker> createState() => _WidgetFieldDatePickerState();
}

class _WidgetFieldDatePickerState extends State<WidgetFieldDatePicker> {
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.initialDate ?? DateTime(2000),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
    );

    if (picked != null) {
      final formatted = DateFormat('yyyy-MM-dd').format(picked);
      widget.controller.text = formatted;
      widget.onDateChanged?.call(picked);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: _pickDate,
        child: AbsorbPointer(
          child: TextField(
            controller: widget.controller,
            readOnly: true,
            style: AppTextStyles.textTheme.bodyLarge,
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: AppTextStyles.textTheme.labelLarge?.copyWith(
                color: AppColors.textMutedDark,
              ),
              suffixIcon: Icon(Icons.calendar_month, color: AppColors.primary),
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
              filled: true,
              fillColor: AppColors.surfaceLight,
            ),
          ),
        ),
      ),
    );
  }
}
