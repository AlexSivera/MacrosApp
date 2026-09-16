import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/meal_types.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/database/database_provider.dart';

// Move-entry sheet for a planned meal — like the Diario's MoveEntrySheet but
// also offers changing the day, since a plan entry (unlike a diary log) is
// routinely rearranged before it's ever eaten.
class PlanMoveEntrySheet extends ConsumerWidget {
  const PlanMoveEntrySheet({super.key, required this.entryId, required this.currentDate});

  final int entryId;
  final DateTime currentDate;

  static Future<void> show(BuildContext context, {required int entryId, required DateTime currentDate}) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => PlanMoveEntrySheet(entryId: entryId, currentDate: currentDate),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Mover a...', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            for (final meal in mealSectionOrder)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(meal.label),
                onTap: () async {
                  await ref
                      .read(appDatabaseProvider)
                      .mealPlanDao
                      .moveEntry(entryId, newMealType: meal);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('Cambiar de día'),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: currentDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked == null) return;
                await ref.read(appDatabaseProvider).mealPlanDao.moveEntry(entryId, newDate: picked);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
