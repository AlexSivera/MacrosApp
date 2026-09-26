import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/legacy_recipe_image.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../diario/providers/diary_providers.dart';
import '../../plan_semanal/widgets/plan_recipe_quantity_sheet.dart';
import '../providers/recipes_providers.dart';
import '../../../core/widgets/macro_preview_row.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_date_picker.dart';

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

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        Text(text, style: theme.textTheme.bodyMedium),
      ],
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
    final image = recipe.imageBytes != null
        ? Image.memory(recipe.imageBytes!, fit: BoxFit.cover)
        : (recipe.imagePath != null ? legacyFileImage(recipe.imagePath!) : null);

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
          if (image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: SizedBox.expand(child: image),
              ),
            ),
          if (image != null) const SizedBox(height: AppSpacing.lg),
          // Category · time · servings on one line.
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              _Meta(icon: recipe.category.icon, text: recipe.category.label),
              if (recipe.prepTimeMinutes != null) _Meta(icon: Icons.schedule, text: '${recipe.prepTimeMinutes} min'),
              _Meta(
                icon: Icons.restaurant_outlined,
                text: recipe.servings == 1 ? '1 ración' : '${formatDecimal(recipe.servings)} raciones',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          macrosAsync.when(
            data: (perServing) => AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Por ración', style: theme.textTheme.labelMedium),
                  const SizedBox(height: AppSpacing.sm),
                  MacroPreviewRow(macros: perServing, filled: false),
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
              if (ingredients.isEmpty) return const SizedBox.shrink();
              return AppCard(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    for (var i = 0; i < ingredients.length; i++) ...[
                      FutureBuilder<Food?>(
                        future: db.foodsDao.getById(ingredients[i].foodId),
                        builder: (context, foodSnapshot) {
                          final food = foodSnapshot.data;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                            child: Row(
                              children: [
                                Expanded(child: Text(food?.name ?? '…', style: theme.textTheme.bodyLarge)),
                                Text('${ingredients[i].grams.round()} g', style: theme.textTheme.bodyMedium),
                              ],
                            ),
                          );
                        },
                      ),
                      if (i != ingredients.length - 1)
                        Divider(
                          height: AppSpacing.xs,
                          color: theme.colorScheme.outline.withValues(alpha: 0.5),
                        ),
                    ],
                  ],
                ),
              );
            },
          ),
          if (_steps(recipe).isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text('Preparación', style: theme.textTheme.labelMedium),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (i, step) in _steps(recipe).indexed)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            child: Text(
                              '${i + 1}.',
                              style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
                            ),
                          ),
                          Expanded(child: Text(step, style: theme.textTheme.bodyMedium)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
      // Pinned, so adding it doesn't mean scrolling past a long recipe.
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _addToPlan(context),
                  child: const Text('Añadir al plan'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => PlanRecipeQuantitySheet.showAdd(
                    context,
                    recipe: recipe,
                    date: ref.read(selectedDiaryDateProvider),
                    eaten: true,
                  ),
                  child: const Text('Añadir al diario'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // One step per non-empty line of the free-text instructions.
  static List<String> _steps(Recipe recipe) => [
        for (final line in (recipe.instructions ?? '').split('\n'))
          if (line.trim().isNotEmpty) line.trim(),
      ];

  // Planning needs a day first; the meal is picked in the quantity sheet.
  Future<void> _addToPlan(BuildContext context) async {
    final today = DateTime.now();
    final picked = await showAppDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(today.year - 1),
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked == null || !context.mounted) return;
    await PlanRecipeQuantitySheet.showAdd(
      context,
      recipe: recipe,
      date: DateTime(picked.year, picked.month, picked.day),
      eaten: false,
    );
  }

  Future<void> _handleMenuAction(BuildContext context, WidgetRef ref, String action) async {
    final db = ref.read(appDatabaseProvider);
    switch (action) {
      case 'edit':
        context.push('/recetas/${recipe.id}/editar');
      case 'duplicate':
        final newId = await db.recipesDao.insert(
          RecipesCompanion.insert(
            name: '${recipe.name} (copia)',
            imagePath: Value(recipe.imagePath),
            imageBytes: Value(recipe.imageBytes),
            category: Value(recipe.category),
            servings: Value(recipe.servings),
            prepTimeMinutes: Value(recipe.prepTimeMinutes),
            instructions: Value(recipe.instructions),
          ),
        );
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
        // Opens the copy (usually to rename or tweak it) instead of just
        // closing this screen.
        if (context.mounted) {
          context.pushReplacement('/recetas/$newId');
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receta duplicada')));
        }
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar receta'),
            content: Text('Se eliminará "${recipe.name}" y no se podrá recuperar.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
        await db.recipesDao.deleteRecipe(recipe.id);
        if (context.mounted) context.pop();
    }
  }
}
