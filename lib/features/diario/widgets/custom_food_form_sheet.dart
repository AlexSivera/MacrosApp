import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import 'food_category_chips.dart';

// "Crear alimento personalizado" — a minimal form (name + macros, entered
// either per 100g or per serving), saved to Foods with isCustom = true, then
// handed back to the caller so it can flow straight into quantity entry
// without an extra round trip.
class CustomFoodFormSheet extends ConsumerStatefulWidget {
  const CustomFoodFormSheet({super.key});

  static Future<Food?> show(BuildContext context) {
    return showModalBottomSheet<Food>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CustomFoodFormSheet(),
    );
  }

  @override
  ConsumerState<CustomFoodFormSheet> createState() => _CustomFoodFormSheetState();
}

class _CustomFoodFormSheetState extends ConsumerState<CustomFoodFormSheet> {
  final _name = TextEditingController();
  final _kcal = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fat = TextEditingController();
  final _servingGrams = TextEditingController();
  final _servingLabel = TextEditingController();
  FoodCategory _category = FoodCategory.otros;
  // Most people know a food's nutrition the way it's printed on a label or
  // in a tracking app they used before: "per serving", not "per 100g". This
  // toggle lets them enter it that way instead of doing the math themselves
  // — we convert to per-100g (the storage unit) on submit.
  bool _perServing = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _kcal.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    _servingGrams.dispose();
    _servingLabel.dispose();
    super.dispose();
  }

  double _parse(String text) => double.tryParse(text.replaceAll(',', '.')) ?? 0;

  // Fills in kcal from the three macros (4/4/9 kcal per gram) for foods
  // whose label lists macros but not calories, or as a quick sanity check.
  void _calculateKcal() {
    final kcal = _parse(_protein.text) * 4 + _parse(_carbs.text) * 4 + _parse(_fat.text) * 9;
    setState(() => _kcal.text = kcal.round().toString());
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Ponle un nombre al alimento.');
      return;
    }

    double? servingGrams;
    if (_perServing) {
      servingGrams = double.tryParse(_servingGrams.text.replaceAll(',', '.'));
      if (servingGrams == null || servingGrams <= 0) {
        setState(() => _error = 'Introduce el tamaño de la ración en gramos.');
        return;
      }
    }

    final enteredKcal = _parse(_kcal.text);
    final enteredProtein = _parse(_protein.text);
    final enteredCarbs = _parse(_carbs.text);
    final enteredFat = _parse(_fat.text);
    if (enteredKcal < 0 || enteredProtein < 0 || enteredCarbs < 0 || enteredFat < 0) {
      setState(() => _error = 'Los valores no pueden ser negativos.');
      return;
    }

    // Scale from "per serving" up to "per 100g" (storage's fixed unit) —
    // a no-op factor of 1 when the user entered per-100g values directly.
    final factor = _perServing ? 100 / servingGrams! : 1.0;

    final db = ref.read(appDatabaseProvider);
    final id = await db.foodsDao.insert(FoodsCompanion.insert(
      name: _name.text.trim(),
      kcalPer100g: enteredKcal * factor,
      proteinPer100g: enteredProtein * factor,
      carbsPer100g: enteredCarbs * factor,
      fatPer100g: enteredFat * factor,
      isCustom: const Value(true),
      category: Value(_category),
      defaultServingGrams: Value(servingGrams),
      servingLabel: Value(
        _perServing && _servingLabel.text.trim().isNotEmpty ? _servingLabel.text.trim() : null,
      ),
    ));
    final food = await db.foodsDao.getById(id);
    if (mounted) Navigator.of(context).pop(food);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
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
            Text('Crear alimento personalizado', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _name,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<FoodCategory>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: [
                for (final category in FoodCategory.values)
                  DropdownMenuItem(value: category, child: Text(category.label)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('¿Cómo conoces sus valores?', style: theme.textTheme.labelMedium),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Por 100 g')),
                ButtonSegment(value: true, label: Text('Por ración')),
              ],
              selected: {_perServing},
              onSelectionChanged: (s) => setState(() => _perServing = s.first),
            ),
            if (_perServing) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _servingGrams,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Tamaño de la ración', suffixText: 'g'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _servingLabel,
                      decoration: const InputDecoration(labelText: 'Nombre (opcional)', hintText: '1 huevo'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _perServing ? 'Valores de esa ración' : 'Valores por 100 g',
                    style: theme.textTheme.labelMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: _calculateKcal,
                  icon: const Icon(Icons.calculate_outlined, size: 16),
                  label: const Text('Calcular kcal'),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _kcal,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'kcal'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _protein,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Proteína (g)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _carbs,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Carbohidratos (g)'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _fat,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Grasas (g)'),
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ],
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(onPressed: _submit, child: const Text('Crear y continuar')),
          ],
        ),
      ),
    );
  }
}
