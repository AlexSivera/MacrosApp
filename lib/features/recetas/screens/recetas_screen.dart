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

    return Scaffold(
      appBar: AppBar(title: const Text('Recetas')),
      floatingActionButton: FloatingActionButton.extended(
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
                    return _EmptyRecipesState(
                      onCreate: () => context.push('/recetas/nuevo'),
                    );
                  }
                  return GridView.builder(
                    itemCount: recipes.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.66,
                    ),
                    itemBuilder: (context, index) {
                      final data = recipes[index];
                      return FadeSlideIn(
                        delay: Duration(milliseconds: 30 * (index % 10)),
                        child: RecipeCard(
                          data: data,
                          onTap: () => context.push('/recetas/${data.recipe.id}'),
                        ),
                      );
                    },
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
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.22),
                    blurRadius: 40,
                    spreadRadius: -12,
                  ),
                ],
              ),
              child: Icon(Icons.menu_book_rounded, size: 40, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Aún no tienes recetas',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
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
