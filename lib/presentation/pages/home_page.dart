import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';
import 'package:sanku_pro/core/constants/app_text_styles.dart';
import 'package:sanku_pro/presentation/components/custom_bottom_app_bar.dart';
import 'package:sanku_pro/presentation/pages/auth/services/auth_firebase_service.dart';
import 'package:sanku_pro/presentation/utils/others/items_colors.dart';
import 'package:sanku_pro/presentation/utils/others/menu_items.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
          Container(
            color: AppColors.backgroundLight,
            padding: EdgeInsets.all(AppDimensions.paddingM),
            width: double.infinity,
            child: Column(
              children: [
                Text(
                  "Bienvenido, ${authService.value.currentUser!.displayName}",
                ),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: List.generate(itemsHastaVerMas.length, (index) {
                    final item = itemsHastaVerMas[index];

                    return Center(
                      child: GestureDetector(
                        onTap: () {
                          if (item['action'] != null) {
                            item['action'](context); // usa la lista correcta
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingL,
                                vertical: AppDimensions.paddingS,
                              ),
                              decoration: BoxDecoration(
                                color: ItemsColors.bgThreeLight,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusM,
                                ),
                              ),
                              child: Icon(
                                item['icon'],
                                size: 24,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              item['label'],
                              textAlign: TextAlign.center,
                              style: AppTextStyles.textTheme.labelLarge,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(children: [Text('Horarios')]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }
}
