import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/meal_types.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/macro_preview_row.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../services/nutrition_engine/food_macros_calculator.dart';
import '../../../services/nutrition_engine/recipe_macros_calculator.dart';
import 'added_entry_snack_bar.dart';

// Servings-entry step for a recipe, on a given day — used by the Plan
// (mealType known from the section tapped, planned), the Diario (eaten) and
// the recipe detail screen's "Añadir al diario" (mealType unknown, picked
// here via dropdown; eaten).
class PlanRecipeQuantitySheet extends ConsumerStatefulWidget {
  const PlanRecipeQuantitySheet({
    super.key,
    required this.recipe,
    this.date,
    this.mealType,
    this.entry,
    this.eaten = false,
  });

  final Recipe recipe;
  final DateTime? date;
  final MealType? mealType;
  final MealPlanEntry? entry;
  final bool eaten;

  static Future<void> showAdd(
    BuildContext context, {
    required Recipe recipe,
    required DateTime date,
    MealType? mealType,
    bool eaten = false,
  }) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => PlanRecipeQuantitySheet(
        recipe: recipe,
        date: date,
        mealType: mealType,
        eaten: eaten,
      ),
    );
  }

  static Future<void> showEdit(
    BuildContext context, {
    required Recipe recipe,
    required MealPlanEntry entry,
  }) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => PlanRecipeQuantitySheet(recipe: recipe, entry: entry),
    );
  }

  @override
  ConsumerState<PlanRecipeQuantitySheet> createState() => _PlanRecipeQuantitySheetState();
}

class _PlanRecipeQuantitySheetState extends ConsumerState<PlanRecipeQuantitySheet> {
  late final TextEditingController _controller;
  late MealType _mealType;
  late final Future<FoodMacros> _perServing;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial = widget.entry?.servings ?? 1.0;
    _controller = TextEditingController(text: formatInputNumber(initial));
    // Pre-selected, so typing replaces the value instead of appending to it.
    _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
    // Opened from the recipe itself (no meal section tapped): start from the
    // meal its category names.
    _mealType = widget.mealType ??
        widget.entry?.mealType ??
        switch (widget.recipe.category) {
          RecipeCategory.breakfast => MealType.breakfast,
          RecipeCategory.lunch => MealType.lunch,
          RecipeCategory.dinner => MealType.dinner,
          RecipeCategory.snack => MealType.snack,
        };
    _perServing = _loadPerServing();
  }

  // Loaded once, not in build(): a FutureBuilder fed a fresh Future every
  // keystroke flashed a spinner on each digit typed.
  Future<FoodMacros> _loadPerServing() async {
    final db = ref.read(appDatabaseProvider);
    final ingredients = await db.recipeIngredientsDao.getForRecipe(widget.recipe.id);
    final foods = await Future.wait(ingredients.map((i) => db.foodsDao.getById(i.foodId)));
    final pairs = [
      for (var i = 0; i < ingredients.length; i++)
        if (foods[i] != null) (ingredients[i], foods[i]!),
    ];
    return computePerServing(computeRecipeTotals(pairs), widget.recipe.servings);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? get _servings => parseDecimal(_controller.text);

  Future<void> _submit() async {
    final servings = _servings;
    if (servings == null || servings <= 0) {
      setState(() => _error = 'Introduce un número de raciones válido.');
      return;
    }
    final db = ref.read(appDatabaseProvider);
    final messenger = ScaffoldMessenger.of(context);

    if (widget.entry != null) {
      await db.mealPlanDao.updateEntryQuantity(widget.entry!.id, servings: servings);
    } else {
      final orderIndex = await db.mealPlanDao.nextOrderIndex(widget.date!, _mealType);
      final entryId = await db.mealPlanDao.addRecipe(
        date: widget.date!,
        mealType: _mealType,
        recipeId: widget.recipe.id,
        servings: servings,
        orderIndex: orderIndex,
        eaten: widget.eaten,
      );
      showAddedEntrySnackBar(messenger, db: db, entryId: entryId, mealType: _mealType, eaten: widget.eaten);
    }

    if (mounted) Navigator.of(context).pop();
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
        child: FutureBuilder<FoodMacros>(
          future: _perServing,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final servings = _servings;
            final preview = servings != null && servings > 0 ? snapshot.data! * servings : null;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(widget.recipe.name, style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                if (widget.mealType == null && widget.entry == null) ...[
                  DropdownButtonFormField<MealType>(
                    initialValue: _mealType,
                    decoration: const InputDecoration(labelText: 'Comida'),
                    items: [
                      for (final meal in mealSectionOrder)
                        DropdownMenuItem(value: meal, child: Text(meal.label)),
                    ],
                    onChanged: (v) => setState(() => _mealType = v ?? _mealType),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                TextField(
                  controller: _controller,
                  autofocus: widget.mealType != null || widget.entry != null,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: 'Raciones', errorText: _error),
                  onChanged: (_) => setState(() => _error = null),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    for (final v in const [0.5, 1.0, 1.5, 2.0])
                      ActionChip(
                        label: Text(v == 1 ? '1 ración' : '${formatDecimal(v)} raciones'),
                        onPressed: () => setState(() {
                          _error = null;
                          _controller.text = formatInputNumber(v);
                        }),
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
            );
          },
        ),
      ),
    );
  }
}
