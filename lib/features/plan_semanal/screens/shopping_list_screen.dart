import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/editable_checklist.dart';
import '../../../data/database/database_provider.dart';
import '../../diario/widgets/food_category_chips.dart';
import '../providers/meal_plan_providers.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/formatters.dart';

// A trip-friendly checklist for the week currently visible in Plan semanal.
// Two independent modes per week (see ShoppingListWeekModes):
// - Automática: aggregated live from the week's planned meals (checked-off
//   items here are local UI state only, not persisted — regenerated fresh
//   from the plan on every visit, so there's nothing worth saving).
// - Manual: a free-text list the user fills in by hand (no grams/units),
//   for when the plan doesn't reflect what's actually left to buy. This one
//   IS persisted per week, checkmarks included, since there's no plan to
//   regenerate it from.
class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = ref.watch(shoppingListWeekDaysProvider);
    final weekStart = ref.watch(shoppingListWeekStartProvider);
    final modeAsync = ref.watch(shoppingListModeProvider);
    final isManual = modeAsync.valueOrNull ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Lista de la compra')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Semana anterior',
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () =>
                      ref.read(shoppingListWeekStartProvider.notifier).state = addDays(weekStart, -7),
                ),
                Expanded(
                  child: Text(
                    'Semana del ${DateFormat('d MMM', 'es').format(days.first)} '
                    'al ${DateFormat('d MMM', 'es').format(days.last)}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Semana siguiente',
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () =>
                      ref.read(shoppingListWeekStartProvider.notifier).state = addDays(weekStart, 7),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Automática')),
                ButtonSegment(value: true, label: Text('Manual')),
              ],
              selected: {isManual},
              onSelectionChanged: (s) =>
                  ref.read(appDatabaseProvider).shoppingListDao.setMode(weekStart, manual: s.first),
            ),
          ),
          Expanded(child: isManual ? const _ManualShoppingList() : const _AutomaticShoppingList()),
        ],
      ),
    );
  }
}

class _AutomaticShoppingList extends ConsumerStatefulWidget {
  const _AutomaticShoppingList();

  @override
  ConsumerState<_AutomaticShoppingList> createState() => _AutomaticShoppingListState();
}

class _AutomaticShoppingListState extends ConsumerState<_AutomaticShoppingList> {
  final _checkedFoodIds = <int>{};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sectionsAsync = ref.watch(shoppingListForWeekProvider);

    return sectionsAsync.when(
      data: (sections) {
        if (sections.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'No hay comidas planificadas para esta semana.\n'
                'Añade alimentos o recetas en Plan semanal y aparecerán aquí.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            for (final section in sections) ...[
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      section.category.label.toUpperCase(),
                      style: theme.textTheme.labelLarge?.copyWith(letterSpacing: 0.6),
                    ),
                    const Divider(height: AppSpacing.lg),
                    for (var i = 0; i < section.items.length; i++) ...[
                      _ShoppingListTile(
                        foodName: section.items[i].food.name,
                        grams: section.items[i].grams,
                        servingGrams: section.items[i].food.defaultServingGrams,
                        checked: _checkedFoodIds.contains(section.items[i].food.id),
                        onChanged: (checked) => setState(() {
                          if (checked) {
                            _checkedFoodIds.add(section.items[i].food.id);
                          } else {
                            _checkedFoodIds.remove(section.items[i].food.id);
                          }
                        }),
                      ),
                      if (i != section.items.length - 1)
                        Divider(
                          height: AppSpacing.md,
                          color: theme.colorScheme.outline.withValues(alpha: 0.5),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error al calcular la compra: $err')),
    );
  }
}

class _ManualShoppingList extends ConsumerWidget {
  const _ManualShoppingList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(shoppingListManualItemsProvider);
    final weekStart = ref.watch(shoppingListWeekStartProvider);
    final db = ref.read(appDatabaseProvider);

    return itemsAsync.when(
      data: (items) => EditableChecklist(
        items: [
          for (final item in items) ChecklistItemData(id: item.id, name: item.name, checked: item.checked),
        ],
        hintText: 'p. ej. pan, tomates...',
        emptyText: 'Añade a mano lo que necesites comprar esta semana.',
        onAdd: (name) => db.shoppingListDao.addManualItem(weekStart, name),
        onToggle: (id, checked) => db.shoppingListDao.updateManualItem(id, checked: checked),
        onDelete: db.shoppingListDao.deleteManualItem,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error al cargar la lista: $err')),
    );
  }
}

class _ShoppingListTile extends StatelessWidget {
  const _ShoppingListTile({
    required this.foodName,
    required this.grams,
    required this.servingGrams,
    required this.checked,
    required this.onChanged,
  });

  final String foodName;
  final double grams;
  final double? servingGrams;
  final bool checked;
  final ValueChanged<bool> onChanged;

  // A food with a known piece size ("1 huevo ≈ 50g") reads as a shopping
  // quantity better in units than in grams — "3 huevos" beats "150 g" at
  // the supermarket. Falls back to grams for anything without one.
  static String _formatQuantity(double grams, double? servingGrams) {
    if (servingGrams != null && servingGrams > 0) {
      final units = grams / servingGrams;
      final rounded = units.roundToDouble();
      final display = (units - rounded).abs() < 0.05 ? rounded : (units * 10).round() / 10;
      final displayText = formatDecimal(display);
      return '$displayText ${display == 1 ? 'ud' : 'uds'}';
    }
    if (grams >= 1000) {
      final kg = grams / 1000;
      return '${formatDecimal(kg)} kg';
    }
    return '${grams.round()} g';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => onChanged(!checked),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Checkbox(value: checked, onChanged: (v) => onChanged(v ?? false)),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                foodName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  decoration: checked ? TextDecoration.lineThrough : null,
                  color: checked ? theme.colorScheme.onSurfaceVariant : null,
                ),
              ),
            ),
            Text(_formatQuantity(grams, servingGrams), style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
