import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../providers/recipes_providers.dart';

extension on RecipeFilter {
  String get label => switch (this) {
        RecipeFilter.all => 'Todas',
        RecipeFilter.breakfast => 'Desayunos',
        RecipeFilter.lunch => 'Comidas',
        RecipeFilter.dinner => 'Cenas',
        RecipeFilter.snack => 'Snacks',
        RecipeFilter.favorites => 'Favoritas',
        RecipeFilter.highProtein => 'Alta proteína',
      };
}

class RecipeFilterChips extends ConsumerWidget {
  const RecipeFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(recipeFilterProvider);

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: RecipeFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final filter = RecipeFilter.values[index];
          return ChoiceChip(
            label: Text(filter.label),
            selected: selected == filter,
            onSelected: (_) => ref.read(recipeFilterProvider.notifier).state = filter,
          );
        },
      ),
    );
  }
}
