import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/meal_types.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_add_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/database/daos/meal_plan_dao.dart';
import '../../../data/database/enums.dart';
import '../../diario/widgets/add_entry_options_sheet.dart';
import '../../diario/widgets/food_search_sheet.dart';
import '../../diario/widgets/save_meal_as_recipe_sheet.dart';
import '../providers/meal_plan_providers.dart';
import 'plan_entry_tile.dart';
import 'plan_food_quantity_sheet.dart';
import 'plan_recipe_picker_sheet.dart';

// The one meal-section card shared by the Diario and the Plan: both are just
// a (date, mealType) slot in MealPlanEntries now (see meal_plan_entries_table
// .dart's doc comment on why the two features share a single table). Reused
// across both feature folders, same as AddEntryOptionsSheet/FoodSearchSheet
// already were.
class PlanMealSectionCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isEmpty = entries.isEmpty;
    final totalMacros = sumEntryMacros(ref.watch, entries);

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
              if (!isEmpty) ...[
                if (totalMacros != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text('${totalMacros.kcal.round()} kcal', style: theme.textTheme.labelLarge),
                  ),
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
