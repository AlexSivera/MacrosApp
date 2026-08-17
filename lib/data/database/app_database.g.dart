// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserProfileTable extends UserProfile
    with TableInfo<$UserProfileTable, UserProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BiologicalSex?, int> sex =
      GeneratedColumn<int>(
        'sex',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<BiologicalSex?>($UserProfileTable.$convertersexn);
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ActivityLevel, int>
  activityLevel = GeneratedColumn<int>(
    'activity_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: Constant(ActivityLevel.moderate.index),
  ).withConverter<ActivityLevel>($UserProfileTable.$converteractivityLevel);
  @override
  late final GeneratedColumnWithTypeConverter<GoalType, int> goalType =
      GeneratedColumn<int>(
        'goal_type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(GoalType.maintain.index),
      ).withConverter<GoalType>($UserProfileTable.$convertergoalType);
  static const VerificationMeta _weeklyWeightChangeKgMeta =
      const VerificationMeta('weeklyWeightChangeKg');
  @override
  late final GeneratedColumn<double> weeklyWeightChangeKg =
      GeneratedColumn<double>(
        'weekly_weight_change_kg',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _startingWeightKgMeta = const VerificationMeta(
    'startingWeightKg',
  );
  @override
  late final GeneratedColumn<double> startingWeightKg = GeneratedColumn<double>(
    'starting_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goalWeightKgMeta = const VerificationMeta(
    'goalWeightKg',
  );
  @override
  late final GeneratedColumn<double> goalWeightKg = GeneratedColumn<double>(
    'goal_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CalorieTargetMode, int>
  calorieTargetMode =
      GeneratedColumn<int>(
        'calorie_target_mode',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(CalorieTargetMode.automatic.index),
      ).withConverter<CalorieTargetMode>(
        $UserProfileTable.$convertercalorieTargetMode,
      );
  static const VerificationMeta _manualCalorieTargetMeta =
      const VerificationMeta('manualCalorieTarget');
  @override
  late final GeneratedColumn<int> manualCalorieTarget = GeneratedColumn<int>(
    'manual_calorie_target',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinGramsPerKgMeta = const VerificationMeta(
    'proteinGramsPerKg',
  );
  @override
  late final GeneratedColumn<double> proteinGramsPerKg =
      GeneratedColumn<double>(
        'protein_grams_per_kg',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(1.8),
      );
  static const VerificationMeta _fatPercentOfCaloriesMeta =
      const VerificationMeta('fatPercentOfCalories');
  @override
  late final GeneratedColumn<double> fatPercentOfCalories =
      GeneratedColumn<double>(
        'fat_percent_of_calories',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.28),
      );
  static const VerificationMeta _manualProteinTargetGMeta =
      const VerificationMeta('manualProteinTargetG');
  @override
  late final GeneratedColumn<double> manualProteinTargetG =
      GeneratedColumn<double>(
        'manual_protein_target_g',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _manualCarbTargetGMeta = const VerificationMeta(
    'manualCarbTargetG',
  );
  @override
  late final GeneratedColumn<double> manualCarbTargetG =
      GeneratedColumn<double>(
        'manual_carb_target_g',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _manualFatTargetGMeta = const VerificationMeta(
    'manualFatTargetG',
  );
  @override
  late final GeneratedColumn<double> manualFatTargetG = GeneratedColumn<double>(
    'manual_fat_target_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WeightUnit, int> weightUnit =
      GeneratedColumn<int>(
        'weight_unit',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(WeightUnit.kg.index),
      ).withConverter<WeightUnit>($UserProfileTable.$converterweightUnit);
  @override
  late final GeneratedColumnWithTypeConverter<FoodMassUnit, int> foodMassUnit =
      GeneratedColumn<int>(
        'food_mass_unit',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(FoodMassUnit.g.index),
      ).withConverter<FoodMassUnit>($UserProfileTable.$converterfoodMassUnit);
  @override
  late final GeneratedColumnWithTypeConverter<AppearanceMode, int>
  appearanceMode = GeneratedColumn<int>(
    'appearance_mode',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: Constant(AppearanceMode.dark.index),
  ).withConverter<AppearanceMode>($UserProfileTable.$converterappearanceMode);
  static const VerificationMeta _remindersEnabledMeta = const VerificationMeta(
    'remindersEnabled',
  );
  @override
  late final GeneratedColumn<bool> remindersEnabled = GeneratedColumn<bool>(
    'reminders_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminders_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _onboardingCompletedMeta =
      const VerificationMeta('onboardingCompleted');
  @override
  late final GeneratedColumn<bool> onboardingCompleted = GeneratedColumn<bool>(
    'onboarding_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sex,
    birthDate,
    heightCm,
    activityLevel,
    goalType,
    weeklyWeightChangeKg,
    startingWeightKg,
    goalWeightKg,
    calorieTargetMode,
    manualCalorieTarget,
    proteinGramsPerKg,
    fatPercentOfCalories,
    manualProteinTargetG,
    manualCarbTargetG,
    manualFatTargetG,
    weightUnit,
    foodMassUnit,
    appearanceMode,
    remindersEnabled,
    onboardingCompleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfileData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('weekly_weight_change_kg')) {
      context.handle(
        _weeklyWeightChangeKgMeta,
        weeklyWeightChangeKg.isAcceptableOrUnknown(
          data['weekly_weight_change_kg']!,
          _weeklyWeightChangeKgMeta,
        ),
      );
    }
    if (data.containsKey('starting_weight_kg')) {
      context.handle(
        _startingWeightKgMeta,
        startingWeightKg.isAcceptableOrUnknown(
          data['starting_weight_kg']!,
          _startingWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('goal_weight_kg')) {
      context.handle(
        _goalWeightKgMeta,
        goalWeightKg.isAcceptableOrUnknown(
          data['goal_weight_kg']!,
          _goalWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('manual_calorie_target')) {
      context.handle(
        _manualCalorieTargetMeta,
        manualCalorieTarget.isAcceptableOrUnknown(
          data['manual_calorie_target']!,
          _manualCalorieTargetMeta,
        ),
      );
    }
    if (data.containsKey('protein_grams_per_kg')) {
      context.handle(
        _proteinGramsPerKgMeta,
        proteinGramsPerKg.isAcceptableOrUnknown(
          data['protein_grams_per_kg']!,
          _proteinGramsPerKgMeta,
        ),
      );
    }
    if (data.containsKey('fat_percent_of_calories')) {
      context.handle(
        _fatPercentOfCaloriesMeta,
        fatPercentOfCalories.isAcceptableOrUnknown(
          data['fat_percent_of_calories']!,
          _fatPercentOfCaloriesMeta,
        ),
      );
    }
    if (data.containsKey('manual_protein_target_g')) {
      context.handle(
        _manualProteinTargetGMeta,
        manualProteinTargetG.isAcceptableOrUnknown(
          data['manual_protein_target_g']!,
          _manualProteinTargetGMeta,
        ),
      );
    }
    if (data.containsKey('manual_carb_target_g')) {
      context.handle(
        _manualCarbTargetGMeta,
        manualCarbTargetG.isAcceptableOrUnknown(
          data['manual_carb_target_g']!,
          _manualCarbTargetGMeta,
        ),
      );
    }
    if (data.containsKey('manual_fat_target_g')) {
      context.handle(
        _manualFatTargetGMeta,
        manualFatTargetG.isAcceptableOrUnknown(
          data['manual_fat_target_g']!,
          _manualFatTargetGMeta,
        ),
      );
    }
    if (data.containsKey('reminders_enabled')) {
      context.handle(
        _remindersEnabledMeta,
        remindersEnabled.isAcceptableOrUnknown(
          data['reminders_enabled']!,
          _remindersEnabledMeta,
        ),
      );
    }
    if (data.containsKey('onboarding_completed')) {
      context.handle(
        _onboardingCompletedMeta,
        onboardingCompleted.isAcceptableOrUnknown(
          data['onboarding_completed']!,
          _onboardingCompletedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      sex: $UserProfileTable.$convertersexn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sex'],
        ),
      ),
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      ),
      activityLevel: $UserProfileTable.$converteractivityLevel.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}activity_level'],
        )!,
      ),
      goalType: $UserProfileTable.$convertergoalType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}goal_type'],
        )!,
      ),
      weeklyWeightChangeKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weekly_weight_change_kg'],
      )!,
      startingWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}starting_weight_kg'],
      ),
      goalWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}goal_weight_kg'],
      ),
      calorieTargetMode: $UserProfileTable.$convertercalorieTargetMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}calorie_target_mode'],
        )!,
      ),
      manualCalorieTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}manual_calorie_target'],
      ),
      proteinGramsPerKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_grams_per_kg'],
      )!,
      fatPercentOfCalories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_percent_of_calories'],
      )!,
      manualProteinTargetG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}manual_protein_target_g'],
      ),
      manualCarbTargetG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}manual_carb_target_g'],
      ),
      manualFatTargetG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}manual_fat_target_g'],
      ),
      weightUnit: $UserProfileTable.$converterweightUnit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}weight_unit'],
        )!,
      ),
      foodMassUnit: $UserProfileTable.$converterfoodMassUnit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}food_mass_unit'],
        )!,
      ),
      appearanceMode: $UserProfileTable.$converterappearanceMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}appearance_mode'],
        )!,
      ),
      remindersEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminders_enabled'],
      )!,
      onboardingCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_completed'],
      )!,
    );
  }

  @override
  $UserProfileTable createAlias(String alias) {
    return $UserProfileTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BiologicalSex, int, int> $convertersex =
      const EnumIndexConverter<BiologicalSex>(BiologicalSex.values);
  static JsonTypeConverter2<BiologicalSex?, int?, int?> $convertersexn =
      JsonTypeConverter2.asNullable($convertersex);
  static JsonTypeConverter2<ActivityLevel, int, int> $converteractivityLevel =
      const EnumIndexConverter<ActivityLevel>(ActivityLevel.values);
  static JsonTypeConverter2<GoalType, int, int> $convertergoalType =
      const EnumIndexConverter<GoalType>(GoalType.values);
  static JsonTypeConverter2<CalorieTargetMode, int, int>
  $convertercalorieTargetMode = const EnumIndexConverter<CalorieTargetMode>(
    CalorieTargetMode.values,
  );
  static JsonTypeConverter2<WeightUnit, int, int> $converterweightUnit =
      const EnumIndexConverter<WeightUnit>(WeightUnit.values);
  static JsonTypeConverter2<FoodMassUnit, int, int> $converterfoodMassUnit =
      const EnumIndexConverter<FoodMassUnit>(FoodMassUnit.values);
  static JsonTypeConverter2<AppearanceMode, int, int> $converterappearanceMode =
      const EnumIndexConverter<AppearanceMode>(AppearanceMode.values);
}

class UserProfileData extends DataClass implements Insertable<UserProfileData> {
  final int id;
  final String? name;
  final BiologicalSex? sex;
  final DateTime? birthDate;
  final double? heightCm;
  final ActivityLevel activityLevel;
  final GoalType goalType;
  final double weeklyWeightChangeKg;
  final double? startingWeightKg;
  final double? goalWeightKg;
  final CalorieTargetMode calorieTargetMode;
  final int? manualCalorieTarget;
  final double proteinGramsPerKg;
  final double fatPercentOfCalories;
  final double? manualProteinTargetG;
  final double? manualCarbTargetG;
  final double? manualFatTargetG;
  final WeightUnit weightUnit;
  final FoodMassUnit foodMassUnit;
  final AppearanceMode appearanceMode;
  final bool remindersEnabled;
  final bool onboardingCompleted;
  const UserProfileData({
    required this.id,
    this.name,
    this.sex,
    this.birthDate,
    this.heightCm,
    required this.activityLevel,
    required this.goalType,
    required this.weeklyWeightChangeKg,
    this.startingWeightKg,
    this.goalWeightKg,
    required this.calorieTargetMode,
    this.manualCalorieTarget,
    required this.proteinGramsPerKg,
    required this.fatPercentOfCalories,
    this.manualProteinTargetG,
    this.manualCarbTargetG,
    this.manualFatTargetG,
    required this.weightUnit,
    required this.foodMassUnit,
    required this.appearanceMode,
    required this.remindersEnabled,
    required this.onboardingCompleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || sex != null) {
      map['sex'] = Variable<int>($UserProfileTable.$convertersexn.toSql(sex));
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    {
      map['activity_level'] = Variable<int>(
        $UserProfileTable.$converteractivityLevel.toSql(activityLevel),
      );
    }
    {
      map['goal_type'] = Variable<int>(
        $UserProfileTable.$convertergoalType.toSql(goalType),
      );
    }
    map['weekly_weight_change_kg'] = Variable<double>(weeklyWeightChangeKg);
    if (!nullToAbsent || startingWeightKg != null) {
      map['starting_weight_kg'] = Variable<double>(startingWeightKg);
    }
    if (!nullToAbsent || goalWeightKg != null) {
      map['goal_weight_kg'] = Variable<double>(goalWeightKg);
    }
    {
      map['calorie_target_mode'] = Variable<int>(
        $UserProfileTable.$convertercalorieTargetMode.toSql(calorieTargetMode),
      );
    }
    if (!nullToAbsent || manualCalorieTarget != null) {
      map['manual_calorie_target'] = Variable<int>(manualCalorieTarget);
    }
    map['protein_grams_per_kg'] = Variable<double>(proteinGramsPerKg);
    map['fat_percent_of_calories'] = Variable<double>(fatPercentOfCalories);
    if (!nullToAbsent || manualProteinTargetG != null) {
      map['manual_protein_target_g'] = Variable<double>(manualProteinTargetG);
    }
    if (!nullToAbsent || manualCarbTargetG != null) {
      map['manual_carb_target_g'] = Variable<double>(manualCarbTargetG);
    }
    if (!nullToAbsent || manualFatTargetG != null) {
      map['manual_fat_target_g'] = Variable<double>(manualFatTargetG);
    }
    {
      map['weight_unit'] = Variable<int>(
        $UserProfileTable.$converterweightUnit.toSql(weightUnit),
      );
    }
    {
      map['food_mass_unit'] = Variable<int>(
        $UserProfileTable.$converterfoodMassUnit.toSql(foodMassUnit),
      );
    }
    {
      map['appearance_mode'] = Variable<int>(
        $UserProfileTable.$converterappearanceMode.toSql(appearanceMode),
      );
    }
    map['reminders_enabled'] = Variable<bool>(remindersEnabled);
    map['onboarding_completed'] = Variable<bool>(onboardingCompleted);
    return map;
  }

  UserProfileCompanion toCompanion(bool nullToAbsent) {
    return UserProfileCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      sex: sex == null && nullToAbsent ? const Value.absent() : Value(sex),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      activityLevel: Value(activityLevel),
      goalType: Value(goalType),
      weeklyWeightChangeKg: Value(weeklyWeightChangeKg),
      startingWeightKg: startingWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(startingWeightKg),
      goalWeightKg: goalWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(goalWeightKg),
      calorieTargetMode: Value(calorieTargetMode),
      manualCalorieTarget: manualCalorieTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(manualCalorieTarget),
      proteinGramsPerKg: Value(proteinGramsPerKg),
      fatPercentOfCalories: Value(fatPercentOfCalories),
      manualProteinTargetG: manualProteinTargetG == null && nullToAbsent
          ? const Value.absent()
          : Value(manualProteinTargetG),
      manualCarbTargetG: manualCarbTargetG == null && nullToAbsent
          ? const Value.absent()
          : Value(manualCarbTargetG),
      manualFatTargetG: manualFatTargetG == null && nullToAbsent
          ? const Value.absent()
          : Value(manualFatTargetG),
      weightUnit: Value(weightUnit),
      foodMassUnit: Value(foodMassUnit),
      appearanceMode: Value(appearanceMode),
      remindersEnabled: Value(remindersEnabled),
      onboardingCompleted: Value(onboardingCompleted),
    );
  }

