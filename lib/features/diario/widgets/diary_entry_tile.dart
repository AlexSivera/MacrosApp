import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/database/daos/diary_dao.dart';
import '../../../data/database/database_provider.dart';
import 'food_quantity_sheet.dart';
import 'move_entry_sheet.dart';
import 'recipe_quantity_sheet.dart';

class DiaryEntryTile extends ConsumerWidget {
  const DiaryEntryTile({super.key, required this.display});

  final DiaryEntryDisplay display;

  String _subtitle() {
    final entry = display.entry;
    if (entry.foodId != null && entry.quantityGrams != null) {
      return '${entry.quantityGrams!.round()} g';
    }
    if (entry.recipeId != null && entry.servings != null) {
      final s = entry.servings!;
      return s == 1 ? '1 ración' : '${_formatServings(s)} raciones';
    }
    return '';
  }

  static String _formatServings(double s) =>
      s == s.roundToDouble() ? s.round().toString() : s.toStringAsFixed(1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final entry = display.entry;
    final subtitle = _subtitle();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: () => _handleAction(context, ref, 'edit'),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      display.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(subtitle, style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text('${entry.kcal.round()} kcal', style: theme.textTheme.labelLarge),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (action) => _handleAction(context, ref, action),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar cantidad')),
                  PopupMenuItem(value: 'move', child: Text('Mover de comida')),
                  PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref, String action) async {
    final db = ref.read(appDatabaseProvider);
    final entry = display.entry;

    switch (action) {
      case 'edit':
        if (entry.foodId != null) {
          final food = await db.foodsDao.getById(entry.foodId!);
          if (food != null && context.mounted) {
            await FoodQuantitySheet.showEdit(context, food: food, entry: entry);
          }
        } else if (entry.recipeId != null) {
          final recipe = await db.recipesDao.getById(entry.recipeId!);
          if (recipe != null && context.mounted) {
            await RecipeQuantitySheet.showEdit(context, recipe: recipe, entry: entry);
          }
        }
      case 'move':
        if (context.mounted) await MoveEntrySheet.show(context, entryId: entry.id);
      case 'delete':
        await db.diaryDao.deleteEntry(entry.id);
    }
  }
}
