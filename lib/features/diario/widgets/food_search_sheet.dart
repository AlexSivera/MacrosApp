import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../providers/food_search_providers.dart';
import 'custom_food_form_sheet.dart';
import 'food_category_chips.dart';

// Fast food lookup sheet — search the bundled + custom Foods table by name,
// tap a result to hand it back to the caller (add-entry flow, ingredient
// builder). Doesn't itself write anything; quantity entry is a separate step.
class FoodSearchSheet extends ConsumerWidget {
  const FoodSearchSheet({super.key});

  static Future<Food?> show(BuildContext context) {
    return showModalBottomSheet<Food>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const FoodSearchSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(foodSearchResultsProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Buscar alimento', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'p. ej. pollo',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) =>
                    ref.read(foodSearchQueryProvider.notifier).state = value,
              ),
              const SizedBox(height: AppSpacing.md),
              const FoodCategoryChips(),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: resultsAsync.when(
                  data: (foods) {
                    if (foods.isEmpty) {
                      return const _EmptySearchState();
                    }
                    return ListView.separated(
                      itemCount: foods.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
                      itemBuilder: (context, index) {
                        final food = foods[index];
                        return _FoodResultTile(food: food);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error al buscar: $err')),
                ),
              ),
              const Divider(height: AppSpacing.lg),
              OutlinedButton.icon(
                icon: const Icon(Icons.add_box_outlined, size: 18),
                label: const Text('Crear alimento personalizado'),
                onPressed: () async {
                  final food = await CustomFoodFormSheet.show(context);
                  if (food != null && context.mounted) Navigator.of(context).pop(food);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FoodResultTile extends ConsumerWidget {
  const _FoodResultTile({required this.food});

  final Food food;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(food.name, style: theme.textTheme.bodyLarge),
      subtitle: Text(
        '${food.kcalPer100g.round()} kcal · P ${food.proteinPer100g.round()}g · '
        'C ${food.carbsPer100g.round()}g · G ${food.fatPer100g.round()}g  (100g)',
        style: theme.textTheme.bodySmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Only isCustom foods are editable/deletable — the bundled catalog
          // is re-synced from the app on every launch (see
          // food_seeder.dart), so touching one of those rows here would
          // just be overwritten (edit) or reappear (delete) on next launch.
          if (food.isCustom)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (action) => _handleAction(context, ref, action),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Editar')),
                PopupMenuItem(value: 'delete', child: Text('Eliminar')),
              ],
            ),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () => Navigator.of(context).pop(food),
    );
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref, String action) async {
    switch (action) {
      case 'edit':
        await CustomFoodFormSheet.showEdit(context, food: food);
      case 'delete':
        await _delete(context, ref);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    // A recipe ingredient's foodId has no onDelete action (unlike a diary
    // entry's, which sets null) — deleting a food still used by a recipe
    // would hit a real foreign-key-constraint failure, so check first
    // instead of surfacing that as a raw DB error.
    final usedInRecipe = await (db.select(db.recipeIngredients)
          ..where((i) => i.foodId.equals(food.id)))
        .get();
    if (usedInRecipe.isNotEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Este alimento se usa en una receta — quítalo de ahí antes de eliminarlo.'),
        ));
      }
      return;
    }
    await db.foodsDao.deleteFood(food.id);
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No se han encontrado alimentos.\nPrueba a crear uno personalizado.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
