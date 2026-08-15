import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import 'food_category_chips.dart';

// "Crear alimento personalizado" — a minimal form (name + macros per 100g),
// saved to Foods with isCustom = true, then handed back to the caller so it
// can flow straight into quantity entry without an extra round trip.
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
  FoodCategory _category = FoodCategory.otros;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _kcal.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    super.dispose();
  }

  double _parse(String text) => double.tryParse(text.replaceAll(',', '.')) ?? 0;

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Ponle un nombre al alimento.');
      return;
    }
    final kcal = _parse(_kcal.text);
    final protein = _parse(_protein.text);
    final carbs = _parse(_carbs.text);
    final fat = _parse(_fat.text);
    if (kcal < 0 || protein < 0 || carbs < 0 || fat < 0) {
      setState(() => _error = 'Los valores no pueden ser negativos.');
      return;
    }

    final db = ref.read(appDatabaseProvider);
    final id = await db.foodsDao.insert(FoodsCompanion.insert(
      name: _name.text.trim(),
      kcalPer100g: kcal,
      proteinPer100g: protein,
      carbsPer100g: carbs,
      fatPer100g: fat,
      isCustom: const Value(true),
      category: Value(_category),
    ));
    final food = await db.foodsDao.getById(id);
    if (mounted) Navigator.of(context).pop(food);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            const SizedBox(height: AppSpacing.md),
            Text('Valores por 100 g', style: theme.textTheme.labelMedium),
            const SizedBox(height: AppSpacing.sm),
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
