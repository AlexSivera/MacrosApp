import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/profile_labels.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_date_picker.dart';
import '../../../core/widgets/date_field_tile.dart';
import '../../../core/widgets/macro_preview_row.dart';
import '../../../core/widgets/unit_input_decoration.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../services/nutrition_engine/food_macros_calculator.dart';
import '../../../services/nutrition_engine/goal_weight.dart';
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
  // No default: the formula differs by sex, so it's asked, not assumed.
  BiologicalSex? _sex;
  DateTime _birthDate = DateTime(DateTime.now().year - 25);
  ActivityLevel _activityLevel = ActivityLevel.moderate;
  GoalType _goalType = GoalType.maintain;
  double _weeklyChangeKg = 0.5;
  bool _saving = false;

  // Shown under the field each one belongs to: 'sex', 'height', 'weight',
  // 'goalWeight'.
  Map<String, String> _errors = {};

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

  TdeeInput get _tdeeInput => TdeeInput(
        weightKg: _weight!,
        heightCm: _height!,
        age: _age,
        sex: _sex!,
        activityLevel: _activityLevel,
        goalType: _goalType,
        weeklyWeightChangeKg: _signedWeeklyChange,
      );

  // The targets the Diario will start from — the same Mifflin-St Jeor path
  // resolveTargets() takes for an automatic profile.
  (int, MacroTargets) _targets() {
    final calories = calculateCalorieTarget(_tdeeInput);
    final macros = calculateMacroTargets(
      calorieTarget: calories,
      weightKg: _weight!,
      proteinGramsPerKg: _proteinGramsPerKg,
      fatPercentOfCalories: _fatPercentOfCalories,
    );
    return (calories, macros);
  }

  Map<String, String> _validateStep(int step) {
    final errors = <String, String>{};
    if (step == 0) {
      if (_sex == null) errors['sex'] = 'Elige una opción: la fórmula del gasto diario cambia según el sexo.';
      final height = _height;
      if (height == null) {
        errors['height'] = 'Introduce tu altura';
      } else if (height < 100 || height > 250) {
        errors['height'] = 'Entre 100 y 250 cm';
      }
      final weight = _weight;
      if (weight == null) {
        errors['weight'] = 'Introduce tu peso';
      } else if (weight < 30 || weight > 300) {
        errors['weight'] = 'Entre 30 y 300 kg';
      }
    }
    if (step == 1) {
      final goalError = goalWeightError(_goalType, _goalWeightController.text, _weight);
      if (goalError != null) errors['goalWeight'] = goalError;
    }
    return errors;
  }

  void _clearError(String field) {
    if (_errors.containsKey(field)) setState(() => _errors = {..._errors}..remove(field));
  }

  void _goTo(int step) {
    FocusScope.of(context).unfocus();
    setState(() {
      _step = step;
      _errors = {};
    });
    _pageController.animateToPage(
      step,
      duration: AppMotion.of(context, AppMotion.slow),
      curve: AppMotion.curve,
    );
  }

  void _next() {
    final errors = _validateStep(_step);
    if (errors.isNotEmpty) {
      setState(() => _errors = errors);
      return;
    }
    if (_step < _stepCount - 1) {
      _goTo(_step + 1);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    setState(() => _saving = true);

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
        goalWeightKg: Value(_goalType == GoalType.maintain ? weight : goalWeight),
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
      selected: {?_sex},
      emptySelectionAllowed: true,
      onSelectionChanged: (s) {
        if (s.isEmpty) return; // tapping the chosen one again keeps it
        setState(() => _sex = s.first);
        _clearError('sex');
      },
    ),
    if (_errors['sex'] case final error?)
      Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.md, 0),
        child: Text(
          error,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
        ),
      ),
    const SizedBox(height: AppSpacing.md),
    DateFieldTile(
      label: 'Fecha de nacimiento',
      value: formatLongDate(_birthDate),
      onTap: () async {
        final picked = await showAppDatePicker(
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            decoration: unitInputDecoration(
              label: 'Altura',
              unit: 'cm',
              hint: '175',
              errorText: _errors['height'],
            ),
            onChanged: (_) => _clearError('height'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: unitInputDecoration(
              label: 'Peso actual',
              unit: 'kg',
              hint: '72,5',
              errorText: _errors['weight'],
            ),
            onChanged: (_) => _clearError('weight'),
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
        onSelectionChanged: (s) {
          setState(() => _goalType = s.first);
          _clearError('goalWeight');
        },
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
                    decoration: unitInputDecoration(
                      label: 'Peso objetivo',
                      unit: 'kg',
                      errorText: _errors['goalWeight'],
                    ),
                    onChanged: (_) => _clearError('goalWeight'),
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
        isExpanded: true,
        items: activityLevelItems(),
        onChanged: (v) => setState(() => _activityLevel = v ?? _activityLevel),
      ),
    ];
  }

  Widget _result(BuildContext context) {
    final theme = Theme.of(context);
    final (calories, macros) = _targets();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            children: [
              Text('$calories', style: theme.textTheme.displaySmall?.copyWith(color: theme.colorScheme.primary)),
              Text('kcal al día', style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.lg),
              MacroPreviewRow(
                showKcal: false,
                macros: FoodMacros(
                  kcal: calories.toDouble(),
                  proteinG: macros.proteinG,
                  carbsG: macros.carbsG,
                  fatG: macros.fatG,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _explanation(context, calories),
      ],
    );
  }

  // How the number above was reached, so it isn't a black box: estimated
  // daily burn, the deficit/surplus for the chosen pace, the floor at the
  // resting metabolism, and roughly when the goal weight would be reached.
  Widget _explanation(BuildContext context, int calories) {
    final theme = Theme.of(context);
    int round10(double v) => (v / 10).round() * 10;
    final input = _tdeeInput;
    final tdee = calculateTdee(input);
    final bmr = calculateBmr(weightKg: input.weightKg, heightCm: input.heightCm, age: input.age, sex: input.sex);
    final adjustment = _signedWeeklyChange * 1100; // 7700 kcal per kg, over 7 days
    final flooredAtBmr = tdee + adjustment < bmr;
    final goalWeight = parseDecimal(_goalWeightController.text);
    final eta = _goalType == GoalType.maintain || goalWeight == null
        ? null
        : addDays(DateTime.now(), ((_weight! - goalWeight).abs() / _weeklyChangeKg * 7).round());
    final pace = formatDecimal(_weeklyChangeKg);

    Widget line(String label, String value, {bool strong = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: [
              Expanded(child: Text(label, style: strong ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium)),
              Text(value, style: strong ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium),
            ],
          ),
        );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('CÓMO SE CALCULA', style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 0.6)),
          const SizedBox(height: AppSpacing.sm),
          line('Gasto diario estimado', '${round10(tdee)} kcal'),
          if (_goalType == GoalType.lose) line('Déficit para perder $pace kg/semana', '−${round10(-adjustment)} kcal'),
          if (_goalType == GoalType.gain) line('Superávit para ganar $pace kg/semana', '+${round10(adjustment)} kcal'),
          if (flooredAtBmr)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                'Ajustado a tu metabolismo basal (${round10(bmr)} kcal): comer por debajo no es recomendable. '
                'Prueba un ritmo más suave.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          const Divider(height: AppSpacing.lg),
          line('Tu objetivo diario', '$calories kcal', strong: true),
          const SizedBox(height: AppSpacing.sm),
          if (eta != null && goalWeight != null)
            Text(
              'A este ritmo llegarías a ${formatKg(goalWeight)} hacia ${DateFormat("MMMM 'de' y", 'es').format(eta)}.',
              style: theme.textTheme.bodySmall,
            ),
          Text(
            'Proteína: ${formatDecimal(_proteinGramsPerKg)} g por kg de peso · grasa: '
            '${(_fatPercentOfCalories * 100).round()} % de las calorías · el resto, carbohidratos.',
            style: theme.textTheme.bodySmall,
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
