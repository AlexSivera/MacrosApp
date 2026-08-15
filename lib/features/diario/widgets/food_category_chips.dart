import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/database/enums.dart';
import '../providers/food_search_providers.dart';

extension FoodCategoryLabel on FoodCategory {
  String get label => switch (this) {
        FoodCategory.fruta => 'Fruta',
        FoodCategory.verdura => 'Verdura',
        FoodCategory.cerealLegumbre => 'Cereales',
        FoodCategory.lacteo => 'Lácteos',
        FoodCategory.carnePescado => 'Carne y pescado',
        FoodCategory.huevo => 'Huevos',
        FoodCategory.frutoSecoSemilla => 'Frutos secos',
        FoodCategory.aceiteGrasa => 'Aceites y grasas',
        FoodCategory.panaderia => 'Panadería',
        FoodCategory.bebida => 'Bebidas',
        FoodCategory.snackProcesado => 'Snacks',
        FoodCategory.proteinaVegetal => 'Proteína vegetal',
        FoodCategory.condimento => 'Condimentos',
        FoodCategory.otros => 'Otros',
      };
}

// "Todos" (null) + one chip per FoodCategory, horizontally scrollable —
// narrows the food_search_sheet results alongside (not instead of) the text
// search, reused as-is by both the Diario's add-food flow and the recipe
// ingredient builder since they share FoodSearchSheet.
class FoodCategoryChips extends ConsumerWidget {
  const FoodCategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(foodCategoryFilterProvider);
    final categories = FoodCategory.values;

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          if (index == 0) {
            return ChoiceChip(
              label: const Text('Todos'),
              selected: selected == null,
              onSelected: (_) => ref.read(foodCategoryFilterProvider.notifier).state = null,
            );
          }
          final category = categories[index - 1];
          return ChoiceChip(
            label: Text(category.label),
            selected: selected == category,
            onSelected: (_) =>
                ref.read(foodCategoryFilterProvider.notifier).state = category,
          );
        },
      ),
    );
  }
}
