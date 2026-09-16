import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../diario/widgets/food_category_chips.dart';
import '../providers/meal_plan_providers.dart';

// A trip-friendly checklist for the week currently visible in Plan semanal —
// checked-off items are local UI state only (a Set of food ids), not
// persisted: crossing an item off mid-aisle isn't data worth keeping once
// the list itself is regenerated from the plan on the next visit.
class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  final _checkedFoodIds = <int>{};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = ref.watch(selectedWeekDaysProvider);
    final sectionsAsync = ref.watch(shoppingListForWeekProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de la compra'),
      ),
      body: sectionsAsync.when(
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
              Text(
                'Semana del ${DateFormat('d MMM', 'es').format(days.first)} '
                'al ${DateFormat('d MMM', 'es').format(days.last)}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
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
      ),
    );
  }
}

class _ShoppingListTile extends StatelessWidget {
  const _ShoppingListTile({
    required this.foodName,
    required this.grams,
    required this.checked,
    required this.onChanged,
  });

  final String foodName;
  final double grams;
  final bool checked;
  final ValueChanged<bool> onChanged;

  static String _formatGrams(double grams) {
    if (grams >= 1000) {
      final kg = grams / 1000;
      return '${kg == kg.roundToDouble() ? kg.round() : kg.toStringAsFixed(1)} kg';
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
            Text(_formatGrams(grams), style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
