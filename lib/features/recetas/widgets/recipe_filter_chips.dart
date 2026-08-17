import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../providers/recipes_providers.dart';

// Plain (not Consumer-)widget so it can drive either the Recetas tab's
// shared recipeFilterProvider or a sheet's own local, independent filter
// state (see RecipePickerSheet) — a chip row has no business knowing which.
class RecipeFilterChips extends StatelessWidget {
  const RecipeFilterChips({super.key, required this.selected, required this.onChanged});

  final RecipeFilter selected;
  final ValueChanged<RecipeFilter> onChanged;

  @override
  Widget build(BuildContext context) {
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
            onSelected: (_) => onChanged(filter),
          );
        },
      ),
    );
  }
}
