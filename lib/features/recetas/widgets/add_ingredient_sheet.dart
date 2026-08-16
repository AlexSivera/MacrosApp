import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/database/app_database.dart';
import '../../../services/nutrition_engine/food_macros_calculator.dart';
import '../../diario/widgets/food_search_sheet.dart';

class IngredientDraft {
  const IngredientDraft({required this.food, required this.grams});

  final Food food;
  final double grams;
}

// Add-ingredient step of the recipe builder: search a food, enter grams,
// see a live macro preview, then return straight to the ingredient list —
// the flow the brief asks for (buscar → seleccionar → cantidad → añadir →
// volver al constructor) without any extra screens in between.
class AddIngredientSheet extends StatefulWidget {
  const AddIngredientSheet({super.key, required this.food});

  final Food food;

  static Future<IngredientDraft?> show(BuildContext context) async {
    final food = await FoodSearchSheet.show(context);
    if (food == null || !context.mounted) return null;
    return showForFood(context, food);
  }

  // Skips the search step for a food the caller already has in hand (e.g.
  // one just created via CustomFoodFormSheet) — straight to quantity entry.
  static Future<IngredientDraft?> showForFood(BuildContext context, Food food) {
    return showModalBottomSheet<IngredientDraft>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddIngredientSheet(food: food),
    );
  }

  @override
  State<AddIngredientSheet> createState() => _AddIngredientSheetState();
}

class _AddIngredientSheetState extends State<AddIngredientSheet> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial = widget.food.defaultServingGrams ?? 100;
    _controller = TextEditingController(
      text: initial == initial.roundToDouble() ? initial.round().toString() : initial.toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? get _grams => double.tryParse(_controller.text.replaceAll(',', '.'));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grams = _grams;
    final preview = grams != null && grams > 0 ? scaleFoodMacros(widget.food, grams) : null;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.food.name, style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Cantidad', suffixText: 'g', errorText: _error),
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (preview != null)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('${preview.kcal.round()} kcal', style: theme.textTheme.bodyMedium),
                    Text('P${preview.proteinG.round()}g', style: theme.textTheme.bodyMedium),
                    Text('C${preview.carbsG.round()}g', style: theme.textTheme.bodyMedium),
                    Text('G${preview.fatG.round()}g', style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: () {
                final g = _grams;
                if (g == null || g <= 0) {
                  setState(() => _error = 'Introduce una cantidad válida.');
                  return;
                }
                Navigator.of(context).pop(IngredientDraft(food: widget.food, grams: g));
              },
              child: const Text('Añadir ingrediente'),
            ),
          ],
        ),
      ),
    );
  }
}
