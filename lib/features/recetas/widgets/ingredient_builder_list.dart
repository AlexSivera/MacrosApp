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
                label: 'Crear alimento',
                onPressed: () => _createFoodsLoop(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // "Crear alimento" only adds new foods to the catalog — it does NOT add
  // them to this recipe. Creating a food and deciding how much of it goes
  // into *this* recipe are two different decisions, so forcing a "cantidad"
  // prompt immediately after typing in its macros was the wrong step to
  // force here; the food shows up via "Añadir ingrediente" like any other
  // once it exists. Reopens the creation form immediately after each save
  // so creating several homemade ingredients in a row (flour, eggs,
  // sugar…) doesn't mean re-tapping the button each time — the loop only
  // ends when the user backs out of the form, which reads as "I'm done"
  // without needing a separate confirmation step.
  Future<void> _createFoodsLoop(BuildContext context) async {
    while (true) {
      final food = await CustomFoodFormSheet.show(context);
      if (food == null || !context.mounted) return;
    }
  }
}
