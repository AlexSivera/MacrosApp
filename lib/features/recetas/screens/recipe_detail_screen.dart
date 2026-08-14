import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../diario/widgets/recipe_quantity_sheet.dart';
import '../providers/recipes_providers.dart';

class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({super.key, required this.recipeId});

  final int recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);

    return StreamBuilder<Recipe?>(
      stream: db.recipesDao.watchById(recipeId),
      builder: (context, snapshot) {
        final recipe = snapshot.data;
        if (recipe == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return _RecipeDetailBody(recipe: recipe);
      },
    );
  }
}

class _RecipeDetailBody extends ConsumerWidget {
  const _RecipeDetailBody({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(appDatabaseProvider);
    final macrosAsync = ref.watch(recipePerServingMacrosProvider(recipe));

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        actions: [
          IconButton(
            icon: Icon(recipe.isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () => db.recipesDao.toggleFavorite(recipe.id, !recipe.isFavorite),
          ),
          PopupMenuButton<String>(
            onSelected: (action) => _handleMenuAction(context, ref, action),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Editar')),
              PopupMenuItem(value: 'duplicate', child: Text('Duplicar')),
              PopupMenuItem(value: 'delete', child: Text('Eliminar')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (recipe.imagePath != null && File(recipe.imagePath!).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.file(File(recipe.imagePath!), fit: BoxFit.cover),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          if (recipe.prepTimeMinutes != null)
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: AppSpacing.xs),
                Text('${recipe.prepTimeMinutes} min', style: theme.textTheme.bodyMedium),
              ],
            ),
          const SizedBox(height: AppSpacing.md),
          Text(
            recipe.servings == 1 ? '1 ración' : '${recipe.servings.round()} raciones',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          macrosAsync.when(
            data: (perServing) => Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Stat('${perServing.kcal.round()}', 'kcal'),
                  _Stat('${perServing.proteinG.round()}g', 'prot'),
                  _Stat('${perServing.carbsG.round()}g', 'carb'),
                  _Stat('${perServing.fatG.round()}g', 'grasa'),
                ],
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err'),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Ingredientes', style: theme.textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          StreamBuilder<List<RecipeIngredient>>(
            stream: db.recipeIngredientsDao.watchForRecipe(recipe.id),
            builder: (context, snapshot) {
              final ingredients = snapshot.data ?? [];
              return Column(
                children: [
                  for (final ingredient in ingredients)
                    FutureBuilder<Food?>(
                      future: db.foodsDao.getById(ingredient.foodId),
                      builder: (context, foodSnapshot) {
                        final food = foodSnapshot.data;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(food?.name ?? '…'),
                          trailing: Text('${ingredient.grams.round()} g'),
                        );
                      },
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
          ElevatedButton(
            onPressed: () => RecipeQuantitySheet.showAdd(context, recipe: recipe),
            child: const Text('Añadir al Diario'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMenuAction(BuildContext context, WidgetRef ref, String action) async {
    final db = ref.read(appDatabaseProvider);
    switch (action) {
      case 'edit':
        context.push('/recetas/${recipe.id}/editar');
      case 'duplicate':
        final newId = await db.recipesDao.insert(RecipesCompanion.insert(
          name: '${recipe.name} (copia)',
          imagePath: Value(recipe.imagePath),
          category: Value(recipe.category),
          servings: Value(recipe.servings),
          prepTimeMinutes: Value(recipe.prepTimeMinutes),
        ));
        final ingredients = await db.recipeIngredientsDao.getForRecipe(recipe.id);
        await db.recipeIngredientsDao.replaceIngredients(newId, [
          for (final i in ingredients)
            RecipeIngredientsCompanion.insert(
              recipeId: newId,
              foodId: i.foodId,
              grams: i.grams,
              orderIndex: i.orderIndex,
            ),
        ]);
        if (context.mounted) context.pop();
      case 'delete':
        await db.recipesDao.deleteRecipe(recipe.id);
        if (context.mounted) context.pop();
    }
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleMedium),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
