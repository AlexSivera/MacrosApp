import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/daos/diary_dao.dart';
import '../../../data/database/database_provider.dart';

// "Guardar como receta" — bundles everything logged in one meal into a new
// Recipe. Food entries map straight to a RecipeIngredient. Entries that are
// themselves a logged recipe are expanded to their own ingredients, scaled
// by (loggedServings / originalServings), so the new recipe is always
// built from real Foods rather than nesting a recipe inside a recipe.
class SaveMealAsRecipeSheet extends ConsumerStatefulWidget {
  const SaveMealAsRecipeSheet({super.key, required this.entries, required this.mealType});

  final List<DiaryEntryDisplay> entries;
  final MealType mealType;

  static Future<void> show(
    BuildContext context, {
    required List<DiaryEntryDisplay> entries,
    required MealType mealType,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SaveMealAsRecipeSheet(entries: entries, mealType: mealType),
    );
  }

  @override
  ConsumerState<SaveMealAsRecipeSheet> createState() => _SaveMealAsRecipeSheetState();
}

class _SaveMealAsRecipeSheetState extends ConsumerState<SaveMealAsRecipeSheet> {
  final _name = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  RecipeCategory _categoryFor(MealType meal) => switch (meal) {
        MealType.breakfast => RecipeCategory.breakfast,
        MealType.lunch => RecipeCategory.lunch,
        MealType.dinner => RecipeCategory.dinner,
        MealType.snackMerienda || MealType.snack => RecipeCategory.snack,
      };

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Ponle un nombre a la receta.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    final db = ref.read(appDatabaseProvider);
    final gramsByFoodId = <int, double>{};

    for (final display in widget.entries) {
      final entry = display.entry;
      if (entry.foodId != null && entry.quantityGrams != null) {
        gramsByFoodId.update(
          entry.foodId!,
          (g) => g + entry.quantityGrams!,
          ifAbsent: () => entry.quantityGrams!,
        );
      } else if (entry.recipeId != null && entry.servings != null) {
        final recipe = await db.recipesDao.getById(entry.recipeId!);
        if (recipe == null || recipe.servings <= 0) continue;
        final scale = entry.servings! / recipe.servings;
        final ingredients = await db.recipeIngredientsDao.getForRecipe(recipe.id);
        for (final ingredient in ingredients) {
          gramsByFoodId.update(
            ingredient.foodId,
            (g) => g + ingredient.grams * scale,
            ifAbsent: () => ingredient.grams * scale,
          );
        }
      }
    }

    if (gramsByFoodId.isEmpty) {
      setState(() {
        _saving = false;
        _error = 'Esta comida no tiene alimentos que guardar.';
      });
      return;
    }

    final recipeId = await db.recipesDao.insert(RecipesCompanion.insert(
      name: _name.text.trim(),
      category: Value(_categoryFor(widget.mealType)),
    ));
    var orderIndex = 0;
    await db.recipeIngredientsDao.replaceIngredients(recipeId, [
      for (final entry in gramsByFoodId.entries)
        RecipeIngredientsCompanion.insert(
          recipeId: recipeId,
          foodId: entry.key,
          grams: entry.value,
          orderIndex: orderIndex++,
        ),
    ]);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Guardar como receta', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _name,
              autofocus: true,
              decoration: InputDecoration(labelText: 'Nombre de la receta', errorText: _error),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Guardar receta'),
            ),
          ],
        ),
      ),
    );
  }
}