  factory UserProfileData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      sex: $UserProfileTable.$convertersexn.fromJson(
        serializer.fromJson<int?>(json['sex']),
      ),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      activityLevel: $UserProfileTable.$converteractivityLevel.fromJson(
        serializer.fromJson<int>(json['activityLevel']),
      ),
      goalType: $UserProfileTable.$convertergoalType.fromJson(
        serializer.fromJson<int>(json['goalType']),
      ),
      weeklyWeightChangeKg: serializer.fromJson<double>(
        json['weeklyWeightChangeKg'],
      ),
      startingWeightKg: serializer.fromJson<double?>(json['startingWeightKg']),
      goalWeightKg: serializer.fromJson<double?>(json['goalWeightKg']),
      calorieTargetMode: $UserProfileTable.$convertercalorieTargetMode.fromJson(
        serializer.fromJson<int>(json['calorieTargetMode']),
      ),
      manualCalorieTarget: serializer.fromJson<int?>(
        json['manualCalorieTarget'],
      ),
      proteinGramsPerKg: serializer.fromJson<double>(json['proteinGramsPerKg']),
      fatPercentOfCalories: serializer.fromJson<double>(
        json['fatPercentOfCalories'],
      ),
      manualProteinTargetG: serializer.fromJson<double?>(
        json['manualProteinTargetG'],
      ),
      manualCarbTargetG: serializer.fromJson<double?>(
        json['manualCarbTargetG'],
      ),
      manualFatTargetG: serializer.fromJson<double?>(json['manualFatTargetG']),
      weightUnit: $UserProfileTable.$converterweightUnit.fromJson(
        serializer.fromJson<int>(json['weightUnit']),
      ),
      foodMassUnit: $UserProfileTable.$converterfoodMassUnit.fromJson(
        serializer.fromJson<int>(json['foodMassUnit']),
      ),
      appearanceMode: $UserProfileTable.$converterappearanceMode.fromJson(
        serializer.fromJson<int>(json['appearanceMode']),
      ),
      remindersEnabled: serializer.fromJson<bool>(json['remindersEnabled']),
      onboardingCompleted: serializer.fromJson<bool>(
        json['onboardingCompleted'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String?>(name),
      'sex': serializer.toJson<int?>(
        $UserProfileTable.$convertersexn.toJson(sex),
      ),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'heightCm': serializer.toJson<double?>(heightCm),
      'activityLevel': serializer.toJson<int>(
        $UserProfileTable.$converteractivityLevel.toJson(activityLevel),
      ),
      'goalType': serializer.toJson<int>(
        $UserProfileTable.$convertergoalType.toJson(goalType),
      ),
      'weeklyWeightChangeKg': serializer.toJson<double>(weeklyWeightChangeKg),
      'startingWeightKg': serializer.toJson<double?>(startingWeightKg),
      'goalWeightKg': serializer.toJson<double?>(goalWeightKg),
      'calorieTargetMode': serializer.toJson<int>(
        $UserProfileTable.$convertercalorieTargetMode.toJson(calorieTargetMode),
      ),
      'manualCalorieTarget': serializer.toJson<int?>(manualCalorieTarget),
      'proteinGramsPerKg': serializer.toJson<double>(proteinGramsPerKg),
      'fatPercentOfCalories': serializer.toJson<double>(fatPercentOfCalories),
      'manualProteinTargetG': serializer.toJson<double?>(manualProteinTargetG),
      'manualCarbTargetG': serializer.toJson<double?>(manualCarbTargetG),
      'manualFatTargetG': serializer.toJson<double?>(manualFatTargetG),
      'weightUnit': serializer.toJson<int>(
        $UserProfileTable.$converterweightUnit.toJson(weightUnit),
      ),
      'foodMassUnit': serializer.toJson<int>(
        $UserProfileTable.$converterfoodMassUnit.toJson(foodMassUnit),
      ),
      'appearanceMode': serializer.toJson<int>(
        $UserProfileTable.$converterappearanceMode.toJson(appearanceMode),
      ),
      'remindersEnabled': serializer.toJson<bool>(remindersEnabled),
      'onboardingCompleted': serializer.toJson<bool>(onboardingCompleted),
    };
  }

