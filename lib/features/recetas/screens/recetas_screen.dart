import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../providers/recipes_providers.dart';
import '../widgets/recipe_card.dart';
import '../widgets/recipe_filter_chips.dart';

class RecetasScreen extends ConsumerWidget {
  const RecetasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(filteredRecipesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recetas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/recetas/nuevo'),
        icon: const Icon(Icons.add),
        label: const Text('Crear receta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar recetas',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => ref.read(recipeSearchQueryProvider.notifier).state = value,
            ),
            const SizedBox(height: AppSpacing.md),
            const RecipeFilterChips(),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: AppSpacing.md),
          Text('Aún no tienes recetas', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(onPressed: onCreate, child: const Text('Crear mi primera receta')),
        ],
      ),
    );
  }
}
