import 'package:flutter/material.dart';

import '../../../core/constants/meal_types.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_add_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/database/daos/meal_plan_dao.dart';
import '../../../data/database/enums.dart';
import '../../diario/widgets/add_entry_options_sheet.dart';
import '../../diario/widgets/food_search_sheet.dart';
import 'plan_entry_tile.dart';
import 'plan_food_quantity_sheet.dart';
import 'plan_recipe_picker_sheet.dart';

// The Plan semanal analogue of the Diario's MealSectionCard: same layout and
// add-entry flow, but for a given (date, mealType) slot in MealPlanEntries
// instead of the current day's DiaryEntries. AddEntryOptionsSheet and
// FoodSearchSheet are reused as-is from the Diario feature — neither writes
// to DiaryDao, they just return a choice/a Food for the caller to act on.
class PlanMealSectionCard extends StatelessWidget {
  const PlanMealSectionCard({
    super.key,
    required this.date,
    required this.mealType,
    required this.entries,
  });

  final DateTime date;
  final MealType mealType;
  final List<MealPlanEntryDisplay> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmpty = entries.isEmpty;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(mealType.icon, size: 18, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  mealType.label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(letterSpacing: 0.6),
                ),
              ),
            ],
          ),
          if (isEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(left: 48),
              child: Text('Nada planeado', style: theme.textTheme.bodyMedium),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppAddButton(label: 'Añadir', onPressed: () => _addEntry(context)),
          ] else ...[
            const Divider(height: AppSpacing.lg),
            for (var i = 0; i < entries.length; i++) ...[
              PlanEntryTile(display: entries[i]),
              if (i != entries.length - 1)
                Divider(height: AppSpacing.lg, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
            ],
            const SizedBox(height: AppSpacing.sm),
            AppAddButton(label: 'Añadir', onPressed: () => _addEntry(context)),
          ],
        ],
      ),
    );
  }

  Future<void> _addEntry(BuildContext context) async {
    final action = await AddEntryOptionsSheet.show(context);
    if (action == null || !context.mounted) return;

    switch (action) {
      case AddEntryAction.food:
        final food = await FoodSearchSheet.show(context);
        if (food != null && context.mounted) {
          await PlanFoodQuantitySheet.showAdd(context, food: food, date: date, mealType: mealType);
        }
      case AddEntryAction.recipe:
        await PlanRecipePickerSheet.show(context, date: date, mealType: mealType);
    }
  }
}
