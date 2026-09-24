import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../providers/recipes_providers.dart';
import '../widgets/recipe_card.dart';
import '../widgets/recipe_filter_chips.dart';

class RecetasScreen extends ConsumerWidget {
  const RecetasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recipesAsync = ref.watch(filteredRecipesProvider);
    // Only the whole collection being empty is "no recipes yet"; an empty
    // search or filter result is its own, lighter state.
    final hasAnyRecipe = ref.watch(recipesWithMacrosProvider).valueOrNull?.isNotEmpty ?? true;

    return Scaffold(
      appBar: AppBar(title: const Text('Recetas')),
      // The empty state already has its own centered "Crear" button.
      floatingActionButton: !hasAnyRecipe
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.push('/recetas/nuevo'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Crear receta'),
            ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                boxShadow: AppTheme.softShadow(context),
              ),
              child: TextField(
                style: theme.textTheme.bodyLarge,
                decoration: const InputDecoration(
                  hintText: 'Buscar recetas',
                  prefixIcon: Icon(Icons.search_rounded),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                onChanged: (value) => ref.read(recipeSearchQueryProvider.notifier).state = value,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            RecipeFilterChips(
              selected: ref.watch(recipeFilterProvider),
              onChanged: (filter) => ref.read(recipeFilterProvider.notifier).state = filter,
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: recipesAsync.when(
                data: (recipes) {
                  if (recipes.isEmpty) {
                    return hasAnyRecipe
                        ? const _NoResultsState()
                        : _EmptyRecipesState(onCreate: () => context.push('/recetas/nuevo'));
                  }
                  return SingleChildScrollView(
                    child: _RecipeMasonryGrid(
                      recipes: recipes,
                      onTapRecipe: (id) => context.push('/recetas/$id'),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error al cargar recetas: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// A manual 2-column masonry layout, not GridView: a recipe name can wrap
// onto extra lines now that it's never truncated with "…" (see RecipeCard),
// so cards need variable heights rather than the uniform ones a
// SliverGridDelegateWithFixedCrossAxisCount would force on every card
// regardless of its own content.
class _RecipeMasonryGrid extends StatelessWidget {
  const _RecipeMasonryGrid({required this.recipes, required this.onTapRecipe});

  final List<RecipeCardData> recipes;
  final ValueChanged<int> onTapRecipe;

  @override
  Widget build(BuildContext context) {
    final leftColumn = <int>[];
    final rightColumn = <int>[];
    for (var i = 0; i < recipes.length; i++) {
      (i.isEven ? leftColumn : rightColumn).add(i);
    }

    Widget buildColumn(List<int> indices) => Column(
      children: [
        for (final index in indices)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: FadeSlideIn(
              // Keyed by recipe so a card only animates in once, not again
              // whenever filtering shuffles which slot it lands in.
              key: ValueKey(recipes[index].recipe.id),
              delay: Duration(milliseconds: 30 * (index % 10)),
              child: RecipeCard(data: recipes[index], onTap: () => onTapRecipe(recipes[index].recipe.id)),
            ),
          ),
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: buildColumn(leftColumn)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: buildColumn(rightColumn)),
      ],
    );
  }
}

class _EmptyRecipesState extends StatelessWidget {
  const _EmptyRecipesState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.tint(context),
              ),
              child: Icon(Icons.menu_book_rounded, size: 40, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Aún no tienes recetas', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Guarda tus platos favoritos y añádelos al diario en un toque',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Crear mi primera receta'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  const _NoResultsState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 40, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: AppSpacing.md),
          Text('Ninguna receta coincide', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text('Prueba con otra búsqueda o filtro.', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
