import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
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
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Añadir ingrediente'),
            onPressed: () async {
              final draft = await AddIngredientSheet.show(context);
              if (draft != null) onAdd(draft);
            },
          ),
        ),
      ],
    );
  }
}
