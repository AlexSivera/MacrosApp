import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/app_card.dart';
import '../../progreso/screens/log_weight_sheet.dart';
import '../providers/diary_providers.dart';

// Weighing in lives under Perfil > Progreso, three taps deep, so the Diario
// nudges once a week: shown only when the last weigh-in is 7+ days old (or
// there's none) and gone as soon as one is logged.
class WeighInReminder extends ConsumerWidget {
  const WeighInReminder({super.key});

  static const staleAfterDays = 7;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestAsync = ref.watch(latestWeightLogProvider);
    // Nothing until the query answers, so the card never flashes in.
    if (!latestAsync.hasValue) return const SizedBox.shrink();
    final latest = latestAsync.value;
    final daysSince = latest == null ? null : daysBetween(latest.date, ref.watch(todayProvider));
    if (daysSince != null && daysSince < staleAfterDays) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: AppCard(
        onTap: () => LogWeightSheet.show(context),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: AppTheme.tint(context), shape: BoxShape.circle),
              child: Icon(Icons.monitor_weight_outlined, size: 18, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Registra tu peso', style: theme.textTheme.titleMedium),
                  Text(
                    daysSince == null ? 'Aún no hay ningún registro.' : 'El último fue hace $daysSince días.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(Icons.add_rounded, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
