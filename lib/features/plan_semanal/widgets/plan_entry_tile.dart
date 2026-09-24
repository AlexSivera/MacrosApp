import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/database/daos/meal_plan_dao.dart';
import '../../../data/database/database_provider.dart';
import '../../../services/nutrition_engine/meal_plan_macros_calculator.dart';
import '../providers/meal_plan_providers.dart';
import 'plan_food_quantity_sheet.dart';
import 'plan_move_entry_sheet.dart';
import 'plan_recipe_quantity_sheet.dart';

// One food/recipe row in a meal section (Diario or Plan). The leading circle
// ticks it off as eaten (snapshotting its macros) or back to planned; swipe
// left or "Eliminar" deletes it with a "Deshacer" snackbar.
class PlanEntryTile extends ConsumerWidget {
  const PlanEntryTile({super.key, required this.display});

  final MealPlanEntryDisplay display;

  String _subtitle() {
    final entry = display.entry;
    var quantity = '';
    if (entry.quantityGrams != null && entry.recipeId == null) {
      quantity = '${entry.quantityGrams!.round()} g';
    } else if (entry.servings != null) {
      final s = entry.servings!;
      quantity = s == 1 ? '1 ración' : '${formatDecimal(s)} raciones';
    }
    if (entry.isEaten) return quantity;
    return quantity.isEmpty ? 'Planeado' : '$quantity · planeado';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final entry = display.entry;
    final macros =
        snapshotMacros(entry) ?? ref.watch(entryMacrosProvider(entry)).valueOrNull;
    final muted = !entry.isEaten;

    return Dismissible(
      key: ValueKey('entry-${entry.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.onErrorContainer),
      ),
      confirmDismiss: (_) async {
        await _delete(context, ref);
        return true;
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          onTap: () => _handleAction(context, ref, 'edit'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                _EatenToggle(
                  eaten: entry.isEaten,
                  onTap: () => _handleAction(context, ref, entry.isEaten ? 'planned' : 'eaten'),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AnimatedOpacity(
                    opacity: muted ? 0.6 : 1,
                    duration: AppMotion.of(context, AppMotion.fast),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          display.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(_subtitle(), style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                // Reserves the pill's space while a planned entry's live
                // macros load, so the row doesn't jump when they arrive.
                AnimatedSwitcher(
                  duration: AppMotion.of(context, AppMotion.fast),
                  child: macros == null
                      ? const SizedBox(width: 64, key: ValueKey('loading'))
                      : Container(
                          key: const ValueKey('kcal'),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            '${macros.kcal.round()} kcal',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: muted ? theme.colorScheme.onSurfaceVariant : null,
                            ),
                          ),
                        ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (action) => _handleAction(context, ref, action),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: entry.isEaten ? 'planned' : 'eaten',
                      child: Text(entry.isEaten ? 'Marcar como no comido' : 'Marcar como comido'),
                    ),
                    const PopupMenuItem(value: 'edit', child: Text('Editar cantidad')),
                    const PopupMenuItem(value: 'move', child: Text('Mover')),
                    const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    // Grabbed before the delete: this tile is gone from the tree right after.
    final messenger = ScaffoldMessenger.of(context);
    final deleted = display.entry;
    await db.mealPlanDao.deleteEntry(deleted.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('${display.label} eliminado'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () => db.mealPlanDao.restoreEntry(deleted),
        ),
      ));
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref, String action) async {
    final db = ref.read(appDatabaseProvider);
    final entry = display.entry;

    switch (action) {
      case 'eaten':
        await db.mealPlanDao.markEaten(entry.id);
      case 'planned':
        await db.mealPlanDao.markPlanned(entry.id);
      case 'edit':
        if (entry.recipeId != null) {
          final recipe = await db.recipesDao.getById(entry.recipeId!);
          if (recipe != null && context.mounted) {
            await PlanRecipeQuantitySheet.showEdit(context, recipe: recipe, entry: entry);
          }
        } else if (entry.foodId != null) {
          final food = await db.foodsDao.getById(entry.foodId!);
          if (food != null && context.mounted) {
            await PlanFoodQuantitySheet.showEdit(context, food: food, entry: entry);
          }
        }
      case 'move':
        if (context.mounted) {
          await PlanMoveEntrySheet.show(context, entryId: entry.id, currentDate: entry.date);
        }
      case 'delete':
        if (context.mounted) await _delete(context, ref);
    }
  }
}

// The "¿Comido?" circle: outlined while planned, filled with a check once
// eaten — the fill and the check scale in rather than snapping.
class _EatenToggle extends StatelessWidget {
  const _EatenToggle({required this.eaten, required this.onTap});

  final bool eaten;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = AppMotion.of(context, AppMotion.fast);
    return Semantics(
      button: true,
      checked: eaten,
      label: eaten ? 'Comido' : 'Marcar como comido',
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        child: AnimatedContainer(
          duration: duration,
          curve: AppMotion.curve,
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: eaten ? theme.colorScheme.primary : Colors.transparent,
            border: Border.all(
              color: eaten ? theme.colorScheme.primary : theme.colorScheme.outline,
              width: 2,
            ),
          ),
          child: AnimatedSwitcher(
            duration: duration,
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: eaten
                ? Icon(
                    Icons.check_rounded,
                    key: const ValueKey('on'),
                    size: 16,
                    color: theme.colorScheme.onPrimary,
                  )
                : const SizedBox.shrink(key: ValueKey('off')),
          ),
        ),
      ),
    );
  }
}
