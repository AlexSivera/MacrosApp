import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/database/enums.dart';
import '../../recetas/providers/recipes_providers.dart';
import '../../recetas/widgets/recipe_filter_chips.dart';
import 'plan_recipe_quantity_sheet.dart';

// "Añadir receta" from a Plan semanal meal slot — the Plan analogue of
// RecipePickerSheet, handing off to PlanRecipeQuantitySheet instead of the
// Diario's. Filter state is local for the same reason as the Diario's
// picker: it starts pre-set to the slot's meal and must never leak onto the
// Recetas tab's own shared filter.
class PlanRecipePickerSheet extends ConsumerStatefulWidget {
  const PlanRecipePickerSheet({super.key, required this.date, required this.mealType});

  final DateTime date;
  final MealType mealType;

  static Future<void> show(
    BuildContext context, {
    required DateTime date,
    required MealType mealType,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PlanRecipePickerSheet(date: date, mealType: mealType),
    );
  }

  @override
  ConsumerState<PlanRecipePickerSheet> createState() => _PlanRecipePickerSheetState();
}

class _PlanRecipePickerSheetState extends ConsumerState<PlanRecipePickerSheet> {
  late RecipeFilter _filter = recipeFilterForMealType(widget.mealType);
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allAsync = ref.watch(recipesWithMacrosProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Añadir receta al plan', style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar en Mis Recetas',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: AppSpacing.md),
              RecipeFilterChips(
                selected: _filter,
                onChanged: (filter) => setState(() => _filter = filter),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: allAsync.when(
                  data: (all) {
                    final recipes = applyRecipeFilter(all, filter: _filter, query: _query);
                    if (recipes.isEmpty) {
                      return Center(
                        child: Text(
                          'No se han encontrado recetas.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: recipes.length,
                      separatorBuilder: (_, _) => Divider(
                        height: AppSpacing.lg,
                        color: theme.colorScheme.outline.withValues(alpha: 0.5),
                      ),
                      itemBuilder: (context, index) {
                        final data = recipes[index];
                        return _RecipeResultTile(
                          data: data,
                          onTap: () async {
                            Navigator.of(context).pop();
                            await PlanRecipeQuantitySheet.showAdd(
                              context,
                              recipe: data.recipe,
                              date: widget.date,
                              mealType: widget.mealType,
                            );
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeResultTile extends StatelessWidget {
  const _RecipeResultTile({required this.data, required this.onTap});

  final RecipeCardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recipe = data.recipe;
    final imageBytes = recipe.imageBytes;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      onTap: onTap,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: SizedBox(
              width: 44,
              height: 44,
              child: imageBytes != null
                  ? Image.memory(imageBytes, fit: BoxFit.cover)
                  : Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  '${data.perServing.kcal.round()} kcal · '
                  'P${data.perServing.proteinG.round()} '
                  'C${data.perServing.carbsG.round()} '
                  'G${data.perServing.fatG.round()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
