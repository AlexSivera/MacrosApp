import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../services/nutrition_engine/food_macros_calculator.dart';
import '../providers/diary_providers.dart';

// Quantity-entry step for a food, in both directions: adding a fresh diary
// entry (Food + target meal known, no existing entry) and editing an
// existing entry's grams (entry != null, meal fixed).
class FoodQuantitySheet extends ConsumerStatefulWidget {
  const FoodQuantitySheet({
    super.key,
    required this.food,
    this.mealType,
    this.entry,
  });

  final Food food;
  final MealType? mealType;
  final DiaryEntry? entry;

  static Future<void> showAdd(BuildContext context, {required Food food, required MealType mealType}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FoodQuantitySheet(food: food, mealType: mealType),
    );
  }

  static Future<void> showEdit(BuildContext context, {required Food food, required DiaryEntry entry}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FoodQuantitySheet(food: food, entry: entry),
    );
  }

  @override
  ConsumerState<FoodQuantitySheet> createState() => _FoodQuantitySheetState();
}

class _FoodQuantitySheetState extends ConsumerState<FoodQuantitySheet> {
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
    final macros = scaleFoodMacros(widget.food, grams);
    final db = ref.read(appDatabaseProvider);

    if (widget.entry != null) {
      await db.diaryDao.updateEntryQuantityAndMacros(
        widget.entry!.id,
        quantityGrams: grams,
        kcal: macros.kcal,
        proteinG: macros.proteinG,
        carbsG: macros.carbsG,
        fatG: macros.fatG,
      );
    } else {
      final date = ref.read(selectedDiaryDateProvider);
      final orderIndex = await db.diaryDao.nextOrderIndex(date, widget.mealType!);
      await db.diaryDao.logFood(
        date: date,
        mealType: widget.mealType!,
        foodId: widget.food.id,
        quantityGrams: grams,
        orderIndex: orderIndex,
        kcal: macros.kcal,
        proteinG: macros.proteinG,
        carbsG: macros.carbsG,
        fatG: macros.fatG,
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
              child: Text(widget.entry != null ? 'Guardar' : 'Agregar'),
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