  UserProfileData copyWith({
    int? id,
    Value<String?> name = const Value.absent(),
    Value<BiologicalSex?> sex = const Value.absent(),
    Value<DateTime?> birthDate = const Value.absent(),
    Value<double?> heightCm = const Value.absent(),
    ActivityLevel? activityLevel,
    GoalType? goalType,
    double? weeklyWeightChangeKg,
    Value<double?> startingWeightKg = const Value.absent(),
    Value<double?> goalWeightKg = const Value.absent(),
    CalorieTargetMode? calorieTargetMode,
    Value<int?> manualCalorieTarget = const Value.absent(),
    double? proteinGramsPerKg,
    double? fatPercentOfCalories,
    Value<double?> manualProteinTargetG = const Value.absent(),
    Value<double?> manualCarbTargetG = const Value.absent(),
    Value<double?> manualFatTargetG = const Value.absent(),
    WeightUnit? weightUnit,
    FoodMassUnit? foodMassUnit,
    AppearanceMode? appearanceMode,
    bool? remindersEnabled,
    bool? onboardingCompleted,
  }) => UserProfileData(
    id: id ?? this.id,
    name: name.present ? name.value : this.name,
    sex: sex.present ? sex.value : this.sex,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    activityLevel: activityLevel ?? this.activityLevel,
    goalType: goalType ?? this.goalType,
    weeklyWeightChangeKg: weeklyWeightChangeKg ?? this.weeklyWeightChangeKg,
    startingWeightKg: startingWeightKg.present
        ? startingWeightKg.value
        : this.startingWeightKg,
    goalWeightKg: goalWeightKg.present ? goalWeightKg.value : this.goalWeightKg,
    calorieTargetMode: calorieTargetMode ?? this.calorieTargetMode,
    manualCalorieTarget: manualCalorieTarget.present
        ? manualCalorieTarget.value
        : this.manualCalorieTarget,
    proteinGramsPerKg: proteinGramsPerKg ?? this.proteinGramsPerKg,
    fatPercentOfCalories: fatPercentOfCalories ?? this.fatPercentOfCalories,
    manualProteinTargetG: manualProteinTargetG.present
        ? manualProteinTargetG.value
        : this.manualProteinTargetG,
    manualCarbTargetG: manualCarbTargetG.present
        ? manualCarbTargetG.value
        : this.manualCarbTargetG,
    manualFatTargetG: manualFatTargetG.present
        ? manualFatTargetG.value
        : this.manualFatTargetG,
    weightUnit: weightUnit ?? this.weightUnit,
    foodMassUnit: foodMassUnit ?? this.foodMassUnit,
    appearanceMode: appearanceMode ?? this.appearanceMode,
    remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
  );
  UserProfileData copyWithCompanion(UserProfileCompanion data) {
    return UserProfileData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sex: data.sex.present ? data.sex.value : this.sex,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      activityLevel: data.activityLevel.present
          ? data.activityLevel.value
          : this.activityLevel,
      goalType: data.goalType.present ? data.goalType.value : this.goalType,
      weeklyWeightChangeKg: data.weeklyWeightChangeKg.present
          ? data.weeklyWeightChangeKg.value
          : this.weeklyWeightChangeKg,
      startingWeightKg: data.startingWeightKg.present
          ? data.startingWeightKg.value
          : this.startingWeightKg,
      goalWeightKg: data.goalWeightKg.present
          ? data.goalWeightKg.value
          : this.goalWeightKg,
      calorieTargetMode: data.calorieTargetMode.present
          ? data.calorieTargetMode.value
          : this.calorieTargetMode,
      manualCalorieTarget: data.manualCalorieTarget.present
          ? data.manualCalorieTarget.value
          : this.manualCalorieTarget,
      proteinGramsPerKg: data.proteinGramsPerKg.present
          ? data.proteinGramsPerKg.value
          : this.proteinGramsPerKg,
      fatPercentOfCalories: data.fatPercentOfCalories.present
          ? data.fatPercentOfCalories.value
          : this.fatPercentOfCalories,
      manualProteinTargetG: data.manualProteinTargetG.present
          ? data.manualProteinTargetG.value
          : this.manualProteinTargetG,
      manualCarbTargetG: data.manualCarbTargetG.present
          ? data.manualCarbTargetG.value
          : this.manualCarbTargetG,
      manualFatTargetG: data.manualFatTargetG.present
          ? data.manualFatTargetG.value
          : this.manualFatTargetG,
      weightUnit: data.weightUnit.present
          ? data.weightUnit.value
          : this.weightUnit,
      foodMassUnit: data.foodMassUnit.present
          ? data.foodMassUnit.value
          : this.foodMassUnit,
      appearanceMode: data.appearanceMode.present
          ? data.appearanceMode.value
          : this.appearanceMode,
      remindersEnabled: data.remindersEnabled.present
          ? data.remindersEnabled.value
          : this.remindersEnabled,
      onboardingCompleted: data.onboardingCompleted.present
          ? data.onboardingCompleted.value
          : this.onboardingCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sex: $sex, ')
          ..write('birthDate: $birthDate, ')
          ..write('heightCm: $heightCm, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('goalType: $goalType, ')
          ..write('weeklyWeightChangeKg: $weeklyWeightChangeKg, ')
          ..write('startingWeightKg: $startingWeightKg, ')
          ..write('goalWeightKg: $goalWeightKg, ')
          ..write('calorieTargetMode: $calorieTargetMode, ')
          ..write('manualCalorieTarget: $manualCalorieTarget, ')
          ..write('proteinGramsPerKg: $proteinGramsPerKg, ')
          ..write('fatPercentOfCalories: $fatPercentOfCalories, ')
          ..write('manualProteinTargetG: $manualProteinTargetG, ')
          ..write('manualCarbTargetG: $manualCarbTargetG, ')
          ..write('manualFatTargetG: $manualFatTargetG, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('foodMassUnit: $foodMassUnit, ')
          ..write('appearanceMode: $appearanceMode, ')
          ..write('remindersEnabled: $remindersEnabled, ')
          ..write('onboardingCompleted: $onboardingCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    sex,
    birthDate,
    heightCm,
    activityLevel,
    goalType,
    weeklyWeightChangeKg,
    startingWeightKg,
    goalWeightKg,
    calorieTargetMode,
    manualCalorieTarget,
    proteinGramsPerKg,
    fatPercentOfCalories,
    manualProteinTargetG,
    manualCarbTargetG,
    manualFatTargetG,
    weightUnit,
    foodMassUnit,
    appearanceMode,
    remindersEnabled,
    onboardingCompleted,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileData &&
          other.id == this.id &&
          other.name == this.name &&
          other.sex == this.sex &&
          other.birthDate == this.birthDate &&
          other.heightCm == this.heightCm &&
          other.activityLevel == this.activityLevel &&
          other.goalType == this.goalType &&
          other.weeklyWeightChangeKg == this.weeklyWeightChangeKg &&
          other.startingWeightKg == this.startingWeightKg &&
          other.goalWeightKg == this.goalWeightKg &&
          other.calorieTargetMode == this.calorieTargetMode &&
          other.manualCalorieTarget == this.manualCalorieTarget &&
          other.proteinGramsPerKg == this.proteinGramsPerKg &&
          other.fatPercentOfCalories == this.fatPercentOfCalories &&
          other.manualProteinTargetG == this.manualProteinTargetG &&
          other.manualCarbTargetG == this.manualCarbTargetG &&
          other.manualFatTargetG == this.manualFatTargetG &&
          other.weightUnit == this.weightUnit &&
          other.foodMassUnit == this.foodMassUnit &&
          other.appearanceMode == this.appearanceMode &&
          other.remindersEnabled == this.remindersEnabled &&
          other.onboardingCompleted == this.onboardingCompleted);
}

class UserProfileCompanion extends UpdateCompanion<UserProfileData> {
  final Value<int> id;
  final Value<String?> name;
  final Value<BiologicalSex?> sex;
  final Value<DateTime?> birthDate;
  final Value<double?> heightCm;
  final Value<ActivityLevel> activityLevel;
  final Value<GoalType> goalType;
  final Value<double> weeklyWeightChangeKg;
  final Value<double?> startingWeightKg;
  final Value<double?> goalWeightKg;
  final Value<CalorieTargetMode> calorieTargetMode;
  final Value<int?> manualCalorieTarget;
  final Value<double> proteinGramsPerKg;
  final Value<double> fatPercentOfCalories;
  final Value<double?> manualProteinTargetG;
  final Value<double?> manualCarbTargetG;
  final Value<double?> manualFatTargetG;
  final Value<WeightUnit> weightUnit;
  final Value<FoodMassUnit> foodMassUnit;
  final Value<AppearanceMode> appearanceMode;
  final Value<bool> remindersEnabled;
  final Value<bool> onboardingCompleted;
  const UserProfileCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sex = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.goalType = const Value.absent(),
    this.weeklyWeightChangeKg = const Value.absent(),
    this.startingWeightKg = const Value.absent(),
    this.goalWeightKg = const Value.absent(),
    this.calorieTargetMode = const Value.absent(),
    this.manualCalorieTarget = const Value.absent(),
    this.proteinGramsPerKg = const Value.absent(),
    this.fatPercentOfCalories = const Value.absent(),
    this.manualProteinTargetG = const Value.absent(),
    this.manualCarbTargetG = const Value.absent(),
    this.manualFatTargetG = const Value.absent(),
    this.weightUnit = const Value.absent(),
    this.foodMassUnit = const Value.absent(),
    this.appearanceMode = const Value.absent(),
    this.remindersEnabled = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
  });
  UserProfileCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sex = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.goalType = const Value.absent(),
    this.weeklyWeightChangeKg = const Value.absent(),
    this.startingWeightKg = const Value.absent(),
    this.goalWeightKg = const Value.absent(),
    this.calorieTargetMode = const Value.absent(),
    this.manualCalorieTarget = const Value.absent(),
    this.proteinGramsPerKg = const Value.absent(),
    this.fatPercentOfCalories = const Value.absent(),
    this.manualProteinTargetG = const Value.absent(),
    this.manualCarbTargetG = const Value.absent(),
    this.manualFatTargetG = const Value.absent(),
    this.weightUnit = const Value.absent(),
    this.foodMassUnit = const Value.absent(),
    this.appearanceMode = const Value.absent(),
    this.remindersEnabled = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
  });
  static Insertable<UserProfileData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? sex,
    Expression<DateTime>? birthDate,
    Expression<double>? heightCm,
    Expression<int>? activityLevel,
    Expression<int>? goalType,
    Expression<double>? weeklyWeightChangeKg,
    Expression<double>? startingWeightKg,
    Expression<double>? goalWeightKg,
    Expression<int>? calorieTargetMode,
    Expression<int>? manualCalorieTarget,
    Expression<double>? proteinGramsPerKg,
    Expression<double>? fatPercentOfCalories,
    Expression<double>? manualProteinTargetG,
    Expression<double>? manualCarbTargetG,
    Expression<double>? manualFatTargetG,
    Expression<int>? weightUnit,
    Expression<int>? foodMassUnit,
    Expression<int>? appearanceMode,
    Expression<bool>? remindersEnabled,
    Expression<bool>? onboardingCompleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sex != null) 'sex': sex,
      if (birthDate != null) 'birth_date': birthDate,
      if (heightCm != null) 'height_cm': heightCm,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (goalType != null) 'goal_type': goalType,
      if (weeklyWeightChangeKg != null)
        'weekly_weight_change_kg': weeklyWeightChangeKg,
      if (startingWeightKg != null) 'starting_weight_kg': startingWeightKg,
      if (goalWeightKg != null) 'goal_weight_kg': goalWeightKg,
      if (calorieTargetMode != null) 'calorie_target_mode': calorieTargetMode,
      if (manualCalorieTarget != null)
        'manual_calorie_target': manualCalorieTarget,
      if (proteinGramsPerKg != null) 'protein_grams_per_kg': proteinGramsPerKg,
      if (fatPercentOfCalories != null)
        'fat_percent_of_calories': fatPercentOfCalories,
      if (manualProteinTargetG != null)
        'manual_protein_target_g': manualProteinTargetG,
      if (manualCarbTargetG != null) 'manual_carb_target_g': manualCarbTargetG,
      if (manualFatTargetG != null) 'manual_fat_target_g': manualFatTargetG,
      if (weightUnit != null) 'weight_unit': weightUnit,
      if (foodMassUnit != null) 'food_mass_unit': foodMassUnit,
      if (appearanceMode != null) 'appearance_mode': appearanceMode,
      if (remindersEnabled != null) 'reminders_enabled': remindersEnabled,
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
    });
  }

  UserProfileCompanion copyWith({
    Value<int>? id,
    Value<String?>? name,
    Value<BiologicalSex?>? sex,
    Value<DateTime?>? birthDate,
    Value<double?>? heightCm,
    Value<ActivityLevel>? activityLevel,
    Value<GoalType>? goalType,
    Value<double>? weeklyWeightChangeKg,
    Value<double?>? startingWeightKg,
    Value<double?>? goalWeightKg,
    Value<CalorieTargetMode>? calorieTargetMode,
    Value<int?>? manualCalorieTarget,
    Value<double>? proteinGramsPerKg,
    Value<double>? fatPercentOfCalories,
    Value<double?>? manualProteinTargetG,
    Value<double?>? manualCarbTargetG,
    Value<double?>? manualFatTargetG,
    Value<WeightUnit>? weightUnit,
    Value<FoodMassUnit>? foodMassUnit,
    Value<AppearanceMode>? appearanceMode,
    Value<bool>? remindersEnabled,
    Value<bool>? onboardingCompleted,
  }) {
    return UserProfileCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sex: sex ?? this.sex,
      birthDate: birthDate ?? this.birthDate,
      heightCm: heightCm ?? this.heightCm,
      activityLevel: activityLevel ?? this.activityLevel,
      goalType: goalType ?? this.goalType,
      weeklyWeightChangeKg: weeklyWeightChangeKg ?? this.weeklyWeightChangeKg,
      startingWeightKg: startingWeightKg ?? this.startingWeightKg,
      goalWeightKg: goalWeightKg ?? this.goalWeightKg,
      calorieTargetMode: calorieTargetMode ?? this.calorieTargetMode,
      manualCalorieTarget: manualCalorieTarget ?? this.manualCalorieTarget,
      proteinGramsPerKg: proteinGramsPerKg ?? this.proteinGramsPerKg,
      fatPercentOfCalories: fatPercentOfCalories ?? this.fatPercentOfCalories,
      manualProteinTargetG: manualProteinTargetG ?? this.manualProteinTargetG,
      manualCarbTargetG: manualCarbTargetG ?? this.manualCarbTargetG,
      manualFatTargetG: manualFatTargetG ?? this.manualFatTargetG,
      weightUnit: weightUnit ?? this.weightUnit,
      foodMassUnit: foodMassUnit ?? this.foodMassUnit,
      appearanceMode: appearanceMode ?? this.appearanceMode,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sex.present) {
      map['sex'] = Variable<int>(
        $UserProfileTable.$convertersexn.toSql(sex.value),
      );
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (activityLevel.present) {
      map['activity_level'] = Variable<int>(
        $UserProfileTable.$converteractivityLevel.toSql(activityLevel.value),
      );
    }
    if (goalType.present) {
      map['goal_type'] = Variable<int>(
        $UserProfileTable.$convertergoalType.toSql(goalType.value),
      );
    }
    if (weeklyWeightChangeKg.present) {
      map['weekly_weight_change_kg'] = Variable<double>(
        weeklyWeightChangeKg.value,
      );
    }
    if (startingWeightKg.present) {
      map['starting_weight_kg'] = Variable<double>(startingWeightKg.value);
    }
    if (goalWeightKg.present) {
      map['goal_weight_kg'] = Variable<double>(goalWeightKg.value);
    }
    if (calorieTargetMode.present) {
      map['calorie_target_mode'] = Variable<int>(
        $UserProfileTable.$convertercalorieTargetMode.toSql(
          calorieTargetMode.value,
        ),
      );
    }
    if (manualCalorieTarget.present) {
      map['manual_calorie_target'] = Variable<int>(manualCalorieTarget.value);
    }
    if (proteinGramsPerKg.present) {
      map['protein_grams_per_kg'] = Variable<double>(proteinGramsPerKg.value);
    }
    if (fatPercentOfCalories.present) {
      map['fat_percent_of_calories'] = Variable<double>(
        fatPercentOfCalories.value,
      );
    }
    if (manualProteinTargetG.present) {
      map['manual_protein_target_g'] = Variable<double>(
        manualProteinTargetG.value,
      );
    }
    if (manualCarbTargetG.present) {
      map['manual_carb_target_g'] = Variable<double>(manualCarbTargetG.value);
    }
    if (manualFatTargetG.present) {
      map['manual_fat_target_g'] = Variable<double>(manualFatTargetG.value);
    }
    if (weightUnit.present) {
      map['weight_unit'] = Variable<int>(
        $UserProfileTable.$converterweightUnit.toSql(weightUnit.value),
      );
    }
    if (foodMassUnit.present) {
      map['food_mass_unit'] = Variable<int>(
        $UserProfileTable.$converterfoodMassUnit.toSql(foodMassUnit.value),
      );
    }
    if (appearanceMode.present) {
      map['appearance_mode'] = Variable<int>(
        $UserProfileTable.$converterappearanceMode.toSql(appearanceMode.value),
      );
    }
    if (remindersEnabled.present) {
      map['reminders_enabled'] = Variable<bool>(remindersEnabled.value);
    }
    if (onboardingCompleted.present) {
      map['onboarding_completed'] = Variable<bool>(onboardingCompleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sex: $sex, ')
          ..write('birthDate: $birthDate, ')
          ..write('heightCm: $heightCm, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('goalType: $goalType, ')
          ..write('weeklyWeightChangeKg: $weeklyWeightChangeKg, ')
          ..write('startingWeightKg: $startingWeightKg, ')
          ..write('goalWeightKg: $goalWeightKg, ')
          ..write('calorieTargetMode: $calorieTargetMode, ')
          ..write('manualCalorieTarget: $manualCalorieTarget, ')
          ..write('proteinGramsPerKg: $proteinGramsPerKg, ')
          ..write('fatPercentOfCalories: $fatPercentOfCalories, ')
          ..write('manualProteinTargetG: $manualProteinTargetG, ')
          ..write('manualCarbTargetG: $manualCarbTargetG, ')
          ..write('manualFatTargetG: $manualFatTargetG, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('foodMassUnit: $foodMassUnit, ')
          ..write('appearanceMode: $appearanceMode, ')
          ..write('remindersEnabled: $remindersEnabled, ')
          ..write('onboardingCompleted: $onboardingCompleted')
          ..write(')'))
        .toString();
  }
}

class $FoodsTable extends Foods with TableInfo<$FoodsTable, Food> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kcalPer100gMeta = const VerificationMeta(
    'kcalPer100g',
  );
  @override
  late final GeneratedColumn<double> kcalPer100g = GeneratedColumn<double>(
    'kcal_per100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinPer100gMeta = const VerificationMeta(
    'proteinPer100g',
  );
  @override
  late final GeneratedColumn<double> proteinPer100g = GeneratedColumn<double>(
    'protein_per100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsPer100gMeta = const VerificationMeta(
    'carbsPer100g',
  );
  @override
  late final GeneratedColumn<double> carbsPer100g = GeneratedColumn<double>(
    'carbs_per100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatPer100gMeta = const VerificationMeta(
    'fatPer100g',
  );
  @override
  late final GeneratedColumn<double> fatPer100g = GeneratedColumn<double>(
    'fat_per100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fiberPer100gMeta = const VerificationMeta(
    'fiberPer100g',
  );
  @override
  late final GeneratedColumn<double> fiberPer100g = GeneratedColumn<double>(
    'fiber_per100g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultServingGramsMeta =
      const VerificationMeta('defaultServingGrams');
  @override
  late final GeneratedColumn<double> defaultServingGrams =
      GeneratedColumn<double>(
        'default_serving_grams',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _servingLabelMeta = const VerificationMeta(
    'servingLabel',
  );
  @override
  late final GeneratedColumn<String> servingLabel = GeneratedColumn<String>(
    'serving_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<FoodCategory, int> category =
      GeneratedColumn<int>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(FoodCategory.otros.index),
      ).withConverter<FoodCategory>($FoodsTable.$convertercategory);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kcalPer100g,
    proteinPer100g,
    carbsPer100g,
    fatPer100g,
    fiberPer100g,
    defaultServingGrams,
    servingLabel,
    isCustom,
    category,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<Food> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kcal_per100g')) {
      context.handle(
        _kcalPer100gMeta,
        kcalPer100g.isAcceptableOrUnknown(
          data['kcal_per100g']!,
          _kcalPer100gMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_kcalPer100gMeta);
    }
    if (data.containsKey('protein_per100g')) {
      context.handle(
        _proteinPer100gMeta,
        proteinPer100g.isAcceptableOrUnknown(
          data['protein_per100g']!,
          _proteinPer100gMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinPer100gMeta);
    }
    if (data.containsKey('carbs_per100g')) {
      context.handle(
        _carbsPer100gMeta,
        carbsPer100g.isAcceptableOrUnknown(
          data['carbs_per100g']!,
          _carbsPer100gMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_carbsPer100gMeta);
    }
    if (data.containsKey('fat_per100g')) {
      context.handle(
        _fatPer100gMeta,
        fatPer100g.isAcceptableOrUnknown(data['fat_per100g']!, _fatPer100gMeta),
      );
    } else if (isInserting) {
      context.missing(_fatPer100gMeta);
    }
    if (data.containsKey('fiber_per100g')) {
      context.handle(
        _fiberPer100gMeta,
        fiberPer100g.isAcceptableOrUnknown(
          data['fiber_per100g']!,
          _fiberPer100gMeta,
        ),
      );
    }
    if (data.containsKey('default_serving_grams')) {
      context.handle(
        _defaultServingGramsMeta,
        defaultServingGrams.isAcceptableOrUnknown(
          data['default_serving_grams']!,
          _defaultServingGramsMeta,
        ),
      );
    }
    if (data.containsKey('serving_label')) {
      context.handle(
        _servingLabelMeta,
        servingLabel.isAcceptableOrUnknown(
          data['serving_label']!,
          _servingLabelMeta,
        ),
      );
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Food map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Food(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kcalPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal_per100g'],
      )!,
      proteinPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_per100g'],
      )!,
      carbsPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_per100g'],
      )!,
      fatPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_per100g'],
      )!,
      fiberPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fiber_per100g'],
      ),
      defaultServingGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_serving_grams'],
      ),
      servingLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serving_label'],
      ),
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
      category: $FoodsTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}category'],
        )!,
      ),
    );
  }

  @override
  $FoodsTable createAlias(String alias) {
    return $FoodsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FoodCategory, int, int> $convertercategory =
      const EnumIndexConverter<FoodCategory>(FoodCategory.values);
}

class Food extends DataClass implements Insertable<Food> {
  final int id;
  final String name;
  final double kcalPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double? fiberPer100g;
  final double? defaultServingGrams;
  final String? servingLabel;
  final bool isCustom;
  final FoodCategory category;
  const Food({
    required this.id,
    required this.name,
    required this.kcalPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.fiberPer100g,
    this.defaultServingGrams,
    this.servingLabel,
    required this.isCustom,
    required this.category,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['kcal_per100g'] = Variable<double>(kcalPer100g);
    map['protein_per100g'] = Variable<double>(proteinPer100g);
    map['carbs_per100g'] = Variable<double>(carbsPer100g);
    map['fat_per100g'] = Variable<double>(fatPer100g);
    if (!nullToAbsent || fiberPer100g != null) {
      map['fiber_per100g'] = Variable<double>(fiberPer100g);
    }
    if (!nullToAbsent || defaultServingGrams != null) {
      map['default_serving_grams'] = Variable<double>(defaultServingGrams);
    }
    if (!nullToAbsent || servingLabel != null) {
      map['serving_label'] = Variable<String>(servingLabel);
    }
    map['is_custom'] = Variable<bool>(isCustom);
    {
      map['category'] = Variable<int>(
        $FoodsTable.$convertercategory.toSql(category),
      );
    }
    return map;
  }

  FoodsCompanion toCompanion(bool nullToAbsent) {
    return FoodsCompanion(
      id: Value(id),
      name: Value(name),
      kcalPer100g: Value(kcalPer100g),
      proteinPer100g: Value(proteinPer100g),
      carbsPer100g: Value(carbsPer100g),
      fatPer100g: Value(fatPer100g),
      fiberPer100g: fiberPer100g == null && nullToAbsent
          ? const Value.absent()
          : Value(fiberPer100g),
      defaultServingGrams: defaultServingGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultServingGrams),
      servingLabel: servingLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(servingLabel),
      isCustom: Value(isCustom),
      category: Value(category),
    );
  }

