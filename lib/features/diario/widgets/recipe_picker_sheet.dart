import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/database/enums.dart';
import '../../recetas/providers/recipes_providers.dart';
import '../../recetas/widgets/recipe_filter_chips.dart';
import 'recipe_quantity_sheet.dart';

// "Añadir receta" / "Añadir comida guardada" (the brief treats the two as
// the same concept — a saved Recipe) from a Diario meal section: search or
// filter Mis Recetas, tap one, then choose servings via RecipeQuantitySheet.
// Reuses the same search+filter+data providers as the Recetas tab itself so
// this quick picker doesn't drift out of sync with it over time.
class RecipePickerSheet extends ConsumerWidget {
  const RecipePickerSheet({super.key, required this.mealType});

  final MealType mealType;

  static Future<void> show(BuildContext context, {required MealType mealType}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => RecipePickerSheet(mealType: mealType),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final resultsAsync = ref.watch(filteredRecipesProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Añadir receta', style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar en Mis Recetas',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => ref.read(recipeSearchQueryProvider.notifier).state = value,
              ),
              const SizedBox(height: AppSpacing.md),
              const RecipeFilterChips(),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: resultsAsync.when(
                  data: (recipes) {
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
                            await RecipeQuantitySheet.showAdd(
                              context,
                              recipe: data.recipe,
                              mealType: mealType,
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
