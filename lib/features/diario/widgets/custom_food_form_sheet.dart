import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import 'food_category_chips.dart';

// "Crear alimento personalizado" / "Editar alimento" — a minimal form (name
// + macros, entered either per 100g or per serving when creating), saved to
// Foods with isCustom = true, then handed back to the caller so it can flow
// straight into quantity entry without an extra round trip.
//
// Editing is only offered for isCustom foods (see FoodSearchSheet) — the
// bundled catalog is re-synced from food_seed_data.dart on every launch
// (see food_seeder.dart), so an edit made here to a non-custom row would
// silently revert the next time the app starts.
class CustomFoodFormSheet extends ConsumerStatefulWidget {
  const CustomFoodFormSheet({super.key, this.food});

  // Non-null means "editing this food" instead of creating a new one.
  final Food? food;

  static Future<Food?> show(BuildContext context) {
    return showModalBottomSheet<Food>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CustomFoodFormSheet(),
    );
  }

  static Future<Food?> showEdit(BuildContext context, {required Food food}) {
    return showModalBottomSheet<Food>(
      context: context,
      isScrollControlled: true,
      builder: (context) => CustomFoodFormSheet(food: food),
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

  bool get _isEditing => widget.food != null;

  @override
  void initState() {
    super.initState();
    final food = widget.food;
    if (food == null) return;
    _name.text = food.name;
    _category = food.category;
    _kcal.text = _formatNum(food.kcalPer100g);
    _protein.text = _formatNum(food.proteinPer100g);
    _carbs.text = _formatNum(food.carbsPer100g);
    _fat.text = _formatNum(food.fatPer100g);
    if (food.defaultServingGrams != null) {
      _servingGrams.text = _formatNum(food.defaultServingGrams!);
    }
    _servingLabel.text = food.servingLabel ?? '';
  }

  static String _formatNum(double v) => v == v.roundToDouble() ? v.round().toString() : v.toString();

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

    // Editing always shows (and trusts) the serving fields as optional
    // metadata, independent of the per-100g/por-ración toggle — which only
    // exists for the create flow, since an existing food's macros are
    // already known per-100g and re-deriving that from a serving size on
    // every edit would just be one more place to introduce rounding drift.
    double? servingGrams;
    if (_isEditing) {
      final text = _servingGrams.text.trim();
      if (text.isNotEmpty) {
        servingGrams = double.tryParse(text.replaceAll(',', '.'));
        if (servingGrams == null || servingGrams <= 0) {
          setState(() => _error = 'El tamaño de la ración no es válido.');
          return;
        }
      }
    } else if (_perServing) {
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
    // a no-op factor of 1 when the user entered per-100g values directly,
    // and always 1 when editing (macros there are always per-100g).
    final factor = (!_isEditing && _perServing) ? 100 / servingGrams! : 1.0;
    final servingLabel = _servingLabel.text.trim().isEmpty ? null : _servingLabel.text.trim();

    final db = ref.read(appDatabaseProvider);
    if (_isEditing) {
      final updated = widget.food!.copyWith(
        name: _name.text.trim(),
        kcalPer100g: enteredKcal,
        proteinPer100g: enteredProtein,
        carbsPer100g: enteredCarbs,
        fatPer100g: enteredFat,
        category: _category,
        defaultServingGrams: Value(servingGrams),
        servingLabel: Value(servingLabel),
      );
      await db.foodsDao.updateFood(updated);
      if (mounted) Navigator.of(context).pop(updated);
      return;
    }

    final id = await db.foodsDao.insert(FoodsCompanion.insert(
      name: _name.text.trim(),
      kcalPer100g: enteredKcal * factor,
      proteinPer100g: enteredProtein * factor,
      carbsPer100g: enteredCarbs * factor,
      fatPer100g: enteredFat * factor,
      isCustom: const Value(true),
      category: Value(_category),
      defaultServingGrams: Value(servingGrams),
      servingLabel: Value(_perServing ? servingLabel : null),
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
            Text(
              _isEditing ? 'Editar alimento' : 'Crear alimento personalizado',
              style: theme.textTheme.titleLarge,
            ),
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
            if (!_isEditing) ...[
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
            ],
            if (_isEditing || _perServing) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _servingGrams,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: _isEditing ? 'Tamaño de ración (opcional)' : 'Tamaño de la ración',
                        suffixText: 'g',
                      ),
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
            ElevatedButton(
              onPressed: _submit,
              child: Text(_isEditing ? 'Guardar cambios' : 'Crear y continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