  factory Food.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Food(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kcalPer100g: serializer.fromJson<double>(json['kcalPer100g']),
      proteinPer100g: serializer.fromJson<double>(json['proteinPer100g']),
      carbsPer100g: serializer.fromJson<double>(json['carbsPer100g']),
      fatPer100g: serializer.fromJson<double>(json['fatPer100g']),
      fiberPer100g: serializer.fromJson<double?>(json['fiberPer100g']),
      defaultServingGrams: serializer.fromJson<double?>(
        json['defaultServingGrams'],
      ),
      servingLabel: serializer.fromJson<String?>(json['servingLabel']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      category: $FoodsTable.$convertercategory.fromJson(
        serializer.fromJson<int>(json['category']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'kcalPer100g': serializer.toJson<double>(kcalPer100g),
      'proteinPer100g': serializer.toJson<double>(proteinPer100g),
      'carbsPer100g': serializer.toJson<double>(carbsPer100g),
      'fatPer100g': serializer.toJson<double>(fatPer100g),
      'fiberPer100g': serializer.toJson<double?>(fiberPer100g),
      'defaultServingGrams': serializer.toJson<double?>(defaultServingGrams),
      'servingLabel': serializer.toJson<String?>(servingLabel),
      'isCustom': serializer.toJson<bool>(isCustom),
      'category': serializer.toJson<int>(
        $FoodsTable.$convertercategory.toJson(category),
      ),
    };
  }

  Food copyWith({
    int? id,
    String? name,
    double? kcalPer100g,
    double? proteinPer100g,
    double? carbsPer100g,
    double? fatPer100g,
    Value<double?> fiberPer100g = const Value.absent(),
    Value<double?> defaultServingGrams = const Value.absent(),
    Value<String?> servingLabel = const Value.absent(),
    bool? isCustom,
    FoodCategory? category,
  }) => Food(
    id: id ?? this.id,
    name: name ?? this.name,
    kcalPer100g: kcalPer100g ?? this.kcalPer100g,
    proteinPer100g: proteinPer100g ?? this.proteinPer100g,
    carbsPer100g: carbsPer100g ?? this.carbsPer100g,
    fatPer100g: fatPer100g ?? this.fatPer100g,
    fiberPer100g: fiberPer100g.present ? fiberPer100g.value : this.fiberPer100g,
    defaultServingGrams: defaultServingGrams.present
        ? defaultServingGrams.value
        : this.defaultServingGrams,
    servingLabel: servingLabel.present ? servingLabel.value : this.servingLabel,
    isCustom: isCustom ?? this.isCustom,
    category: category ?? this.category,
  );
  Food copyWithCompanion(FoodsCompanion data) {
    return Food(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kcalPer100g: data.kcalPer100g.present
          ? data.kcalPer100g.value
          : this.kcalPer100g,
      proteinPer100g: data.proteinPer100g.present
          ? data.proteinPer100g.value
          : this.proteinPer100g,
      carbsPer100g: data.carbsPer100g.present
          ? data.carbsPer100g.value
          : this.carbsPer100g,
      fatPer100g: data.fatPer100g.present
          ? data.fatPer100g.value
          : this.fatPer100g,
      fiberPer100g: data.fiberPer100g.present
          ? data.fiberPer100g.value
          : this.fiberPer100g,
      defaultServingGrams: data.defaultServingGrams.present
          ? data.defaultServingGrams.value
          : this.defaultServingGrams,
      servingLabel: data.servingLabel.present
          ? data.servingLabel.value
          : this.servingLabel,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      category: data.category.present ? data.category.value : this.category,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Food(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kcalPer100g: $kcalPer100g, ')
          ..write('proteinPer100g: $proteinPer100g, ')
          ..write('carbsPer100g: $carbsPer100g, ')
          ..write('fatPer100g: $fatPer100g, ')
          ..write('fiberPer100g: $fiberPer100g, ')
          ..write('defaultServingGrams: $defaultServingGrams, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('isCustom: $isCustom, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    kcalPer100g,
    proteinPer100g,
    carbsPer100g,
    fatPer100g,
    fiberPer100g,
    defaultServingGrams,
    servingLabel,
    isCustom,
    category,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Food &&
          other.id == this.id &&
          other.name == this.name &&
          other.kcalPer100g == this.kcalPer100g &&
          other.proteinPer100g == this.proteinPer100g &&
          other.carbsPer100g == this.carbsPer100g &&
          other.fatPer100g == this.fatPer100g &&
          other.fiberPer100g == this.fiberPer100g &&
          other.defaultServingGrams == this.defaultServingGrams &&
          other.servingLabel == this.servingLabel &&
          other.isCustom == this.isCustom &&
          other.category == this.category);
}

class FoodsCompanion extends UpdateCompanion<Food> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> kcalPer100g;
  final Value<double> proteinPer100g;
  final Value<double> carbsPer100g;
  final Value<double> fatPer100g;
  final Value<double?> fiberPer100g;
  final Value<double?> defaultServingGrams;
  final Value<String?> servingLabel;
  final Value<bool> isCustom;
  final Value<FoodCategory> category;
  const FoodsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kcalPer100g = const Value.absent(),
    this.proteinPer100g = const Value.absent(),
    this.carbsPer100g = const Value.absent(),
    this.fatPer100g = const Value.absent(),
    this.fiberPer100g = const Value.absent(),
    this.defaultServingGrams = const Value.absent(),
    this.servingLabel = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.category = const Value.absent(),
  });
  FoodsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double kcalPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatPer100g,
    this.fiberPer100g = const Value.absent(),
    this.defaultServingGrams = const Value.absent(),
    this.servingLabel = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.category = const Value.absent(),
  }) : name = Value(name),
       kcalPer100g = Value(kcalPer100g),
       proteinPer100g = Value(proteinPer100g),
       carbsPer100g = Value(carbsPer100g),
       fatPer100g = Value(fatPer100g);
  static Insertable<Food> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? kcalPer100g,
    Expression<double>? proteinPer100g,
    Expression<double>? carbsPer100g,
    Expression<double>? fatPer100g,
    Expression<double>? fiberPer100g,
    Expression<double>? defaultServingGrams,
    Expression<String>? servingLabel,
    Expression<bool>? isCustom,
    Expression<int>? category,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kcalPer100g != null) 'kcal_per100g': kcalPer100g,
      if (proteinPer100g != null) 'protein_per100g': proteinPer100g,
      if (carbsPer100g != null) 'carbs_per100g': carbsPer100g,
      if (fatPer100g != null) 'fat_per100g': fatPer100g,
      if (fiberPer100g != null) 'fiber_per100g': fiberPer100g,
      if (defaultServingGrams != null)
        'default_serving_grams': defaultServingGrams,
      if (servingLabel != null) 'serving_label': servingLabel,
      if (isCustom != null) 'is_custom': isCustom,
      if (category != null) 'category': category,
    });
  }

  FoodsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? kcalPer100g,
    Value<double>? proteinPer100g,
    Value<double>? carbsPer100g,
    Value<double>? fatPer100g,
    Value<double?>? fiberPer100g,
    Value<double?>? defaultServingGrams,
    Value<String?>? servingLabel,
    Value<bool>? isCustom,
    Value<FoodCategory>? category,
  }) {
    return FoodsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kcalPer100g: kcalPer100g ?? this.kcalPer100g,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      fatPer100g: fatPer100g ?? this.fatPer100g,
      fiberPer100g: fiberPer100g ?? this.fiberPer100g,
      defaultServingGrams: defaultServingGrams ?? this.defaultServingGrams,
      servingLabel: servingLabel ?? this.servingLabel,
      isCustom: isCustom ?? this.isCustom,
      category: category ?? this.category,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kcalPer100g.present) {
      map['kcal_per100g'] = Variable<double>(kcalPer100g.value);
    }
    if (proteinPer100g.present) {
      map['protein_per100g'] = Variable<double>(proteinPer100g.value);
    }
    if (carbsPer100g.present) {
      map['carbs_per100g'] = Variable<double>(carbsPer100g.value);
    }
    if (fatPer100g.present) {
      map['fat_per100g'] = Variable<double>(fatPer100g.value);
    }
    if (fiberPer100g.present) {
      map['fiber_per100g'] = Variable<double>(fiberPer100g.value);
    }
    if (defaultServingGrams.present) {
      map['default_serving_grams'] = Variable<double>(
        defaultServingGrams.value,
      );
    }
    if (servingLabel.present) {
      map['serving_label'] = Variable<String>(servingLabel.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (category.present) {
      map['category'] = Variable<int>(
        $FoodsTable.$convertercategory.toSql(category.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kcalPer100g: $kcalPer100g, ')
          ..write('proteinPer100g: $proteinPer100g, ')
          ..write('carbsPer100g: $carbsPer100g, ')
          ..write('fatPer100g: $fatPer100g, ')
          ..write('fiberPer100g: $fiberPer100g, ')
          ..write('defaultServingGrams: $defaultServingGrams, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('isCustom: $isCustom, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }
}

class $RecipesTable extends Recipes with TableInfo<$RecipesTable, Recipe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageBytesMeta = const VerificationMeta(
    'imageBytes',
  );
  @override
  late final GeneratedColumn<Uint8List> imageBytes = GeneratedColumn<Uint8List>(
    'image_bytes',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RecipeCategory, int> category =
      GeneratedColumn<int>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(RecipeCategory.lunch.index),
      ).withConverter<RecipeCategory>($RecipesTable.$convertercategory);
  static const VerificationMeta _servingsMeta = const VerificationMeta(
    'servings',
  );
  @override
  late final GeneratedColumn<double> servings = GeneratedColumn<double>(
    'servings',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _prepTimeMinutesMeta = const VerificationMeta(
    'prepTimeMinutes',
  );
  @override
  late final GeneratedColumn<int> prepTimeMinutes = GeneratedColumn<int>(
    'prep_time_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    imagePath,
    imageBytes,
    category,
    servings,
    isFavorite,
    prepTimeMinutes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Recipe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('image_bytes')) {
      context.handle(
        _imageBytesMeta,
        imageBytes.isAcceptableOrUnknown(data['image_bytes']!, _imageBytesMeta),
      );
    }
    if (data.containsKey('servings')) {
      context.handle(
        _servingsMeta,
        servings.isAcceptableOrUnknown(data['servings']!, _servingsMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('prep_time_minutes')) {
      context.handle(
        _prepTimeMinutesMeta,
        prepTimeMinutes.isAcceptableOrUnknown(
          data['prep_time_minutes']!,
          _prepTimeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recipe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recipe(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      imageBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}image_bytes'],
      ),
      category: $RecipesTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}category'],
        )!,
      ),
      servings: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}servings'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      prepTimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prep_time_minutes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RecipesTable createAlias(String alias) {
    return $RecipesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RecipeCategory, int, int> $convertercategory =
      const EnumIndexConverter<RecipeCategory>(RecipeCategory.values);
}

class Recipe extends DataClass implements Insertable<Recipe> {
  final int id;
  final String name;
  final String? imagePath;
  final Uint8List? imageBytes;
  final RecipeCategory category;
  final double servings;
  final bool isFavorite;
  final int? prepTimeMinutes;
  final DateTime createdAt;
  const Recipe({
    required this.id,
    required this.name,
    this.imagePath,
    this.imageBytes,
    required this.category,
    required this.servings,
    required this.isFavorite,
    this.prepTimeMinutes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || imageBytes != null) {
      map['image_bytes'] = Variable<Uint8List>(imageBytes);
    }
    {
      map['category'] = Variable<int>(
        $RecipesTable.$convertercategory.toSql(category),
      );
    }
    map['servings'] = Variable<double>(servings);
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || prepTimeMinutes != null) {
      map['prep_time_minutes'] = Variable<int>(prepTimeMinutes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RecipesCompanion toCompanion(bool nullToAbsent) {
    return RecipesCompanion(
      id: Value(id),
      name: Value(name),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      imageBytes: imageBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(imageBytes),
      category: Value(category),
      servings: Value(servings),
      isFavorite: Value(isFavorite),
      prepTimeMinutes: prepTimeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(prepTimeMinutes),
      createdAt: Value(createdAt),
    );
  }

  factory Recipe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recipe(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      imageBytes: serializer.fromJson<Uint8List?>(json['imageBytes']),
      category: $RecipesTable.$convertercategory.fromJson(
        serializer.fromJson<int>(json['category']),
      ),
      servings: serializer.fromJson<double>(json['servings']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      prepTimeMinutes: serializer.fromJson<int?>(json['prepTimeMinutes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'imagePath': serializer.toJson<String?>(imagePath),
      'imageBytes': serializer.toJson<Uint8List?>(imageBytes),
      'category': serializer.toJson<int>(
        $RecipesTable.$convertercategory.toJson(category),
      ),
      'servings': serializer.toJson<double>(servings),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'prepTimeMinutes': serializer.toJson<int?>(prepTimeMinutes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Recipe copyWith({
    int? id,
    String? name,
    Value<String?> imagePath = const Value.absent(),
    Value<Uint8List?> imageBytes = const Value.absent(),
    RecipeCategory? category,
    double? servings,
    bool? isFavorite,
    Value<int?> prepTimeMinutes = const Value.absent(),
    DateTime? createdAt,
  }) => Recipe(
    id: id ?? this.id,
    name: name ?? this.name,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    imageBytes: imageBytes.present ? imageBytes.value : this.imageBytes,
    category: category ?? this.category,
    servings: servings ?? this.servings,
    isFavorite: isFavorite ?? this.isFavorite,
    prepTimeMinutes: prepTimeMinutes.present
        ? prepTimeMinutes.value
        : this.prepTimeMinutes,
    createdAt: createdAt ?? this.createdAt,
  );
  Recipe copyWithCompanion(RecipesCompanion data) {
    return Recipe(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      imageBytes: data.imageBytes.present
          ? data.imageBytes.value
          : this.imageBytes,
      category: data.category.present ? data.category.value : this.category,
      servings: data.servings.present ? data.servings.value : this.servings,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      prepTimeMinutes: data.prepTimeMinutes.present
          ? data.prepTimeMinutes.value
          : this.prepTimeMinutes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recipe(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imagePath: $imagePath, ')
          ..write('imageBytes: $imageBytes, ')
          ..write('category: $category, ')
          ..write('servings: $servings, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('prepTimeMinutes: $prepTimeMinutes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    imagePath,
    $driftBlobEquality.hash(imageBytes),
    category,
    servings,
    isFavorite,
    prepTimeMinutes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recipe &&
          other.id == this.id &&
          other.name == this.name &&
          other.imagePath == this.imagePath &&
          $driftBlobEquality.equals(other.imageBytes, this.imageBytes) &&
          other.category == this.category &&
          other.servings == this.servings &&
          other.isFavorite == this.isFavorite &&
          other.prepTimeMinutes == this.prepTimeMinutes &&
          other.createdAt == this.createdAt);
}

class RecipesCompanion extends UpdateCompanion<Recipe> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> imagePath;
  final Value<Uint8List?> imageBytes;
  final Value<RecipeCategory> category;
  final Value<double> servings;
  final Value<bool> isFavorite;
  final Value<int?> prepTimeMinutes;
  final Value<DateTime> createdAt;
  const RecipesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.imageBytes = const Value.absent(),
    this.category = const Value.absent(),
    this.servings = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.prepTimeMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RecipesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.imagePath = const Value.absent(),
    this.imageBytes = const Value.absent(),
    this.category = const Value.absent(),
    this.servings = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.prepTimeMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Recipe> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? imagePath,
    Expression<Uint8List>? imageBytes,
    Expression<int>? category,
    Expression<double>? servings,
    Expression<bool>? isFavorite,
    Expression<int>? prepTimeMinutes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (imagePath != null) 'image_path': imagePath,
      if (imageBytes != null) 'image_bytes': imageBytes,
      if (category != null) 'category': category,
      if (servings != null) 'servings': servings,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (prepTimeMinutes != null) 'prep_time_minutes': prepTimeMinutes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RecipesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? imagePath,
    Value<Uint8List?>? imageBytes,
    Value<RecipeCategory>? category,
    Value<double>? servings,
    Value<bool>? isFavorite,
    Value<int?>? prepTimeMinutes,
    Value<DateTime>? createdAt,
  }) {
    return RecipesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      imageBytes: imageBytes ?? this.imageBytes,
      category: category ?? this.category,
      servings: servings ?? this.servings,
      isFavorite: isFavorite ?? this.isFavorite,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (imageBytes.present) {
      map['image_bytes'] = Variable<Uint8List>(imageBytes.value);
    }
    if (category.present) {
      map['category'] = Variable<int>(
        $RecipesTable.$convertercategory.toSql(category.value),
      );
    }
    if (servings.present) {
      map['servings'] = Variable<double>(servings.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (prepTimeMinutes.present) {
      map['prep_time_minutes'] = Variable<int>(prepTimeMinutes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imagePath: $imagePath, ')
          ..write('imageBytes: $imageBytes, ')
          ..write('category: $category, ')
          ..write('servings: $servings, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('prepTimeMinutes: $prepTimeMinutes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RecipeIngredientsTable extends RecipeIngredients
    with TableInfo<$RecipeIngredientsTable, RecipeIngredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<int> recipeId = GeneratedColumn<int>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<int> foodId = GeneratedColumn<int>(
    'food_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
    'grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recipeId,
    foodId,
    grams,
    orderIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeIngredient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_foodIdMeta);
    }
    if (data.containsKey('grams')) {
      context.handle(
        _gramsMeta,
        grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta),
      );
    } else if (isInserting) {
      context.missing(_gramsMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeIngredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeIngredient(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recipe_id'],
      )!,
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}food_id'],
      )!,
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
    );
  }

  @override
  $RecipeIngredientsTable createAlias(String alias) {
    return $RecipeIngredientsTable(attachedDatabase, alias);
  }
}

class RecipeIngredient extends DataClass
    implements Insertable<RecipeIngredient> {
  final int id;
  final int recipeId;
  final int foodId;
  final double grams;
  final int orderIndex;
  const RecipeIngredient({
    required this.id,
    required this.recipeId,
    required this.foodId,
    required this.grams,
    required this.orderIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recipe_id'] = Variable<int>(recipeId);
    map['food_id'] = Variable<int>(foodId);
    map['grams'] = Variable<double>(grams);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  RecipeIngredientsCompanion toCompanion(bool nullToAbsent) {
    return RecipeIngredientsCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      foodId: Value(foodId),
      grams: Value(grams),
      orderIndex: Value(orderIndex),
    );
  }

  factory RecipeIngredient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeIngredient(
      id: serializer.fromJson<int>(json['id']),
      recipeId: serializer.fromJson<int>(json['recipeId']),
      foodId: serializer.fromJson<int>(json['foodId']),
      grams: serializer.fromJson<double>(json['grams']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recipeId': serializer.toJson<int>(recipeId),
      'foodId': serializer.toJson<int>(foodId),
      'grams': serializer.toJson<double>(grams),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  RecipeIngredient copyWith({
    int? id,
    int? recipeId,
    int? foodId,
    double? grams,
    int? orderIndex,
  }) => RecipeIngredient(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
    foodId: foodId ?? this.foodId,
    grams: grams ?? this.grams,
    orderIndex: orderIndex ?? this.orderIndex,
  );
  RecipeIngredient copyWithCompanion(RecipeIngredientsCompanion data) {
    return RecipeIngredient(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      grams: data.grams.present ? data.grams.value : this.grams,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredient(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('foodId: $foodId, ')
          ..write('grams: $grams, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, recipeId, foodId, grams, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeIngredient &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.foodId == this.foodId &&
          other.grams == this.grams &&
          other.orderIndex == this.orderIndex);
}

class RecipeIngredientsCompanion extends UpdateCompanion<RecipeIngredient> {
  final Value<int> id;
  final Value<int> recipeId;
  final Value<int> foodId;
  final Value<double> grams;
  final Value<int> orderIndex;
  const RecipeIngredientsCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.foodId = const Value.absent(),
    this.grams = const Value.absent(),
    this.orderIndex = const Value.absent(),
  });
  RecipeIngredientsCompanion.insert({
    this.id = const Value.absent(),
    required int recipeId,
    required int foodId,
    required double grams,
    required int orderIndex,
  }) : recipeId = Value(recipeId),
       foodId = Value(foodId),
       grams = Value(grams),
       orderIndex = Value(orderIndex);
  static Insertable<RecipeIngredient> custom({
    Expression<int>? id,
    Expression<int>? recipeId,
    Expression<int>? foodId,
    Expression<double>? grams,
    Expression<int>? orderIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (foodId != null) 'food_id': foodId,
      if (grams != null) 'grams': grams,
      if (orderIndex != null) 'order_index': orderIndex,
    });
  }

  RecipeIngredientsCompanion copyWith({
    Value<int>? id,
    Value<int>? recipeId,
    Value<int>? foodId,
    Value<double>? grams,
    Value<int>? orderIndex,
  }) {
    return RecipeIngredientsCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      foodId: foodId ?? this.foodId,
      grams: grams ?? this.grams,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<int>(recipeId.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<int>(foodId.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredientsCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('foodId: $foodId, ')
          ..write('grams: $grams, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }
}

class $DiaryEntriesTable extends DiaryEntries
    with TableInfo<$DiaryEntriesTable, DiaryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiaryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MealType, int> mealType =
      GeneratedColumn<int>(
        'meal_type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<MealType>($DiaryEntriesTable.$convertermealType);
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<int> foodId = GeneratedColumn<int>(
    'food_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<int> recipeId = GeneratedColumn<int>(
    'recipe_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityGramsMeta = const VerificationMeta(
    'quantityGrams',
  );
  @override
  late final GeneratedColumn<double> quantityGrams = GeneratedColumn<double>(
    'quantity_grams',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _servingsMeta = const VerificationMeta(
    'servings',
  );
  @override
  late final GeneratedColumn<double> servings = GeneratedColumn<double>(
    'servings',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
    'kcal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinGMeta = const VerificationMeta(
    'proteinG',
  );
  @override
  late final GeneratedColumn<double> proteinG = GeneratedColumn<double>(
    'protein_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsGMeta = const VerificationMeta('carbsG');
  @override
  late final GeneratedColumn<double> carbsG = GeneratedColumn<double>(
    'carbs_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatGMeta = const VerificationMeta('fatG');
  @override
  late final GeneratedColumn<double> fatG = GeneratedColumn<double>(
    'fat_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    mealType,
    foodId,
    recipeId,
    quantityGrams,
    servings,
    orderIndex,
    kcal,
    proteinG,
    carbsG,
    fatG,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diary_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiaryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta),
      );
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    }
    if (data.containsKey('quantity_grams')) {
      context.handle(
        _quantityGramsMeta,
        quantityGrams.isAcceptableOrUnknown(
          data['quantity_grams']!,
          _quantityGramsMeta,
        ),
      );
    }
    if (data.containsKey('servings')) {
      context.handle(
        _servingsMeta,
        servings.isAcceptableOrUnknown(data['servings']!, _servingsMeta),
      );
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    } else if (isInserting) {
      context.missing(_kcalMeta);
    }
    if (data.containsKey('protein_g')) {
      context.handle(
        _proteinGMeta,
        proteinG.isAcceptableOrUnknown(data['protein_g']!, _proteinGMeta),
      );
    } else if (isInserting) {
      context.missing(_proteinGMeta);
    }
    if (data.containsKey('carbs_g')) {
      context.handle(
        _carbsGMeta,
        carbsG.isAcceptableOrUnknown(data['carbs_g']!, _carbsGMeta),
      );
    } else if (isInserting) {
      context.missing(_carbsGMeta);
    }
    if (data.containsKey('fat_g')) {
      context.handle(
        _fatGMeta,
        fatG.isAcceptableOrUnknown(data['fat_g']!, _fatGMeta),
      );
    } else if (isInserting) {
      context.missing(_fatGMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiaryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiaryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      mealType: $DiaryEntriesTable.$convertermealType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}meal_type'],
        )!,
      ),
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}food_id'],
      ),
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recipe_id'],
      ),
      quantityGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity_grams'],
      ),
      servings: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}servings'],
      ),
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal'],
      )!,
      proteinG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_g'],
      )!,
      carbsG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_g'],
      )!,
      fatG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_g'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DiaryEntriesTable createAlias(String alias) {
    return $DiaryEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MealType, int, int> $convertermealType =
      const EnumIndexConverter<MealType>(MealType.values);
}

class DiaryEntry extends DataClass implements Insertable<DiaryEntry> {
  final int id;
  final DateTime date;
  final MealType mealType;
  final int? foodId;
  final int? recipeId;
  final double? quantityGrams;
  final double? servings;
  final int orderIndex;
  final double kcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final DateTime createdAt;
  const DiaryEntry({
    required this.id,
    required this.date,
    required this.mealType,
    this.foodId,
    this.recipeId,
    this.quantityGrams,
    this.servings,
    required this.orderIndex,
    required this.kcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    {
      map['meal_type'] = Variable<int>(
        $DiaryEntriesTable.$convertermealType.toSql(mealType),
      );
    }
    if (!nullToAbsent || foodId != null) {
      map['food_id'] = Variable<int>(foodId);
    }
    if (!nullToAbsent || recipeId != null) {
      map['recipe_id'] = Variable<int>(recipeId);
    }
    if (!nullToAbsent || quantityGrams != null) {
      map['quantity_grams'] = Variable<double>(quantityGrams);
    }
    if (!nullToAbsent || servings != null) {
      map['servings'] = Variable<double>(servings);
    }
    map['order_index'] = Variable<int>(orderIndex);
    map['kcal'] = Variable<double>(kcal);
    map['protein_g'] = Variable<double>(proteinG);
    map['carbs_g'] = Variable<double>(carbsG);
    map['fat_g'] = Variable<double>(fatG);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DiaryEntriesCompanion toCompanion(bool nullToAbsent) {
    return DiaryEntriesCompanion(
      id: Value(id),
      date: Value(date),
      mealType: Value(mealType),
      foodId: foodId == null && nullToAbsent
          ? const Value.absent()
          : Value(foodId),
      recipeId: recipeId == null && nullToAbsent
          ? const Value.absent()
          : Value(recipeId),
      quantityGrams: quantityGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(quantityGrams),
      servings: servings == null && nullToAbsent
          ? const Value.absent()
          : Value(servings),
      orderIndex: Value(orderIndex),
      kcal: Value(kcal),
      proteinG: Value(proteinG),
      carbsG: Value(carbsG),
      fatG: Value(fatG),
      createdAt: Value(createdAt),
    );
  }

  factory DiaryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiaryEntry(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      mealType: $DiaryEntriesTable.$convertermealType.fromJson(
        serializer.fromJson<int>(json['mealType']),
      ),
      foodId: serializer.fromJson<int?>(json['foodId']),
      recipeId: serializer.fromJson<int?>(json['recipeId']),
      quantityGrams: serializer.fromJson<double?>(json['quantityGrams']),
      servings: serializer.fromJson<double?>(json['servings']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      kcal: serializer.fromJson<double>(json['kcal']),
      proteinG: serializer.fromJson<double>(json['proteinG']),
      carbsG: serializer.fromJson<double>(json['carbsG']),
      fatG: serializer.fromJson<double>(json['fatG']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'mealType': serializer.toJson<int>(
        $DiaryEntriesTable.$convertermealType.toJson(mealType),
      ),
      'foodId': serializer.toJson<int?>(foodId),
      'recipeId': serializer.toJson<int?>(recipeId),
      'quantityGrams': serializer.toJson<double?>(quantityGrams),
      'servings': serializer.toJson<double?>(servings),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'kcal': serializer.toJson<double>(kcal),
      'proteinG': serializer.toJson<double>(proteinG),
      'carbsG': serializer.toJson<double>(carbsG),
      'fatG': serializer.toJson<double>(fatG),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DiaryEntry copyWith({
    int? id,
    DateTime? date,
    MealType? mealType,
    Value<int?> foodId = const Value.absent(),
    Value<int?> recipeId = const Value.absent(),
    Value<double?> quantityGrams = const Value.absent(),
    Value<double?> servings = const Value.absent(),
    int? orderIndex,
    double? kcal,
    double? proteinG,
    double? carbsG,
    double? fatG,
    DateTime? createdAt,
  }) => DiaryEntry(
    id: id ?? this.id,
    date: date ?? this.date,
    mealType: mealType ?? this.mealType,
    foodId: foodId.present ? foodId.value : this.foodId,
    recipeId: recipeId.present ? recipeId.value : this.recipeId,
    quantityGrams: quantityGrams.present
        ? quantityGrams.value
        : this.quantityGrams,
    servings: servings.present ? servings.value : this.servings,
    orderIndex: orderIndex ?? this.orderIndex,
    kcal: kcal ?? this.kcal,
    proteinG: proteinG ?? this.proteinG,
    carbsG: carbsG ?? this.carbsG,
    fatG: fatG ?? this.fatG,
    createdAt: createdAt ?? this.createdAt,
  );
  DiaryEntry copyWithCompanion(DiaryEntriesCompanion data) {
    return DiaryEntry(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      quantityGrams: data.quantityGrams.present
          ? data.quantityGrams.value
          : this.quantityGrams,
      servings: data.servings.present ? data.servings.value : this.servings,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      proteinG: data.proteinG.present ? data.proteinG.value : this.proteinG,
      carbsG: data.carbsG.present ? data.carbsG.value : this.carbsG,
      fatG: data.fatG.present ? data.fatG.value : this.fatG,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiaryEntry(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('mealType: $mealType, ')
          ..write('foodId: $foodId, ')
          ..write('recipeId: $recipeId, ')
          ..write('quantityGrams: $quantityGrams, ')
          ..write('servings: $servings, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('kcal: $kcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbsG: $carbsG, ')
          ..write('fatG: $fatG, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    mealType,
    foodId,
    recipeId,
    quantityGrams,
    servings,
    orderIndex,
    kcal,
    proteinG,
    carbsG,
    fatG,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiaryEntry &&
          other.id == this.id &&
          other.date == this.date &&
          other.mealType == this.mealType &&
          other.foodId == this.foodId &&
          other.recipeId == this.recipeId &&
          other.quantityGrams == this.quantityGrams &&
          other.servings == this.servings &&
          other.orderIndex == this.orderIndex &&
          other.kcal == this.kcal &&
          other.proteinG == this.proteinG &&
          other.carbsG == this.carbsG &&
          other.fatG == this.fatG &&
          other.createdAt == this.createdAt);
}

class DiaryEntriesCompanion extends UpdateCompanion<DiaryEntry> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<MealType> mealType;
  final Value<int?> foodId;
  final Value<int?> recipeId;
  final Value<double?> quantityGrams;
  final Value<double?> servings;
  final Value<int> orderIndex;
  final Value<double> kcal;
  final Value<double> proteinG;
  final Value<double> carbsG;
  final Value<double> fatG;
  final Value<DateTime> createdAt;
  const DiaryEntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.mealType = const Value.absent(),
    this.foodId = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.quantityGrams = const Value.absent(),
    this.servings = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.kcal = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DiaryEntriesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required MealType mealType,
    this.foodId = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.quantityGrams = const Value.absent(),
    this.servings = const Value.absent(),
    required int orderIndex,
    required double kcal,
    required double proteinG,
    required double carbsG,
    required double fatG,
    this.createdAt = const Value.absent(),
  }) : date = Value(date),
       mealType = Value(mealType),
       orderIndex = Value(orderIndex),
       kcal = Value(kcal),
       proteinG = Value(proteinG),
       carbsG = Value(carbsG),
       fatG = Value(fatG);
  static Insertable<DiaryEntry> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? mealType,
    Expression<int>? foodId,
    Expression<int>? recipeId,
    Expression<double>? quantityGrams,
    Expression<double>? servings,
    Expression<int>? orderIndex,
    Expression<double>? kcal,
    Expression<double>? proteinG,
    Expression<double>? carbsG,
    Expression<double>? fatG,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (mealType != null) 'meal_type': mealType,
      if (foodId != null) 'food_id': foodId,
      if (recipeId != null) 'recipe_id': recipeId,
      if (quantityGrams != null) 'quantity_grams': quantityGrams,
      if (servings != null) 'servings': servings,
      if (orderIndex != null) 'order_index': orderIndex,
      if (kcal != null) 'kcal': kcal,
      if (proteinG != null) 'protein_g': proteinG,
      if (carbsG != null) 'carbs_g': carbsG,
      if (fatG != null) 'fat_g': fatG,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DiaryEntriesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<MealType>? mealType,
    Value<int?>? foodId,
    Value<int?>? recipeId,
    Value<double?>? quantityGrams,
    Value<double?>? servings,
    Value<int>? orderIndex,
    Value<double>? kcal,
    Value<double>? proteinG,
    Value<double>? carbsG,
    Value<double>? fatG,
    Value<DateTime>? createdAt,
  }) {
    return DiaryEntriesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      foodId: foodId ?? this.foodId,
      recipeId: recipeId ?? this.recipeId,
      quantityGrams: quantityGrams ?? this.quantityGrams,
      servings: servings ?? this.servings,
      orderIndex: orderIndex ?? this.orderIndex,
      kcal: kcal ?? this.kcal,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<int>(
        $DiaryEntriesTable.$convertermealType.toSql(mealType.value),
      );
    }
    if (foodId.present) {
      map['food_id'] = Variable<int>(foodId.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<int>(recipeId.value);
    }
    if (quantityGrams.present) {
      map['quantity_grams'] = Variable<double>(quantityGrams.value);
    }
    if (servings.present) {
      map['servings'] = Variable<double>(servings.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (proteinG.present) {
      map['protein_g'] = Variable<double>(proteinG.value);
    }
    if (carbsG.present) {
      map['carbs_g'] = Variable<double>(carbsG.value);
    }
    if (fatG.present) {
      map['fat_g'] = Variable<double>(fatG.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiaryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('mealType: $mealType, ')
          ..write('foodId: $foodId, ')
          ..write('recipeId: $recipeId, ')
          ..write('quantityGrams: $quantityGrams, ')
          ..write('servings: $servings, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('kcal: $kcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbsG: $carbsG, ')
          ..write('fatG: $fatG, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BodyWeightLogsTable extends BodyWeightLogs
    with TableInfo<$BodyWeightLogsTable, BodyWeightLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyWeightLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, weightKg, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_weight_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<BodyWeightLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BodyWeightLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyWeightLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $BodyWeightLogsTable createAlias(String alias) {
    return $BodyWeightLogsTable(attachedDatabase, alias);
  }
}

class BodyWeightLog extends DataClass implements Insertable<BodyWeightLog> {
  final int id;
  final DateTime date;
  final double weightKg;
  final String? notes;
  const BodyWeightLog({
    required this.id,
    required this.date,
    required this.weightKg,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['weight_kg'] = Variable<double>(weightKg);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  BodyWeightLogsCompanion toCompanion(bool nullToAbsent) {
    return BodyWeightLogsCompanion(
      id: Value(id),
      date: Value(date),
      weightKg: Value(weightKg),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory BodyWeightLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyWeightLog(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'weightKg': serializer.toJson<double>(weightKg),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  BodyWeightLog copyWith({
    int? id,
    DateTime? date,
    double? weightKg,
    Value<String?> notes = const Value.absent(),
  }) => BodyWeightLog(
    id: id ?? this.id,
    date: date ?? this.date,
    weightKg: weightKg ?? this.weightKg,
    notes: notes.present ? notes.value : this.notes,
  );
  BodyWeightLog copyWithCompanion(BodyWeightLogsCompanion data) {
    return BodyWeightLog(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyWeightLog(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('weightKg: $weightKg, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, weightKg, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyWeightLog &&
          other.id == this.id &&
          other.date == this.date &&
          other.weightKg == this.weightKg &&
          other.notes == this.notes);
}

class BodyWeightLogsCompanion extends UpdateCompanion<BodyWeightLog> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<double> weightKg;
  final Value<String?> notes;
  const BodyWeightLogsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.notes = const Value.absent(),
  });
  BodyWeightLogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required double weightKg,
    this.notes = const Value.absent(),
  }) : date = Value(date),
       weightKg = Value(weightKg);
  static Insertable<BodyWeightLog> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<double>? weightKg,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (weightKg != null) 'weight_kg': weightKg,
      if (notes != null) 'notes': notes,
    });
  }

  BodyWeightLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<double>? weightKg,
    Value<String?>? notes,
  }) {
    return BodyWeightLogsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyWeightLogsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('weightKg: $weightKg, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $BurnedCaloriesTable extends BurnedCalories
    with TableInfo<$BurnedCaloriesTable, BurnedCalory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BurnedCaloriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
    'kcal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BurnedCalorieSource, int> source =
      GeneratedColumn<int>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(BurnedCalorieSource.manual.index),
      ).withConverter<BurnedCalorieSource>(
        $BurnedCaloriesTable.$convertersource,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    kcal,
    label,
    source,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'burned_calories';
  @override
  VerificationContext validateIntegrity(
    Insertable<BurnedCalory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    } else if (isInserting) {
      context.missing(_kcalMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BurnedCalory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BurnedCalory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      source: $BurnedCaloriesTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}source'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BurnedCaloriesTable createAlias(String alias) {
    return $BurnedCaloriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BurnedCalorieSource, int, int> $convertersource =
      const EnumIndexConverter<BurnedCalorieSource>(BurnedCalorieSource.values);
}

class BurnedCalory extends DataClass implements Insertable<BurnedCalory> {
  final int id;
  final DateTime date;
  final double kcal;
  final String? label;
  final BurnedCalorieSource source;
  final DateTime createdAt;
  const BurnedCalory({
    required this.id,
    required this.date,
    required this.kcal,
    this.label,
    required this.source,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['kcal'] = Variable<double>(kcal);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    {
      map['source'] = Variable<int>(
        $BurnedCaloriesTable.$convertersource.toSql(source),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BurnedCaloriesCompanion toCompanion(bool nullToAbsent) {
    return BurnedCaloriesCompanion(
      id: Value(id),
      date: Value(date),
      kcal: Value(kcal),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      source: Value(source),
      createdAt: Value(createdAt),
    );
  }

  factory BurnedCalory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BurnedCalory(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      kcal: serializer.fromJson<double>(json['kcal']),
      label: serializer.fromJson<String?>(json['label']),
      source: $BurnedCaloriesTable.$convertersource.fromJson(
        serializer.fromJson<int>(json['source']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'kcal': serializer.toJson<double>(kcal),
      'label': serializer.toJson<String?>(label),
      'source': serializer.toJson<int>(
        $BurnedCaloriesTable.$convertersource.toJson(source),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BurnedCalory copyWith({
    int? id,
    DateTime? date,
    double? kcal,
    Value<String?> label = const Value.absent(),
    BurnedCalorieSource? source,
    DateTime? createdAt,
  }) => BurnedCalory(
    id: id ?? this.id,
    date: date ?? this.date,
    kcal: kcal ?? this.kcal,
    label: label.present ? label.value : this.label,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
  );
  BurnedCalory copyWithCompanion(BurnedCaloriesCompanion data) {
    return BurnedCalory(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      label: data.label.present ? data.label.value : this.label,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BurnedCalory(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('kcal: $kcal, ')
          ..write('label: $label, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, kcal, label, source, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BurnedCalory &&
          other.id == this.id &&
          other.date == this.date &&
          other.kcal == this.kcal &&
          other.label == this.label &&
          other.source == this.source &&
          other.createdAt == this.createdAt);
}

class BurnedCaloriesCompanion extends UpdateCompanion<BurnedCalory> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<double> kcal;
  final Value<String?> label;
  final Value<BurnedCalorieSource> source;
  final Value<DateTime> createdAt;
  const BurnedCaloriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.kcal = const Value.absent(),
    this.label = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BurnedCaloriesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required double kcal,
    this.label = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : date = Value(date),
       kcal = Value(kcal);
  static Insertable<BurnedCalory> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<double>? kcal,
    Expression<String>? label,
    Expression<int>? source,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (kcal != null) 'kcal': kcal,
      if (label != null) 'label': label,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BurnedCaloriesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<double>? kcal,
    Value<String?>? label,
    Value<BurnedCalorieSource>? source,
    Value<DateTime>? createdAt,
  }) {
    return BurnedCaloriesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      kcal: kcal ?? this.kcal,
      label: label ?? this.label,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (source.present) {
      map['source'] = Variable<int>(
        $BurnedCaloriesTable.$convertersource.toSql(source.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BurnedCaloriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('kcal: $kcal, ')
          ..write('label: $label, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfileTable userProfile = $UserProfileTable(this);
  late final $FoodsTable foods = $FoodsTable(this);
  late final $RecipesTable recipes = $RecipesTable(this);
  late final $RecipeIngredientsTable recipeIngredients =
      $RecipeIngredientsTable(this);
  late final $DiaryEntriesTable diaryEntries = $DiaryEntriesTable(this);
  late final $BodyWeightLogsTable bodyWeightLogs = $BodyWeightLogsTable(this);
  late final $BurnedCaloriesTable burnedCalories = $BurnedCaloriesTable(this);
  late final UserProfileDao userProfileDao = UserProfileDao(
    this as AppDatabase,
  );
  late final FoodsDao foodsDao = FoodsDao(this as AppDatabase);
  late final RecipesDao recipesDao = RecipesDao(this as AppDatabase);
  late final RecipeIngredientsDao recipeIngredientsDao = RecipeIngredientsDao(
    this as AppDatabase,
  );
  late final DiaryDao diaryDao = DiaryDao(this as AppDatabase);
  late final BodyWeightDao bodyWeightDao = BodyWeightDao(this as AppDatabase);
  late final BurnedCaloriesDao burnedCaloriesDao = BurnedCaloriesDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfile,
    foods,
    recipes,
    recipeIngredients,
    diaryEntries,
    bodyWeightLogs,
    burnedCalories,
  ];
}

typedef $$UserProfileTableCreateCompanionBuilder =
    UserProfileCompanion Function({
      Value<int> id,
      Value<String?> name,
      Value<BiologicalSex?> sex,
      Value<DateTime?> birthDate,
      Value<double?> heightCm,
      Value<ActivityLevel> activityLevel,
      Value<GoalType> goalType,
      Value<double> weeklyWeightChangeKg,
      Value<double?> startingWeightKg,
      Value<double?> goalWeightKg,
      Value<CalorieTargetMode> calorieTargetMode,
      Value<int?> manualCalorieTarget,
      Value<double> proteinGramsPerKg,
      Value<double> fatPercentOfCalories,
      Value<double?> manualProteinTargetG,
      Value<double?> manualCarbTargetG,
      Value<double?> manualFatTargetG,
      Value<WeightUnit> weightUnit,
      Value<FoodMassUnit> foodMassUnit,
      Value<AppearanceMode> appearanceMode,
      Value<bool> remindersEnabled,
      Value<bool> onboardingCompleted,
    });
typedef $$UserProfileTableUpdateCompanionBuilder =
    UserProfileCompanion Function({
      Value<int> id,
      Value<String?> name,
      Value<BiologicalSex?> sex,
      Value<DateTime?> birthDate,
      Value<double?> heightCm,
      Value<ActivityLevel> activityLevel,
      Value<GoalType> goalType,
      Value<double> weeklyWeightChangeKg,
      Value<double?> startingWeightKg,
      Value<double?> goalWeightKg,
      Value<CalorieTargetMode> calorieTargetMode,
      Value<int?> manualCalorieTarget,
      Value<double> proteinGramsPerKg,
      Value<double> fatPercentOfCalories,
      Value<double?> manualProteinTargetG,
      Value<double?> manualCarbTargetG,
      Value<double?> manualFatTargetG,
      Value<WeightUnit> weightUnit,
      Value<FoodMassUnit> foodMassUnit,
      Value<AppearanceMode> appearanceMode,
      Value<bool> remindersEnabled,
      Value<bool> onboardingCompleted,
    });

class $$UserProfileTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfileTable> {
  $$UserProfileTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BiologicalSex?, BiologicalSex, int> get sex =>
      $composableBuilder(
        column: $table.sex,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ActivityLevel, ActivityLevel, int>
  get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<GoalType, GoalType, int> get goalType =>
      $composableBuilder(
        column: $table.goalType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get weeklyWeightChangeKg => $composableBuilder(
    column: $table.weeklyWeightChangeKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startingWeightKg => $composableBuilder(
    column: $table.startingWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get goalWeightKg => $composableBuilder(
    column: $table.goalWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CalorieTargetMode, CalorieTargetMode, int>
  get calorieTargetMode => $composableBuilder(
    column: $table.calorieTargetMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get manualCalorieTarget => $composableBuilder(
    column: $table.manualCalorieTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinGramsPerKg => $composableBuilder(
    column: $table.proteinGramsPerKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatPercentOfCalories => $composableBuilder(
    column: $table.fatPercentOfCalories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get manualProteinTargetG => $composableBuilder(
    column: $table.manualProteinTargetG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get manualCarbTargetG => $composableBuilder(
    column: $table.manualCarbTargetG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get manualFatTargetG => $composableBuilder(
    column: $table.manualFatTargetG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WeightUnit, WeightUnit, int> get weightUnit =>
      $composableBuilder(
        column: $table.weightUnit,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<FoodMassUnit, FoodMassUnit, int>
  get foodMassUnit => $composableBuilder(
    column: $table.foodMassUnit,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<AppearanceMode, AppearanceMode, int>
  get appearanceMode => $composableBuilder(
    column: $table.appearanceMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfileTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfileTable> {
  $$UserProfileTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goalType => $composableBuilder(
    column: $table.goalType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weeklyWeightChangeKg => $composableBuilder(
    column: $table.weeklyWeightChangeKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startingWeightKg => $composableBuilder(
    column: $table.startingWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get goalWeightKg => $composableBuilder(
    column: $table.goalWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calorieTargetMode => $composableBuilder(
    column: $table.calorieTargetMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get manualCalorieTarget => $composableBuilder(
    column: $table.manualCalorieTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinGramsPerKg => $composableBuilder(
    column: $table.proteinGramsPerKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatPercentOfCalories => $composableBuilder(
    column: $table.fatPercentOfCalories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get manualProteinTargetG => $composableBuilder(
    column: $table.manualProteinTargetG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get manualCarbTargetG => $composableBuilder(
    column: $table.manualCarbTargetG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get manualFatTargetG => $composableBuilder(
    column: $table.manualFatTargetG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get foodMassUnit => $composableBuilder(
    column: $table.foodMassUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get appearanceMode => $composableBuilder(
    column: $table.appearanceMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfileTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfileTable> {
  $$UserProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BiologicalSex?, int> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivityLevel, int> get activityLevel =>
      $composableBuilder(
        column: $table.activityLevel,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<GoalType, int> get goalType =>
      $composableBuilder(column: $table.goalType, builder: (column) => column);

  GeneratedColumn<double> get weeklyWeightChangeKg => $composableBuilder(
    column: $table.weeklyWeightChangeKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get startingWeightKg => $composableBuilder(
    column: $table.startingWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get goalWeightKg => $composableBuilder(
    column: $table.goalWeightKg,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<CalorieTargetMode, int>
  get calorieTargetMode => $composableBuilder(
    column: $table.calorieTargetMode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get manualCalorieTarget => $composableBuilder(
    column: $table.manualCalorieTarget,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinGramsPerKg => $composableBuilder(
    column: $table.proteinGramsPerKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatPercentOfCalories => $composableBuilder(
    column: $table.fatPercentOfCalories,
    builder: (column) => column,
  );

  GeneratedColumn<double> get manualProteinTargetG => $composableBuilder(
    column: $table.manualProteinTargetG,
    builder: (column) => column,
  );

  GeneratedColumn<double> get manualCarbTargetG => $composableBuilder(
    column: $table.manualCarbTargetG,
    builder: (column) => column,
  );

  GeneratedColumn<double> get manualFatTargetG => $composableBuilder(
    column: $table.manualFatTargetG,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<WeightUnit, int> get weightUnit =>
      $composableBuilder(
        column: $table.weightUnit,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<FoodMassUnit, int> get foodMassUnit =>
      $composableBuilder(
        column: $table.foodMassUnit,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<AppearanceMode, int> get appearanceMode =>
      $composableBuilder(
        column: $table.appearanceMode,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => column,
  );
}

class $$UserProfileTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfileTable,
          UserProfileData,
          $$UserProfileTableFilterComposer,
          $$UserProfileTableOrderingComposer,
          $$UserProfileTableAnnotationComposer,
          $$UserProfileTableCreateCompanionBuilder,
          $$UserProfileTableUpdateCompanionBuilder,
          (
            UserProfileData,
            BaseReferences<_$AppDatabase, $UserProfileTable, UserProfileData>,
          ),
          UserProfileData,
          PrefetchHooks Function()
        > {
  $$UserProfileTableTableManager(_$AppDatabase db, $UserProfileTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<BiologicalSex?> sex = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<ActivityLevel> activityLevel = const Value.absent(),
                Value<GoalType> goalType = const Value.absent(),
                Value<double> weeklyWeightChangeKg = const Value.absent(),
                Value<double?> startingWeightKg = const Value.absent(),
                Value<double?> goalWeightKg = const Value.absent(),
                Value<CalorieTargetMode> calorieTargetMode =
                    const Value.absent(),
                Value<int?> manualCalorieTarget = const Value.absent(),
                Value<double> proteinGramsPerKg = const Value.absent(),
                Value<double> fatPercentOfCalories = const Value.absent(),
                Value<double?> manualProteinTargetG = const Value.absent(),
                Value<double?> manualCarbTargetG = const Value.absent(),
                Value<double?> manualFatTargetG = const Value.absent(),
                Value<WeightUnit> weightUnit = const Value.absent(),
                Value<FoodMassUnit> foodMassUnit = const Value.absent(),
                Value<AppearanceMode> appearanceMode = const Value.absent(),
                Value<bool> remindersEnabled = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
              }) => UserProfileCompanion(
                id: id,
                name: name,
                sex: sex,
                birthDate: birthDate,
                heightCm: heightCm,
                activityLevel: activityLevel,
                goalType: goalType,
                weeklyWeightChangeKg: weeklyWeightChangeKg,
                startingWeightKg: startingWeightKg,
                goalWeightKg: goalWeightKg,
                calorieTargetMode: calorieTargetMode,
                manualCalorieTarget: manualCalorieTarget,
                proteinGramsPerKg: proteinGramsPerKg,
                fatPercentOfCalories: fatPercentOfCalories,
                manualProteinTargetG: manualProteinTargetG,
                manualCarbTargetG: manualCarbTargetG,
                manualFatTargetG: manualFatTargetG,
                weightUnit: weightUnit,
                foodMassUnit: foodMassUnit,
                appearanceMode: appearanceMode,
                remindersEnabled: remindersEnabled,
                onboardingCompleted: onboardingCompleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<BiologicalSex?> sex = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<ActivityLevel> activityLevel = const Value.absent(),
                Value<GoalType> goalType = const Value.absent(),
                Value<double> weeklyWeightChangeKg = const Value.absent(),
                Value<double?> startingWeightKg = const Value.absent(),
                Value<double?> goalWeightKg = const Value.absent(),
                Value<CalorieTargetMode> calorieTargetMode =
                    const Value.absent(),
                Value<int?> manualCalorieTarget = const Value.absent(),
                Value<double> proteinGramsPerKg = const Value.absent(),
                Value<double> fatPercentOfCalories = const Value.absent(),
                Value<double?> manualProteinTargetG = const Value.absent(),
                Value<double?> manualCarbTargetG = const Value.absent(),
                Value<double?> manualFatTargetG = const Value.absent(),
                Value<WeightUnit> weightUnit = const Value.absent(),
                Value<FoodMassUnit> foodMassUnit = const Value.absent(),
                Value<AppearanceMode> appearanceMode = const Value.absent(),
                Value<bool> remindersEnabled = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
              }) => UserProfileCompanion.insert(
                id: id,
                name: name,
                sex: sex,
                birthDate: birthDate,
                heightCm: heightCm,
                activityLevel: activityLevel,
                goalType: goalType,
                weeklyWeightChangeKg: weeklyWeightChangeKg,
                startingWeightKg: startingWeightKg,
                goalWeightKg: goalWeightKg,
                calorieTargetMode: calorieTargetMode,
                manualCalorieTarget: manualCalorieTarget,
                proteinGramsPerKg: proteinGramsPerKg,
                fatPercentOfCalories: fatPercentOfCalories,
                manualProteinTargetG: manualProteinTargetG,
                manualCarbTargetG: manualCarbTargetG,
                manualFatTargetG: manualFatTargetG,
                weightUnit: weightUnit,
                foodMassUnit: foodMassUnit,
                appearanceMode: appearanceMode,
                remindersEnabled: remindersEnabled,
                onboardingCompleted: onboardingCompleted,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfileTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfileTable,
      UserProfileData,
      $$UserProfileTableFilterComposer,
      $$UserProfileTableOrderingComposer,
      $$UserProfileTableAnnotationComposer,
      $$UserProfileTableCreateCompanionBuilder,
      $$UserProfileTableUpdateCompanionBuilder,
      (
        UserProfileData,
        BaseReferences<_$AppDatabase, $UserProfileTable, UserProfileData>,
      ),
      UserProfileData,
      PrefetchHooks Function()
    >;
typedef $$FoodsTableCreateCompanionBuilder =
    FoodsCompanion Function({
      Value<int> id,
      required String name,
      required double kcalPer100g,
      required double proteinPer100g,
      required double carbsPer100g,
      required double fatPer100g,
      Value<double?> fiberPer100g,
      Value<double?> defaultServingGrams,
      Value<String?> servingLabel,
      Value<bool> isCustom,
      Value<FoodCategory> category,
    });
typedef $$FoodsTableUpdateCompanionBuilder =
    FoodsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> kcalPer100g,
      Value<double> proteinPer100g,
      Value<double> carbsPer100g,
      Value<double> fatPer100g,
      Value<double?> fiberPer100g,
      Value<double?> defaultServingGrams,
      Value<String?> servingLabel,
      Value<bool> isCustom,
      Value<FoodCategory> category,
    });

class $$FoodsTableFilterComposer extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcalPer100g => $composableBuilder(
    column: $table.kcalPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinPer100g => $composableBuilder(
    column: $table.proteinPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsPer100g => $composableBuilder(
    column: $table.carbsPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatPer100g => $composableBuilder(
    column: $table.fatPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiberPer100g => $composableBuilder(
    column: $table.fiberPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultServingGrams => $composableBuilder(
    column: $table.defaultServingGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FoodCategory, FoodCategory, int>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$FoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcalPer100g => $composableBuilder(
    column: $table.kcalPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinPer100g => $composableBuilder(
    column: $table.proteinPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsPer100g => $composableBuilder(
    column: $table.carbsPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatPer100g => $composableBuilder(
    column: $table.fatPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiberPer100g => $composableBuilder(
    column: $table.fiberPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultServingGrams => $composableBuilder(
    column: $table.defaultServingGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get kcalPer100g => $composableBuilder(
    column: $table.kcalPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinPer100g => $composableBuilder(
    column: $table.proteinPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbsPer100g => $composableBuilder(
    column: $table.carbsPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatPer100g => $composableBuilder(
    column: $table.fatPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fiberPer100g => $composableBuilder(
    column: $table.fiberPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get defaultServingGrams => $composableBuilder(
    column: $table.defaultServingGrams,
    builder: (column) => column,
  );

  GeneratedColumn<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FoodCategory, int> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);
}

class $$FoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodsTable,
          Food,
          $$FoodsTableFilterComposer,
          $$FoodsTableOrderingComposer,
          $$FoodsTableAnnotationComposer,
          $$FoodsTableCreateCompanionBuilder,
          $$FoodsTableUpdateCompanionBuilder,
          (Food, BaseReferences<_$AppDatabase, $FoodsTable, Food>),
          Food,
          PrefetchHooks Function()
        > {
  $$FoodsTableTableManager(_$AppDatabase db, $FoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> kcalPer100g = const Value.absent(),
                Value<double> proteinPer100g = const Value.absent(),
                Value<double> carbsPer100g = const Value.absent(),
                Value<double> fatPer100g = const Value.absent(),
                Value<double?> fiberPer100g = const Value.absent(),
                Value<double?> defaultServingGrams = const Value.absent(),
                Value<String?> servingLabel = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<FoodCategory> category = const Value.absent(),
              }) => FoodsCompanion(
                id: id,
                name: name,
                kcalPer100g: kcalPer100g,
                proteinPer100g: proteinPer100g,
                carbsPer100g: carbsPer100g,
                fatPer100g: fatPer100g,
                fiberPer100g: fiberPer100g,
                defaultServingGrams: defaultServingGrams,
                servingLabel: servingLabel,
                isCustom: isCustom,
                category: category,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required double kcalPer100g,
                required double proteinPer100g,
                required double carbsPer100g,
                required double fatPer100g,
                Value<double?> fiberPer100g = const Value.absent(),
                Value<double?> defaultServingGrams = const Value.absent(),
                Value<String?> servingLabel = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<FoodCategory> category = const Value.absent(),
              }) => FoodsCompanion.insert(
                id: id,
                name: name,
                kcalPer100g: kcalPer100g,
                proteinPer100g: proteinPer100g,
                carbsPer100g: carbsPer100g,
                fatPer100g: fatPer100g,
                fiberPer100g: fiberPer100g,
                defaultServingGrams: defaultServingGrams,
                servingLabel: servingLabel,
                isCustom: isCustom,
                category: category,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodsTable,
      Food,
      $$FoodsTableFilterComposer,
      $$FoodsTableOrderingComposer,
      $$FoodsTableAnnotationComposer,
      $$FoodsTableCreateCompanionBuilder,
      $$FoodsTableUpdateCompanionBuilder,
      (Food, BaseReferences<_$AppDatabase, $FoodsTable, Food>),
      Food,
      PrefetchHooks Function()
    >;
typedef $$RecipesTableCreateCompanionBuilder =
    RecipesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> imagePath,
      Value<Uint8List?> imageBytes,
      Value<RecipeCategory> category,
      Value<double> servings,
      Value<bool> isFavorite,
      Value<int?> prepTimeMinutes,
      Value<DateTime> createdAt,
    });
typedef $$RecipesTableUpdateCompanionBuilder =
    RecipesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> imagePath,
      Value<Uint8List?> imageBytes,
      Value<RecipeCategory> category,
      Value<double> servings,
      Value<bool> isFavorite,
      Value<int?> prepTimeMinutes,
      Value<DateTime> createdAt,
    });

class $$RecipesTableFilterComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get imageBytes => $composableBuilder(
    column: $table.imageBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RecipeCategory, RecipeCategory, int>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get prepTimeMinutes => $composableBuilder(
    column: $table.prepTimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get imageBytes => $composableBuilder(
    column: $table.imageBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get prepTimeMinutes => $composableBuilder(
    column: $table.prepTimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<Uint8List> get imageBytes => $composableBuilder(
    column: $table.imageBytes,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<RecipeCategory, int> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get servings =>
      $composableBuilder(column: $table.servings, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get prepTimeMinutes => $composableBuilder(
    column: $table.prepTimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RecipesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipesTable,
          Recipe,
          $$RecipesTableFilterComposer,
          $$RecipesTableOrderingComposer,
          $$RecipesTableAnnotationComposer,
          $$RecipesTableCreateCompanionBuilder,
          $$RecipesTableUpdateCompanionBuilder,
          (Recipe, BaseReferences<_$AppDatabase, $RecipesTable, Recipe>),
          Recipe,
          PrefetchHooks Function()
        > {
  $$RecipesTableTableManager(_$AppDatabase db, $RecipesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<Uint8List?> imageBytes = const Value.absent(),
                Value<RecipeCategory> category = const Value.absent(),
                Value<double> servings = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int?> prepTimeMinutes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RecipesCompanion(
                id: id,
                name: name,
                imagePath: imagePath,
                imageBytes: imageBytes,
                category: category,
                servings: servings,
                isFavorite: isFavorite,
                prepTimeMinutes: prepTimeMinutes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> imagePath = const Value.absent(),
                Value<Uint8List?> imageBytes = const Value.absent(),
                Value<RecipeCategory> category = const Value.absent(),
                Value<double> servings = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int?> prepTimeMinutes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RecipesCompanion.insert(
                id: id,
                name: name,
                imagePath: imagePath,
                imageBytes: imageBytes,
                category: category,
                servings: servings,
                isFavorite: isFavorite,
                prepTimeMinutes: prepTimeMinutes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecipesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipesTable,
      Recipe,
      $$RecipesTableFilterComposer,
      $$RecipesTableOrderingComposer,
      $$RecipesTableAnnotationComposer,
      $$RecipesTableCreateCompanionBuilder,
      $$RecipesTableUpdateCompanionBuilder,
      (Recipe, BaseReferences<_$AppDatabase, $RecipesTable, Recipe>),
      Recipe,
      PrefetchHooks Function()
    >;
typedef $$RecipeIngredientsTableCreateCompanionBuilder =
    RecipeIngredientsCompanion Function({
      Value<int> id,
      required int recipeId,
      required int foodId,
      required double grams,
      required int orderIndex,
    });
typedef $$RecipeIngredientsTableUpdateCompanionBuilder =
    RecipeIngredientsCompanion Function({
      Value<int> id,
      Value<int> recipeId,
      Value<int> foodId,
      Value<double> grams,
      Value<int> orderIndex,
    });

class $$RecipeIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecipeIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipeIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<int> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => column);

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );
}

class $$RecipeIngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeIngredientsTable,
          RecipeIngredient,
          $$RecipeIngredientsTableFilterComposer,
          $$RecipeIngredientsTableOrderingComposer,
          $$RecipeIngredientsTableAnnotationComposer,
          $$RecipeIngredientsTableCreateCompanionBuilder,
          $$RecipeIngredientsTableUpdateCompanionBuilder,
          (
            RecipeIngredient,
            BaseReferences<
              _$AppDatabase,
              $RecipeIngredientsTable,
              RecipeIngredient
            >,
          ),
          RecipeIngredient,
          PrefetchHooks Function()
        > {
  $$RecipeIngredientsTableTableManager(
    _$AppDatabase db,
    $RecipeIngredientsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeIngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeIngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeIngredientsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> recipeId = const Value.absent(),
                Value<int> foodId = const Value.absent(),
                Value<double> grams = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
              }) => RecipeIngredientsCompanion(
                id: id,
                recipeId: recipeId,
                foodId: foodId,
                grams: grams,
                orderIndex: orderIndex,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int recipeId,
                required int foodId,
                required double grams,
                required int orderIndex,
              }) => RecipeIngredientsCompanion.insert(
                id: id,
                recipeId: recipeId,
                foodId: foodId,
                grams: grams,
                orderIndex: orderIndex,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecipeIngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeIngredientsTable,
      RecipeIngredient,
      $$RecipeIngredientsTableFilterComposer,
      $$RecipeIngredientsTableOrderingComposer,
      $$RecipeIngredientsTableAnnotationComposer,
      $$RecipeIngredientsTableCreateCompanionBuilder,
      $$RecipeIngredientsTableUpdateCompanionBuilder,
      (
        RecipeIngredient,
        BaseReferences<
          _$AppDatabase,
          $RecipeIngredientsTable,
          RecipeIngredient
        >,
      ),
      RecipeIngredient,
      PrefetchHooks Function()
    >;
typedef $$DiaryEntriesTableCreateCompanionBuilder =
    DiaryEntriesCompanion Function({
      Value<int> id,
      required DateTime date,
      required MealType mealType,
      Value<int?> foodId,
      Value<int?> recipeId,
      Value<double?> quantityGrams,
      Value<double?> servings,
      required int orderIndex,
      required double kcal,
      required double proteinG,
      required double carbsG,
      required double fatG,
      Value<DateTime> createdAt,
    });
typedef $$DiaryEntriesTableUpdateCompanionBuilder =
    DiaryEntriesCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<MealType> mealType,
      Value<int?> foodId,
      Value<int?> recipeId,
      Value<double?> quantityGrams,
      Value<double?> servings,
      Value<int> orderIndex,
      Value<double> kcal,
      Value<double> proteinG,
      Value<double> carbsG,
      Value<double> fatG,
      Value<DateTime> createdAt,
    });

class $$DiaryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MealType, MealType, int> get mealType =>
      $composableBuilder(
        column: $table.mealType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantityGrams => $composableBuilder(
    column: $table.quantityGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DiaryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantityGrams => $composableBuilder(
    column: $table.quantityGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DiaryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MealType, int> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<int> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => column);

  GeneratedColumn<int> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<double> get quantityGrams => $composableBuilder(
    column: $table.quantityGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get servings =>
      $composableBuilder(column: $table.servings, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<double> get proteinG =>
      $composableBuilder(column: $table.proteinG, builder: (column) => column);

  GeneratedColumn<double> get carbsG =>
      $composableBuilder(column: $table.carbsG, builder: (column) => column);

  GeneratedColumn<double> get fatG =>
      $composableBuilder(column: $table.fatG, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DiaryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DiaryEntriesTable,
          DiaryEntry,
          $$DiaryEntriesTableFilterComposer,
          $$DiaryEntriesTableOrderingComposer,
          $$DiaryEntriesTableAnnotationComposer,
          $$DiaryEntriesTableCreateCompanionBuilder,
          $$DiaryEntriesTableUpdateCompanionBuilder,
          (
            DiaryEntry,
            BaseReferences<_$AppDatabase, $DiaryEntriesTable, DiaryEntry>,
          ),
          DiaryEntry,
          PrefetchHooks Function()
        > {
  $$DiaryEntriesTableTableManager(_$AppDatabase db, $DiaryEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiaryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiaryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiaryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<MealType> mealType = const Value.absent(),
                Value<int?> foodId = const Value.absent(),
                Value<int?> recipeId = const Value.absent(),
                Value<double?> quantityGrams = const Value.absent(),
                Value<double?> servings = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<double> kcal = const Value.absent(),
                Value<double> proteinG = const Value.absent(),
                Value<double> carbsG = const Value.absent(),
                Value<double> fatG = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DiaryEntriesCompanion(
                id: id,
                date: date,
                mealType: mealType,
                foodId: foodId,
                recipeId: recipeId,
                quantityGrams: quantityGrams,
                servings: servings,
                orderIndex: orderIndex,
                kcal: kcal,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required MealType mealType,
                Value<int?> foodId = const Value.absent(),
                Value<int?> recipeId = const Value.absent(),
                Value<double?> quantityGrams = const Value.absent(),
                Value<double?> servings = const Value.absent(),
                required int orderIndex,
                required double kcal,
                required double proteinG,
                required double carbsG,
                required double fatG,
                Value<DateTime> createdAt = const Value.absent(),
              }) => DiaryEntriesCompanion.insert(
                id: id,
                date: date,
                mealType: mealType,
                foodId: foodId,
                recipeId: recipeId,
                quantityGrams: quantityGrams,
                servings: servings,
                orderIndex: orderIndex,
                kcal: kcal,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DiaryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DiaryEntriesTable,
      DiaryEntry,
      $$DiaryEntriesTableFilterComposer,
      $$DiaryEntriesTableOrderingComposer,
      $$DiaryEntriesTableAnnotationComposer,
      $$DiaryEntriesTableCreateCompanionBuilder,
      $$DiaryEntriesTableUpdateCompanionBuilder,
      (
        DiaryEntry,
        BaseReferences<_$AppDatabase, $DiaryEntriesTable, DiaryEntry>,
      ),
      DiaryEntry,
      PrefetchHooks Function()
    >;
typedef $$BodyWeightLogsTableCreateCompanionBuilder =
    BodyWeightLogsCompanion Function({
      Value<int> id,
      required DateTime date,
      required double weightKg,
      Value<String?> notes,
    });
typedef $$BodyWeightLogsTableUpdateCompanionBuilder =
    BodyWeightLogsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<double> weightKg,
      Value<String?> notes,
    });

class $$BodyWeightLogsTableFilterComposer
    extends Composer<_$AppDatabase, $BodyWeightLogsTable> {
  $$BodyWeightLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BodyWeightLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $BodyWeightLogsTable> {
  $$BodyWeightLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BodyWeightLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BodyWeightLogsTable> {
  $$BodyWeightLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$BodyWeightLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BodyWeightLogsTable,
          BodyWeightLog,
          $$BodyWeightLogsTableFilterComposer,
          $$BodyWeightLogsTableOrderingComposer,
          $$BodyWeightLogsTableAnnotationComposer,
          $$BodyWeightLogsTableCreateCompanionBuilder,
          $$BodyWeightLogsTableUpdateCompanionBuilder,
          (
            BodyWeightLog,
            BaseReferences<_$AppDatabase, $BodyWeightLogsTable, BodyWeightLog>,
          ),
          BodyWeightLog,
          PrefetchHooks Function()
        > {
  $$BodyWeightLogsTableTableManager(
    _$AppDatabase db,
    $BodyWeightLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodyWeightLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodyWeightLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BodyWeightLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => BodyWeightLogsCompanion(
                id: id,
                date: date,
                weightKg: weightKg,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required double weightKg,
                Value<String?> notes = const Value.absent(),
              }) => BodyWeightLogsCompanion.insert(
                id: id,
                date: date,
                weightKg: weightKg,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BodyWeightLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BodyWeightLogsTable,
      BodyWeightLog,
      $$BodyWeightLogsTableFilterComposer,
      $$BodyWeightLogsTableOrderingComposer,
      $$BodyWeightLogsTableAnnotationComposer,
      $$BodyWeightLogsTableCreateCompanionBuilder,
      $$BodyWeightLogsTableUpdateCompanionBuilder,
      (
        BodyWeightLog,
        BaseReferences<_$AppDatabase, $BodyWeightLogsTable, BodyWeightLog>,
      ),
      BodyWeightLog,
      PrefetchHooks Function()
    >;
typedef $$BurnedCaloriesTableCreateCompanionBuilder =
    BurnedCaloriesCompanion Function({
      Value<int> id,
      required DateTime date,
      required double kcal,
      Value<String?> label,
      Value<BurnedCalorieSource> source,
      Value<DateTime> createdAt,
    });
typedef $$BurnedCaloriesTableUpdateCompanionBuilder =
    BurnedCaloriesCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<double> kcal,
      Value<String?> label,
      Value<BurnedCalorieSource> source,
      Value<DateTime> createdAt,
    });

class $$BurnedCaloriesTableFilterComposer
    extends Composer<_$AppDatabase, $BurnedCaloriesTable> {
  $$BurnedCaloriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BurnedCalorieSource, BurnedCalorieSource, int>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BurnedCaloriesTableOrderingComposer
    extends Composer<_$AppDatabase, $BurnedCaloriesTable> {
  $$BurnedCaloriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BurnedCaloriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BurnedCaloriesTable> {
  $$BurnedCaloriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BurnedCalorieSource, int> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BurnedCaloriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BurnedCaloriesTable,
          BurnedCalory,
          $$BurnedCaloriesTableFilterComposer,
          $$BurnedCaloriesTableOrderingComposer,
          $$BurnedCaloriesTableAnnotationComposer,
          $$BurnedCaloriesTableCreateCompanionBuilder,
          $$BurnedCaloriesTableUpdateCompanionBuilder,
          (
            BurnedCalory,
            BaseReferences<_$AppDatabase, $BurnedCaloriesTable, BurnedCalory>,
          ),
          BurnedCalory,
          PrefetchHooks Function()
        > {
  $$BurnedCaloriesTableTableManager(
    _$AppDatabase db,
    $BurnedCaloriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BurnedCaloriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BurnedCaloriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BurnedCaloriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> kcal = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<BurnedCalorieSource> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BurnedCaloriesCompanion(
                id: id,
                date: date,
                kcal: kcal,
                label: label,
                source: source,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required double kcal,
                Value<String?> label = const Value.absent(),
                Value<BurnedCalorieSource> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BurnedCaloriesCompanion.insert(
                id: id,
                date: date,
                kcal: kcal,
                label: label,
                source: source,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BurnedCaloriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BurnedCaloriesTable,
      BurnedCalory,
      $$BurnedCaloriesTableFilterComposer,
      $$BurnedCaloriesTableOrderingComposer,
      $$BurnedCaloriesTableAnnotationComposer,
      $$BurnedCaloriesTableCreateCompanionBuilder,
      $$BurnedCaloriesTableUpdateCompanionBuilder,
      (
        BurnedCalory,
        BaseReferences<_$AppDatabase, $BurnedCaloriesTable, BurnedCalory>,
      ),
      BurnedCalory,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfileTableTableManager get userProfile =>
      $$UserProfileTableTableManager(_db, _db.userProfile);
  $$FoodsTableTableManager get foods =>
      $$FoodsTableTableManager(_db, _db.foods);
  $$RecipesTableTableManager get recipes =>
      $$RecipesTableTableManager(_db, _db.recipes);
  $$RecipeIngredientsTableTableManager get recipeIngredients =>
      $$RecipeIngredientsTableTableManager(_db, _db.recipeIngredients);
  $$DiaryEntriesTableTableManager get diaryEntries =>
      $$DiaryEntriesTableTableManager(_db, _db.diaryEntries);
  $$BodyWeightLogsTableTableManager get bodyWeightLogs =>
      $$BodyWeightLogsTableTableManager(_db, _db.bodyWeightLogs);
  $$BurnedCaloriesTableTableManager get burnedCalories =>
      $$BurnedCaloriesTableTableManager(_db, _db.burnedCalories);
}
