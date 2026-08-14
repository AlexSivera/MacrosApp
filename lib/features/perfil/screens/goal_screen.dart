import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../diario/providers/diary_providers.dart';

class GoalScreen extends ConsumerStatefulWidget {
  const GoalScreen({super.key});

  @override
  ConsumerState<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends ConsumerState<GoalScreen> {
  final _goalWeight = TextEditingController();
  GoalType _goalType = GoalType.maintain;
  double _weeklyChangeKg = 0.5;
  bool _initialized = false;

  void _initFrom(UserProfileData profile) {
    if (_initialized) return;
    _initialized = true;
    _goalType = profile.goalType;
    _weeklyChangeKg = profile.weeklyWeightChangeKg.abs().clamp(0.1, 1.0);
    if (_weeklyChangeKg == 0) _weeklyChangeKg = 0.5;
    _goalWeight.text = profile.goalWeightKg != null ? _fmt(profile.goalWeightKg!) : '';
  }

  static String _fmt(double v) => v == v.roundToDouble() ? v.round().toString() : v.toString();

  @override
  void dispose() {
    _goalWeight.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final goalWeight = double.tryParse(_goalWeight.text.replaceAll(',', '.'));
    final weeklyChange = _goalType == GoalType.maintain
        ? 0.0
        : (_goalType == GoalType.lose ? -_weeklyChangeKg : _weeklyChangeKg);
    await ref.read(appDatabaseProvider).userProfileDao.updateProfile(UserProfileCompanion(
          goalType: Value(_goalType),
          weeklyWeightChangeKg: Value(weeklyChange),
          goalWeightKg: Value(goalWeight),
        ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi objetivo')),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) return const Center(child: CircularProgressIndicator());
          _initFrom(profile);
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              SegmentedButton<GoalType>(
                segments: const [
                  ButtonSegment(value: GoalType.lose, label: Text('Perder')),
                  ButtonSegment(value: GoalType.maintain, label: Text('Mantener')),
                  ButtonSegment(value: GoalType.gain, label: Text('Ganar')),
                ],
                selected: {_goalType},
                onSelectionChanged: (s) => setState(() => _goalType = s.first),
              ),
              if (_goalType != GoalType.maintain) ...[
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _goalWeight,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Peso objetivo (kg)'),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Ritmo: ${_weeklyChangeKg.toStringAsFixed(1)} kg/semana',
                    style: theme.textTheme.bodyMedium),
                Slider(
                  value: _weeklyChangeKg,
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  label: '${_weeklyChangeKg.toStringAsFixed(1)} kg',
                  onChanged: (v) => setState(() => _weeklyChangeKg = v),
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
