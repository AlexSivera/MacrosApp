import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../services/nutrition_engine/recipe_macros_calculator.dart';

// Servings-entry step for a recipe planned on a given day — the Plan
// semanal analogue of RecipeQuantitySheet, writing to MealPlanDao.
class PlanRecipeQuantitySheet extends ConsumerStatefulWidget {
  const PlanRecipeQuantitySheet({
    super.key,
    required this.recipe,
    this.date,
    this.mealType,
    this.entry,
  });

  final Recipe recipe;
  final DateTime? date;
  final MealType? mealType;
  final MealPlanEntry? entry;

  static Future<void> showAdd(
    BuildContext context, {
    required Recipe recipe,
    required DateTime date,
    required MealType mealType,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PlanRecipeQuantitySheet(recipe: recipe, date: date, mealType: mealType),
    );
  }

  static Future<void> showEdit(
    BuildContext context, {
    required Recipe recipe,
    required MealPlanEntry entry,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PlanRecipeQuantitySheet(recipe: recipe, entry: entry),
    );
  }

  @override
  ConsumerState<PlanRecipeQuantitySheet> createState() => _PlanRecipeQuantitySheetState();
}

class _PlanRecipeQuantitySheetState extends ConsumerState<PlanRecipeQuantitySheet> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial = widget.entry?.servings ?? 1.0;
    _controller = TextEditingController(text: _formatServings(initial));
  }

  static String _formatServings(double s) =>
      s == s.roundToDouble() ? s.round().toString() : s.toString();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? get _servings => double.tryParse(_controller.text.replaceAll(',', '.'));

  Future<void> _submit() async {
    final servings = _servings;
    if (servings == null || servings <= 0) {
      setState(() => _error = 'Introduce un número de raciones válido.');
      return;
    }
    final db = ref.read(appDatabaseProvider);

    if (widget.entry != null) {
      await db.mealPlanDao.updateEntryQuantity(widget.entry!.id, servings: servings);
    } else {
      final orderIndex = await db.mealPlanDao.nextOrderIndex(widget.date!, widget.mealType!);
      await db.mealPlanDao.addRecipe(
        date: widget.date!,
        mealType: widget.mealType!,
        recipeId: widget.recipe.id,
        servings: servings,
        orderIndex: orderIndex,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final db = ref.watch(appDatabaseProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        ),
        child: FutureBuilder<List<RecipeIngredient>>(
          future: db.recipeIngredientsDao.getForRecipe(widget.recipe.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return FutureBuilder<List<Food>>(
              future: Future.wait(
                snapshot.data!.map((i) => db.foodsDao.getById(i.foodId)),
              ).then((foods) => foods.whereType<Food>().toList()),
              builder: (context, foodsSnapshot) {
                if (!foodsSnapshot.hasData) {
                  return const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final ingredients = snapshot.data!;
                final foodsById = {for (final f in foodsSnapshot.data!) f.id: f};
                final pairs = [
                  for (final i in ingredients)
                    if (foodsById[i.foodId] != null) (i, foodsById[i.foodId]!),
                ];
                final totals = computeRecipeTotals(pairs);
                final perServing = computePerServing(totals, widget.recipe.servings);
                final servings = _servings;
                final preview =
                    servings != null && servings > 0 ? perServing * servings : null;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(widget.recipe.name, style: theme.textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: 'Raciones', errorText: _error),
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
                );
              },
            );
          },
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
