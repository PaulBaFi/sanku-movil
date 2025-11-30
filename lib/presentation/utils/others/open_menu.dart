import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/constants/app_text_styles.dart';

void openMenu(BuildContext context, List<Map<String, dynamic>> items) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          children: List.generate(items.length, (index) {
            final item = items[index];

            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                item['action'](context);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item['icon'], size: 32, color: AppColors.primary),
                  SizedBox(height: 6),
                  Text(
                    item['label'],
                    textAlign: TextAlign.center,
                    style: AppTextStyles.textTheme.labelLarge,
                  ),
                ],
              ),
            );
          }),
        ),
      );
    },
  );
}
