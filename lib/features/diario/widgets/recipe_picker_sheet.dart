import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/enums.dart';
import '../../recetas/providers/recipes_providers.dart';
import 'recipe_quantity_sheet.dart';

// "Añadir receta" / "Añadir comida guardada" (the brief treats the two as
// the same concept — a saved Recipe) from a Diario meal section: search
// Mis Recetas, tap one, then choose servings via RecipeQuantitySheet.
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
    final resultsAsync = ref.watch(recipeSearchResultsProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Añadir receta', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar en Mis Recetas',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) =>
                    ref.read(recipeSearchQueryProvider.notifier).state = value,
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: resultsAsync.when(
                  data: (recipes) {
                    if (recipes.isEmpty) {
                      return Center(
                        child: Text(
                          'Aún no tienes recetas.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: recipes.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(recipe.name),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            Navigator.of(context).pop();
                            await RecipeQuantitySheet.showAdd(
                              context,
                              recipe: recipe,
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
