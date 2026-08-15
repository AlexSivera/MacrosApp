import 'package:flutter/material.dart';

import '../../../core/constants/meal_types.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/database/daos/diary_dao.dart';
import '../../../data/database/enums.dart';
import 'add_entry_options_sheet.dart';
import 'custom_food_form_sheet.dart';
import 'diary_entry_tile.dart';
import 'food_quantity_sheet.dart';
import 'food_search_sheet.dart';
import 'recipe_picker_sheet.dart';
import 'save_meal_as_recipe_sheet.dart';

class MealSectionCard extends StatelessWidget {
  const MealSectionCard({super.key, required this.mealType, required this.entries});

  final MealType mealType;
  final List<DiaryEntryDisplay> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalKcal = entries.fold(0.0, (sum, e) => sum + e.entry.kcal);
    final isEmpty = entries.isEmpty;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  mealType.label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(letterSpacing: 0.6),
                ),
              ),
              if (!isEmpty) ...[
                Text('${totalKcal.round()} kcal', style: theme.textTheme.bodyMedium),
                IconButton(
                  icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                  tooltip: 'Guardar como receta',
                  onPressed: () => SaveMealAsRecipeSheet.show(
                    context,
                    entries: entries,
                    mealType: mealType,
                  ),
                ),
              ],
            ],
          ),
          if (isEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text('Sin registrar', style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Añadir'),
                onPressed: () => _addEntry(context, mealType),
              ),
            ),
          ] else ...[
            const Divider(height: AppSpacing.lg),
            for (final entry in entries) DiaryEntryTile(display: entry),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Añadir'),
                onPressed: () => _addEntry(context, mealType),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Orchestrates the add-entry flow with *this* card's context, which
  // outlives the transient AddEntryOptionsSheet — using the sheet's own
  // context here would leave `context.mounted` false by the time a search
  // or form sheet returns a result, silently dropping the entry.
  static Future<void> _addEntry(BuildContext context, MealType mealType) async {
    final action = await AddEntryOptionsSheet.show(context);
    if (action == null || !context.mounted) return;

    switch (action) {
      case AddEntryAction.food:
        final food = await FoodSearchSheet.show(context);
        if (food != null && context.mounted) {
          await FoodQuantitySheet.showAdd(context, food: food, mealType: mealType);
        }
      case AddEntryAction.recipe:
        await RecipePickerSheet.show(context, mealType: mealType);
      case AddEntryAction.customFood:
        final food = await CustomFoodFormSheet.show(context);
        if (food != null && context.mounted) {
          await FoodQuantitySheet.showAdd(context, food: food, mealType: mealType);
        }
    }
  }
}
