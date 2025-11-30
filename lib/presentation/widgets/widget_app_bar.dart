import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';

class WidgetAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const WidgetAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      foregroundColor: AppColors.secondary,
      title: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppColors.secondary,
          letterSpacing: 2,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      centerTitle: false,
      actions: actions,
      leading: leading,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
