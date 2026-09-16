import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../services/nutrition_engine/food_macros_calculator.dart';

// Quantity-entry step for a food planned on a given day — the Plan semanal
// analogue of FoodQuantitySheet, writing to MealPlanDao instead of DiaryDao.
// No macros are computed here beyond the live preview: MealPlanEntries never
// snapshots them (see meal_plan_entries_table.dart), unlike a diary entry.
class PlanFoodQuantitySheet extends ConsumerStatefulWidget {
  const PlanFoodQuantitySheet({
    super.key,
    required this.food,
    this.date,
    this.mealType,
    this.entry,
  });

  final Food food;
  final DateTime? date;
  final MealType? mealType;
  final MealPlanEntry? entry;

  static Future<void> showAdd(
    BuildContext context, {
    required Food food,
    required DateTime date,
    required MealType mealType,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PlanFoodQuantitySheet(food: food, date: date, mealType: mealType),
    );
  }

  static Future<void> showEdit(
    BuildContext context, {
    required Food food,
    required MealPlanEntry entry,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PlanFoodQuantitySheet(food: food, entry: entry),
    );
  }

  @override
  ConsumerState<PlanFoodQuantitySheet> createState() => _PlanFoodQuantitySheetState();
}

class _PlanFoodQuantitySheetState extends ConsumerState<PlanFoodQuantitySheet> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial = widget.entry?.quantityGrams ?? widget.food.defaultServingGrams ?? 100;
    _controller = TextEditingController(text: _formatGrams(initial));
  }

  static String _formatGrams(double g) => g == g.roundToDouble() ? g.round().toString() : g.toString();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? get _grams => double.tryParse(_controller.text.replaceAll(',', '.'));

  Future<void> _submit() async {
    final grams = _grams;
    if (grams == null || grams <= 0) {
      setState(() => _error = 'Introduce una cantidad válida.');
      return;
    }
    final db = ref.read(appDatabaseProvider);

    if (widget.entry != null) {
      await db.mealPlanDao.updateEntryQuantity(widget.entry!.id, quantityGrams: grams);
    } else {
      final orderIndex = await db.mealPlanDao.nextOrderIndex(widget.date!, widget.mealType!);
      await db.mealPlanDao.addFood(
        date: widget.date!,
        mealType: widget.mealType!,
        foodId: widget.food.id,
        quantityGrams: grams,
        orderIndex: orderIndex,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

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
              decoration: InputDecoration(
                labelText: 'Cantidad',
                suffixText: 'g',
                errorText: _error,
              ),
              onChanged: (_) => setState(() => _error = null),
            ),
            if (widget.food.servingLabel != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(widget.food.servingLabel!, style: theme.textTheme.bodySmall),
            ],
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
                    _PreviewStat('${preview.kcal.round()}', 'kcal'),
                    _PreviewStat('${preview.proteinG.round()}g', 'prot'),
                    _PreviewStat('${preview.carbsG.round()}g', 'carb'),
                    _PreviewStat('${preview.fatG.round()}g', 'grasa'),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _submit,
              child: Text(widget.entry != null ? 'Guardar' : 'Añadir al plan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewStat extends StatelessWidget {
  const _PreviewStat(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleMedium),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
