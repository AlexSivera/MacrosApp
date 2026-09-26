import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/meal_types.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_add_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../data/database/daos/meal_plan_dao.dart';
import '../../../data/database/database_provider.dart';
import '../../../data/database/enums.dart';
import '../../diario/widgets/add_entry_options_sheet.dart';
import '../../diario/widgets/food_search_sheet.dart';
import '../../diario/widgets/save_meal_as_recipe_sheet.dart';
import '../providers/meal_plan_providers.dart';
import 'plan_entry_tile.dart';
import 'plan_food_quantity_sheet.dart';
import 'plan_recipe_picker_sheet.dart';
import '../../../core/utils/dates.dart';

// The one meal-section card shared by the Diario and the Plan: both are a
// (date, mealType) slot in MealPlanEntries. In the Diario (diaryMode) new
// entries are logged as eaten and the kcal pill counts only what was eaten;
// in the Plan they're added as planned and the pill counts everything.
class PlanMealSectionCard extends ConsumerWidget {
  const PlanMealSectionCard({
    super.key,
    required this.date,
    required this.mealType,
    required this.entries,
    this.diaryMode = false,
    this.canRepeatFromYesterday = false,
  });

  final DateTime date;
  final MealType mealType;
  final List<MealPlanEntryDisplay> entries;
  final bool diaryMode;

  // Shows "Repetir de ayer" on an empty slot when yesterday's same meal had
  // something in it.
  final bool canRepeatFromYesterday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isEmpty = entries.isEmpty;
    final counted = diaryMode ? [for (final e in entries) if (e.entry.isEaten) e] : entries;
    final totalMacros = sumEntryMacros(ref.watch, counted);

    return AppCard(
      // Grows/shrinks smoothly as entries are added or removed instead of
      // the card snapping to its new height.
      child: AnimatedSize(
        duration: AppMotion.of(context, AppMotion.normal),
        curve: AppMotion.curve,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.tint(context),
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
                  if (totalMacros != null && counted.isNotEmpty)
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
                // An empty meal is a single row — header plus its add
                // action — so a fresh day isn't six tall "empty" cards.
                if (isEmpty) AppAddButton(label: 'Añadir', onPressed: () => _addEntry(context)),
              ],
            ),
            if (isEmpty) ...[
              if (canRepeatFromYesterday)
                Padding(
                  padding: const EdgeInsets.only(left: 40, top: AppSpacing.xs),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: const Icon(Icons.replay_rounded, size: 18),
                      label: const Text('Repetir de ayer'),
                      onPressed: () => _repeatFromYesterday(context, ref),
                    ),
                  ),
                ),
            ] else ...[
              const Divider(height: AppSpacing.lg),
              for (var i = 0; i < entries.length; i++) ...[
                // Keyed by entry id so only a newly added row fades in —
                // existing rows keep their state across list rebuilds.
                FadeSlideIn(
                  key: ValueKey(entries[i].entry.id),
                  child: PlanEntryTile(display: entries[i]),
                ),
                if (i != entries.length - 1)
                  Divider(height: AppSpacing.lg, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
              ],
              const SizedBox(height: AppSpacing.sm),
              AppAddButton(label: 'Añadir', onPressed: () => _addEntry(context)),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _repeatFromYesterday(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final copied = await ref.read(appDatabaseProvider).mealPlanDao.copyMeal(
          fromDate: addDays(date, -1),
          toDate: date,
          mealType: mealType,
          eaten: diaryMode,
        );
    messenger.showSnackBar(SnackBar(
      content: Text(copied == 1 ? '1 alimento copiado de ayer' : '$copied alimentos copiados de ayer'),
    ));
  }

  Future<void> _addEntry(BuildContext context) async {
    final action = await AddEntryOptionsSheet.show(context, mealType: mealType);
    if (action == null || !context.mounted) return;

    switch (action) {
      case AddEntryAction.food:
        final food = await FoodSearchSheet.show(context, mealType: mealType);
        if (food != null && context.mounted) {
          await PlanFoodQuantitySheet.showAdd(
            context,
            food: food,
            date: date,
            mealType: mealType,
            eaten: diaryMode,
          );
        }
      case AddEntryAction.recipe:
        await PlanRecipePickerSheet.show(context, date: date, mealType: mealType, eaten: diaryMode);
    }
  }
}
