import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/date_field_tile.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _goalWeightController = TextEditingController();

  BiologicalSex _sex = BiologicalSex.male;
  DateTime _birthDate = DateTime(DateTime.now().year - 25);
  ActivityLevel _activityLevel = ActivityLevel.moderate;
  GoalType _goalType = GoalType.maintain;
  double _weeklyChangeKg = 0.5;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _goalWeightController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final height = double.tryParse(_heightController.text.replaceAll(',', '.'));
    final weight = double.tryParse(_weightController.text.replaceAll(',', '.'));
    final goalWeight = double.tryParse(_goalWeightController.text.replaceAll(',', '.'));

    if (height == null || height <= 0) {
      setState(() => _error = 'Introduce una altura válida.');
      return;
    }
    if (weight == null || weight <= 0) {
      setState(() => _error = 'Introduce un peso válido.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final db = ref.read(appDatabaseProvider);
    final weeklyChange = _goalType == GoalType.maintain
        ? 0.0
        : (_goalType == GoalType.lose ? -_weeklyChangeKg : _weeklyChangeKg);

    await db.userProfileDao.updateProfile(UserProfileCompanion(
      name: Value(_nameController.text.trim().isEmpty ? null : _nameController.text.trim()),
      sex: Value(_sex),
      birthDate: Value(_birthDate),
      heightCm: Value(height),
      activityLevel: Value(_activityLevel),
      goalType: Value(_goalType),
      weeklyWeightChangeKg: Value(weeklyChange),
      startingWeightKg: Value(weight),
      goalWeightKg: Value(goalWeight ?? weight),
      onboardingCompleted: const Value(true),
    ));
    await db.bodyWeightDao.insertLog(BodyWeightLogsCompanion.insert(
      date: DateTime.now(),
      weightKg: weight,
    ));

    if (mounted) context.go('/diario');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('Antes de empezar', style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Necesitamos unos datos para calcular tus calorías y macros.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            _SectionLabel('Sobre ti'),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre (opcional)'),
            ),
            const SizedBox(height: AppSpacing.md),
            SegmentedButton<BiologicalSex>(
              segments: const [
                ButtonSegment(value: BiologicalSex.male, label: Text('Hombre')),
                ButtonSegment(value: BiologicalSex.female, label: Text('Mujer')),
              ],
              selected: {_sex},
              onSelectionChanged: (s) => setState(() => _sex = s.first),
            ),
            const SizedBox(height: AppSpacing.md),
            DateFieldTile(
              label: 'Fecha de nacimiento',
              value: '${_birthDate.day}/${_birthDate.month}/${_birthDate.year}',
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _birthDate,
                  firstDate: DateTime(1920),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _birthDate = picked);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Altura (cm)'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Peso actual (kg)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _SectionLabel('Tu objetivo'),
            const SizedBox(height: AppSpacing.sm),
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
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _goalWeightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Peso objetivo (kg)'),
              ),
              const SizedBox(height: AppSpacing.md),
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
            _SectionLabel('Actividad'),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<ActivityLevel>(
              initialValue: _activityLevel,
              items: const [
                DropdownMenuItem(value: ActivityLevel.sedentary, child: Text('Sedentario')),
                DropdownMenuItem(value: ActivityLevel.light, child: Text('Ligera (1-3 días/semana)')),
                DropdownMenuItem(value: ActivityLevel.moderate, child: Text('Moderada (3-5 días/semana)')),
                DropdownMenuItem(value: ActivityLevel.active, child: Text('Alta (6-7 días/semana)')),
                DropdownMenuItem(value: ActivityLevel.veryActive, child: Text('Muy alta (físico + deporte)')),
              ],
              onChanged: (v) => setState(() => _activityLevel = v ?? _activityLevel),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ],
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton(
              onPressed: _saving ? null : _finish,
              child: _saving
                  ? const SizedBox(
                      width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Empezar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 0.6),
    );
  }
}
