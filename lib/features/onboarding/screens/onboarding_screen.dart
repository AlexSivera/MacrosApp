import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/date_field_tile.dart';
import '../../../core/widgets/macro_preview_row.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../services/nutrition_engine/food_macros_calculator.dart';
import '../../../services/nutrition_engine/macro_targets_calculator.dart';
import '../../../services/nutrition_engine/tdee_calculator.dart';

// First-run setup in three short steps — about you, your goal, and the
// resulting plan — ending on the calorie/macro targets it computed, so the
// numbers the Diario starts from aren't a surprise.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _stepCount = 3;

  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _goalWeightController = TextEditingController();

  int _step = 0;
  BiologicalSex _sex = BiologicalSex.male;
  DateTime _birthDate = DateTime(DateTime.now().year - 25);
  ActivityLevel _activityLevel = ActivityLevel.moderate;
  GoalType _goalType = GoalType.maintain;
  double _weeklyChangeKg = 0.5;
  bool _saving = false;
  String? _error;

  // Same defaults as the UserProfile table (protein g/kg, fat % of kcal).
  static const _proteinGramsPerKg = 1.8;
  static const _fatPercentOfCalories = 0.28;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _goalWeightController.dispose();
    super.dispose();
  }

  double? get _height => parseDecimal(_heightController.text);
  double? get _weight => parseDecimal(_weightController.text);

  double get _signedWeeklyChange => switch (_goalType) {
    GoalType.maintain => 0.0,
    GoalType.lose => -_weeklyChangeKg,
    GoalType.gain => _weeklyChangeKg,
  };

  int get _age {
    final now = DateTime.now();
    var age = now.year - _birthDate.year;
    if (now.month < _birthDate.month || (now.month == _birthDate.month && now.day < _birthDate.day)) {
      age--;
    }
    return age;
  }

  // The targets the Diario will start from — the same Mifflin-St Jeor path
  // resolveTargets() takes for an automatic profile.
  (int, MacroTargets) _targets() {
    final calories = calculateCalorieTarget(
      TdeeInput(
        weightKg: _weight!,
        heightCm: _height!,
        age: _age,
        sex: _sex,
        activityLevel: _activityLevel,
        goalType: _goalType,
        weeklyWeightChangeKg: _signedWeeklyChange,
      ),
    );
    final macros = calculateMacroTargets(
      calorieTarget: calories,
      weightKg: _weight!,
      proteinGramsPerKg: _proteinGramsPerKg,
      fatPercentOfCalories: _fatPercentOfCalories,
    );
    return (calories, macros);
  }

  String? _validateStep(int step) {
    if (step == 0) {
      final height = _height;
      final weight = _weight;
      if (height == null || height < 100 || height > 250) return 'Introduce tu altura en cm (p. ej. 175).';
      if (weight == null || weight < 30 || weight > 300) return 'Introduce tu peso en kg (p. ej. 72,5).';
    }
    if (step == 1 && _goalType != GoalType.maintain && _goalWeightController.text.trim().isNotEmpty) {
      final goal = parseDecimal(_goalWeightController.text);
      if (goal == null || goal < 30 || goal > 300) return 'El peso objetivo no parece válido.';
    }
    return null;
  }

  void _goTo(int step) {
    FocusScope.of(context).unfocus();
    setState(() {
      _step = step;
      _error = null;
    });
    _pageController.animateToPage(
      step,
      duration: AppMotion.of(context, AppMotion.slow),
      curve: AppMotion.curve,
    );
  }

  void _next() {
    final error = _validateStep(_step);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    if (_step < _stepCount - 1) {
      _goTo(_step + 1);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    setState(() {
      _saving = true;
      _error = null;
    });

    final db = ref.read(appDatabaseProvider);
    final weight = _weight!;
    final goalWeight = parseDecimal(_goalWeightController.text);

    await db.userProfileDao.updateProfile(
      UserProfileCompanion(
        name: Value(_nameController.text.trim().isEmpty ? null : _nameController.text.trim()),
        sex: Value(_sex),
        birthDate: Value(_birthDate),
        heightCm: Value(_height!),
        activityLevel: Value(_activityLevel),
        goalType: Value(_goalType),
        weeklyWeightChangeKg: Value(_signedWeeklyChange),
        startingWeightKg: Value(weight),
        goalWeightKg: Value(_goalType == GoalType.maintain ? weight : (goalWeight ?? weight)),
        onboardingCompleted: const Value(true),
      ),
    );
    await db.bodyWeightDao.logForDay(DateTime.now(), weight);

    if (mounted) context.go('/diario');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Paso ${_step + 1} de $_stepCount', style: theme.textTheme.labelMedium),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: (_step + 1) / _stepCount),
                      duration: AppMotion.of(context, AppMotion.slow),
                      curve: AppMotion.curve,
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 6,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _StepPage(
                    title: 'Sobre ti',
                    subtitle: 'Lo necesitamos para calcular cuánto gastas al día.',
                    children: _aboutYou(context),
                  ),
                  _StepPage(
                    title: 'Tu objetivo',
                    subtitle: 'Puedes cambiarlo cuando quieras en Perfil.',
                    children: _goal(context),
                  ),
                  _StepPage(
                    title: 'Tu plan',
                    subtitle: 'Este es tu objetivo diario. Podrás ajustarlo en Perfil.',
                    children: [if (_step == 2 && _height != null && _weight != null) _result(context)],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnimatedSize(
                    duration: AppMotion.of(context, AppMotion.fast),
                    child: _error == null
                        ? const SizedBox(width: double.infinity)
                        : Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                          ),
                  ),
                  Row(
                    children: [
                      if (_step > 0) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _saving ? null : () => _goTo(_step - 1),
                            child: const Text('Atrás'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                      ],
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _next,
                          child: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(_step == _stepCount - 1 ? 'Empezar' : 'Siguiente'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _aboutYou(BuildContext context) => [
    TextField(
      controller: _nameController,
      textCapitalization: TextCapitalization.words,
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
      value: DateFormat('d MMM y', 'es').format(_birthDate),
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
            decoration: const InputDecoration(labelText: 'Altura', suffixText: 'cm'),
            onChanged: (_) => setState(() => _error = null),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Peso actual', suffixText: 'kg'),
            onChanged: (_) => setState(() => _error = null),
          ),
        ),
      ],
    ),
  ];

  List<Widget> _goal(BuildContext context) {
    final theme = Theme.of(context);
    return [
      SegmentedButton<GoalType>(
        segments: const [
          ButtonSegment(value: GoalType.lose, label: Text('Perder')),
          ButtonSegment(value: GoalType.maintain, label: Text('Mantener')),
          ButtonSegment(value: GoalType.gain, label: Text('Ganar')),
        ],
        selected: {_goalType},
        onSelectionChanged: (s) => setState(() => _goalType = s.first),
      ),
      // Grows open for the extra fields instead of them popping in.
      AnimatedSize(
        duration: AppMotion.of(context, AppMotion.normal),
        curve: AppMotion.curve,
        alignment: Alignment.topCenter,
        child: _goalType == GoalType.maintain
            ? const SizedBox(width: double.infinity)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _goalWeightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Peso objetivo (opcional)',
                      suffixText: 'kg',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Ritmo: ${formatDecimal(_weeklyChangeKg)} kg/semana',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Slider(
                    value: _weeklyChangeKg,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    label: '${formatDecimal(_weeklyChangeKg)} kg',
                    onChanged: (v) => setState(() => _weeklyChangeKg = v),
                  ),
                ],
              ),
      ),
      const SizedBox(height: AppSpacing.xl),
      Text('ACTIVIDAD', style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 0.6)),
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
    ];
  }

  Widget _result(BuildContext context) {
    final theme = Theme.of(context);
    final (calories, macros) = _targets();
    return AppCard(
      child: Column(
        children: [
          Text('$calories', style: theme.textTheme.displaySmall?.copyWith(color: theme.colorScheme.primary)),
          Text('kcal al día', style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          MacroPreviewRow(
            macros: FoodMacros(
              kcal: calories.toDouble(),
              proteinG: macros.proteinG,
              carbsG: macros.carbsG,
              fatG: macros.fatG,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepPage extends StatelessWidget {
  const _StepPage({required this.title, required this.subtitle, required this.children});

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(title, style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: theme.textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xl),
        ...children,
      ],
    );
  }
}
