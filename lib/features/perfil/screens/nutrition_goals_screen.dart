import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../diario/providers/diary_providers.dart';

class NutritionGoalsScreen extends ConsumerStatefulWidget {
  const NutritionGoalsScreen({super.key});

  @override
  ConsumerState<NutritionGoalsScreen> createState() => _NutritionGoalsScreenState();
}

class _NutritionGoalsScreenState extends ConsumerState<NutritionGoalsScreen> {
  final _kcal = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fat = TextEditingController();
  CalorieTargetMode _mode = CalorieTargetMode.automatic;
  bool _initialized = false;

  void _initFrom(UserProfileData profile, ResolvedTargets resolved) {
    if (_initialized) return;
    _initialized = true;
    _mode = profile.calorieTargetMode;
    _kcal.text = (profile.manualCalorieTarget ?? resolved.calorieTarget).toString();
    _protein.text = (profile.manualProteinTargetG ?? resolved.proteinG).round().toString();
    _carbs.text = (profile.manualCarbTargetG ?? resolved.carbsG).round().toString();
    _fat.text = (profile.manualFatTargetG ?? resolved.fatG).round().toString();
  }

  @override
  void dispose() {
    _kcal.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref.read(appDatabaseProvider).userProfileDao.updateProfile(UserProfileCompanion(
          calorieTargetMode: Value(_mode),
          manualCalorieTarget: Value(int.tryParse(_kcal.text)),
          manualProteinTargetG: Value(double.tryParse(_protein.text)),
          manualCarbTargetG: Value(double.tryParse(_carbs.text)),
          manualFatTargetG: Value(double.tryParse(_fat.text)),
        ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(userProfileStreamProvider);
    final resolved = ref.watch(resolvedTargetsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Objetivos nutricionales')),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) return const Center(child: CircularProgressIndicator());
          _initFrom(profile, resolved);
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              SegmentedButton<CalorieTargetMode>(
                segments: const [
                  ButtonSegment(value: CalorieTargetMode.automatic, label: Text('Automático')),
                  ButtonSegment(value: CalorieTargetMode.manual, label: Text('Manual')),
                ],
                selected: {_mode},
                onSelectionChanged: (s) => setState(() => _mode = s.first),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_mode == CalorieTargetMode.automatic)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Calculado a partir de tus datos y objetivo', style: theme.textTheme.bodySmall),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        '${resolved.calorieTarget} kcal · P${resolved.proteinG.round()}g · '
                        'C${resolved.carbsG.round()}g · G${resolved.fatG.round()}g',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              else ...[
                TextField(
                  controller: _kcal,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Calorías objetivo', suffixText: 'kcal'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _protein,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Proteínas', suffixText: 'g'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _carbs,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Carbohidratos', suffixText: 'g'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _fat,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Grasas', suffixText: 'g'),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(onPressed: _save, child: const Text('Guardar')),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
