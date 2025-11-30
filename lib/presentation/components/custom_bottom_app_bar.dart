import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';
import 'package:sanku_pro/presentation/pages/auth/pages/profile_screen.dart';
import 'package:sanku_pro/presentation/utils/others/menu_items.dart';
import 'package:sanku_pro/presentation/utils/others/open_menu.dart';

class CustomBottomAppBar extends StatefulWidget {
  const CustomBottomAppBar({super.key});

  @override
  State<CustomBottomAppBar> createState() => _CustomBottomAppBarState();
}

class _CustomBottomAppBarState extends State<CustomBottomAppBar> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.surfaceLight,
      elevation: 8,
      shape: const AutomaticNotchedShape(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXL),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingS,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                openMenu(context, itemsSinVerMas);
              },
              icon: const Icon(
                Icons.drag_indicator_rounded,
                color: AppColors.textLight,
              ),
              tooltip: "Abrir menú principal",
            ),
            Image.asset('assets/logo_sanku.png', fit: BoxFit.contain),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.account_circle_rounded,
                color: AppColors.textLight,
              ),
              tooltip: "Abrir perfil de usuario",
            ),
          ],
        ),
      ),
    );
  }
}
