import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_add_button.dart';
import '../../diario/widgets/custom_food_form_sheet.dart';
import 'add_ingredient_sheet.dart';

class IngredientBuilderList extends StatelessWidget {
  const IngredientBuilderList({
    super.key,
    required this.ingredients,
    required this.onAdd,
    required this.onRemove,
  });

  final List<IngredientDraft> ingredients;
  final ValueChanged<IngredientDraft> onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Ingredientes', style: theme.textTheme.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        if (ingredients.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text('Aún no has añadido ingredientes.', style: theme.textTheme.bodyMedium),
          )
        else
          for (var i = 0; i < ingredients.length; i++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(ingredients[i].food.name),
              subtitle: Text('${ingredients[i].grams.round()} g'),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => onRemove(i),
              ),
            ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              AppAddButton(
                label: 'Añadir ingrediente',
                onPressed: () async {
                  final draft = await AddIngredientSheet.show(context);
                  if (draft != null) onAdd(draft);
                },
              ),
              const SizedBox(width: AppSpacing.sm),
              AppAddButton(
                label: 'Crear ingrediente',
                onPressed: () => _createIngredientsLoop(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Creating several homemade ingredients in a row (flour, eggs, sugar…)
  // otherwise means re-opening the food search just to find nothing and dig
  // out "Crear alimento personalizado" each time. This skips straight to
  // that form and, after each one is added, reopens it immediately — the
  // loop only ends when the user backs out of creating a food, which reads
  // as "I'm done" without needing a separate confirmation step.
  Future<void> _createIngredientsLoop(BuildContext context) async {
    while (true) {
      final food = await CustomFoodFormSheet.show(context);
      if (food == null || !context.mounted) return;
      final draft = await AddIngredientSheet.showForFood(context, food);
      if (draft != null) onAdd(draft);
      if (!context.mounted) return;
    }
  }
}
