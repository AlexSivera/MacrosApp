import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../diario/providers/diary_providers.dart';

class UnitsScreen extends ConsumerWidget {
  const UnitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Unidades')),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) return const Center(child: CircularProgressIndicator());
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text('Peso', style: theme.textTheme.labelMedium),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<WeightUnit>(
                segments: const [
                  ButtonSegment(value: WeightUnit.kg, label: Text('kg')),
                  ButtonSegment(value: WeightUnit.lb, label: Text('lb')),
                ],
                selected: {profile.weightUnit},
                onSelectionChanged: (s) => ref.read(appDatabaseProvider).userProfileDao.updateProfile(
                      UserProfileCompanion(weightUnit: Value(s.first)),
                    ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Alimentos', style: theme.textTheme.labelMedium),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<FoodMassUnit>(
                segments: const [
                  ButtonSegment(value: FoodMassUnit.g, label: Text('g')),
                  ButtonSegment(value: FoodMassUnit.oz, label: Text('oz')),
                ],
                selected: {profile.foodMassUnit},
                onSelectionChanged: (s) => ref.read(appDatabaseProvider).userProfileDao.updateProfile(
                      UserProfileCompanion(foodMassUnit: Value(s.first)),
                    ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
