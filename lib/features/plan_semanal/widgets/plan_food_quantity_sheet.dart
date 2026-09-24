import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/macro_preview_row.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../services/nutrition_engine/food_macros_calculator.dart';

enum _QuantityMode { grams, units }

// Quantity-entry step for a food on a given day, shared by the Diario
// (eaten: true — it's being logged, so it's snapshotted straight away) and
// the Plan (eaten: false — planned, stays live until ticked off).
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
    this.eaten = false,
  });

  final Food food;
  final DateTime? date;
  final MealType? mealType;
  final MealPlanEntry? entry;
  final bool eaten;

  static Future<void> showAdd(
    BuildContext context, {
    required Food food,
    required DateTime date,
    required MealType mealType,
    bool eaten = false,
  }) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) =>
          PlanFoodQuantitySheet(food: food, date: date, mealType: mealType, eaten: eaten),
    );
  }

  static Future<void> showEdit(
    BuildContext context, {
    required Food food,
    required MealPlanEntry entry,
  }) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
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
      _controller = TextEditingController(text: formatInputNumber(1));
    } else {
      _mode = _QuantityMode.grams;
      _controller = TextEditingController(text: formatInputNumber(existingGrams ?? 100));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? get _enteredValue => parseDecimal(_controller.text);

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
        _controller.text = formatInputNumber(
          mode == _QuantityMode.units ? grams / widget.food.defaultServingGrams! : grams,
        );
      }
    });
  }

  void _setQuick(double value) {
    setState(() {
      _error = null;
      _controller.text = formatInputNumber(value);
      _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
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
        eaten: widget.eaten,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grams = _grams;
    final preview = grams != null && grams > 0 ? scaleFoodMacros(widget.food, grams) : null;
    final isUnits = _mode == _QuantityMode.units;
    final quickValues = isUnits ? const [0.5, 1.0, 2.0, 3.0] : const [50.0, 100.0, 150.0, 200.0];

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
                    selected: isUnits,
                    onSelected: (_) => _setMode(_QuantityMode.units),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  ChoiceChip(
                    label: const Text('Gramos'),
                    selected: !isUnits,
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
                labelText: isUnits ? 'Unidades' : 'Cantidad',
                suffixText: isUnits ? null : 'g',
                errorText: _error,
              ),
              onChanged: (_) => setState(() => _error = null),
              onSubmitted: (_) => _submit(),
            ),
            if (widget.food.servingLabel != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(widget.food.servingLabel!, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                for (final v in quickValues)
                  ActionChip(
                    label: Text(isUnits ? '${formatDecimal(v)} ud' : '${v.round()} g'),
                    onPressed: () => _setQuick(v),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (preview != null) MacroPreviewRow(macros: preview),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _submit,
              child: Text(
                widget.entry != null
                    ? 'Guardar'
                    : (widget.eaten ? 'Añadir al diario' : 'Añadir al plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
