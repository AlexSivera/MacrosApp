import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/meal_types.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/database/database_provider.dart';

class MoveEntrySheet extends ConsumerWidget {
  const MoveEntrySheet({super.key, required this.entryId});

  final int entryId;

  static Future<void> show(BuildContext context, {required int entryId}) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => MoveEntrySheet(entryId: entryId),
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
                  await ref.read(appDatabaseProvider).diaryDao.moveEntryToMeal(entryId, meal);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}
