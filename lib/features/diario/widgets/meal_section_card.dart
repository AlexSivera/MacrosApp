import 'package:flutter/material.dart';

import '../../../core/constants/meal_types.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/database/daos/diary_dao.dart';
import '../../../data/database/enums.dart';
import 'add_entry_options_sheet.dart';
import 'diary_entry_tile.dart';
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
                onPressed: () => AddEntryOptionsSheet.show(context, mealType: mealType),
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
                onPressed: () => AddEntryOptionsSheet.show(context, mealType: mealType),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
