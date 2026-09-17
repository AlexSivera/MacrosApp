import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../services/nutrition_engine/food_macros_calculator.dart';

enum _QuantityMode { grams, units }

// Quantity-entry step for a food planned on a given day — the Plan semanal
// analogue of FoodQuantitySheet, writing to MealPlanDao instead of DiaryDao.
// No macros are computed here beyond the live preview: MealPlanEntries never
// snapshots them (see meal_plan_entries_table.dart), unlike a diary entry.
//
// Foods with a defaultServingGrams (e.g. "1 huevo ≈ 50g") get a
// Gramos/Unidades toggle: in Unidades mode the field holds a piece count,
// converted to grams (units * defaultServingGrams) only at the boundary
// (submit, and the macros preview) — MealPlanEntries.quantityGrams is
// always grams, there's no "this was entered as units" flag to persist.
// Foods without a serving size never show the toggle at all.
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
  late _QuantityMode _mode;
  String? _error;

  bool get _hasServingSize => widget.food.defaultServingGrams != null;

  @override
  void initState() {
    super.initState();
    final existingGrams = widget.entry?.quantityGrams;
    if (existingGrams == null && _hasServingSize) {
      // Fresh add on a food with a known piece size: "1 huevo" reads more
      // naturally than "50g" as the starting point.
      _mode = _QuantityMode.units;
      _controller = TextEditingController(text: _formatNumber(1));
    } else {
      _mode = _QuantityMode.grams;
      _controller = TextEditingController(text: _formatNumber(existingGrams ?? 100));
    }
  }

  static String _formatNumber(double n) => n == n.roundToDouble() ? n.round().toString() : n.toString();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? get _enteredValue => double.tryParse(_controller.text.replaceAll(',', '.'));

  double? get _grams {
    final value = _enteredValue;
    if (value == null) return null;
    if (_mode == _QuantityMode.units) return value * widget.food.defaultServingGrams!;
    return value;
  }

  // Converts the current value across the mode switch instead of resetting
  // it, so "3 huevos" becomes "150" (not "1") when the user flips to gramos.
  void _setMode(_QuantityMode mode) {
    if (mode == _mode) return;
    final grams = _grams;
    setState(() {
      _mode = mode;
      _error = null;
      if (grams != null && grams > 0) {
        _controller.text = _formatNumber(
          mode == _QuantityMode.units ? grams / widget.food.defaultServingGrams! : grams,
        );
      }
    });
  }

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
            if (_hasServingSize) ...[
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Unidades'),
                    selected: _mode == _QuantityMode.units,
                    onSelected: (_) => _setMode(_QuantityMode.units),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  ChoiceChip(
                    label: const Text('Gramos'),
                    selected: _mode == _QuantityMode.grams,
                    onSelected: (_) => _setMode(_QuantityMode.grams),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: _mode == _QuantityMode.units ? 'Unidades' : 'Cantidad',
                suffixText: _mode == _QuantityMode.units ? null : 'g',
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
