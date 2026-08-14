import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/database/enums.dart';
import 'custom_food_form_sheet.dart';
import 'food_quantity_sheet.dart';
import 'food_search_sheet.dart';
import 'recipe_picker_sheet.dart';

// The fast add-entry entry point tapped from a meal section's "+ Añadir".
// "Añadir receta" and "Añadir comida guardada" both open the same recipe
// picker — a saved meal *is* a Recipe in this app, so there's no separate
// concept or table for it, just two discoverable labels for one flow.
class AddEntryOptionsSheet extends StatelessWidget {
  const AddEntryOptionsSheet({super.key, required this.mealType});

  final MealType mealType;

  static Future<void> show(BuildContext context, {required MealType mealType}) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => AddEntryOptionsSheet(mealType: mealType),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.restaurant_outlined),
              title: const Text('Añadir alimento'),
              onTap: () async {
                Navigator.of(context).pop();
                final food = await FoodSearchSheet.show(context);
                if (food != null && context.mounted) {
                  await FoodQuantitySheet.showAdd(context, food: food, mealType: mealType);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('Añadir receta'),
              onTap: () {
                Navigator.of(context).pop();
                RecipePickerSheet.show(context, mealType: mealType);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_outline),
              title: const Text('Añadir comida guardada'),
              onTap: () {
                Navigator.of(context).pop();
                RecipePickerSheet.show(context, mealType: mealType);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_box_outlined),
              title: const Text('Crear alimento personalizado'),
              onTap: () async {
                Navigator.of(context).pop();
                final food = await CustomFoodFormSheet.show(context);
                if (food != null && context.mounted) {
                  await FoodQuantitySheet.showAdd(context, food: food, mealType: mealType);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
