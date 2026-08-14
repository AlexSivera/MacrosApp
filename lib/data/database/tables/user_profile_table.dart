import 'package:drift/drift.dart';

import '../enums.dart';

// Single-row table: the app only ever reads/writes the row with id = 1,
// created by ensureDefaultRow() on first launch.
class UserProfile extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().nullable()();
  IntColumn get sex => intEnum<BiologicalSex>().nullable()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  RealColumn get heightCm => real().nullable()();

  IntColumn get activityLevel =>
      intEnum<ActivityLevel>().withDefault(Constant(ActivityLevel.moderate.index))();
  IntColumn get goalType => intEnum<GoalType>().withDefault(Constant(GoalType.maintain.index))();
  // kg/week the user wants to gain or lose; sign follows goalType. 0 for maintain.
  RealColumn get weeklyWeightChangeKg => real().withDefault(const Constant(0))();
  RealColumn get startingWeightKg => real().nullable()();
  RealColumn get goalWeightKg => real().nullable()();

  IntColumn get calorieTargetMode =>
      intEnum<CalorieTargetMode>().withDefault(Constant(CalorieTargetMode.automatic.index))();
  IntColumn get manualCalorieTarget => integer().nullable()();
  RealColumn get proteinGramsPerKg => real().withDefault(const Constant(1.8))();
  RealColumn get fatPercentOfCalories => real().withDefault(const Constant(0.28))();
  RealColumn get manualProteinTargetG => real().nullable()();
  RealColumn get manualCarbTargetG => real().nullable()();
  RealColumn get manualFatTargetG => real().nullable()();

  IntColumn get weightUnit => intEnum<WeightUnit>().withDefault(Constant(WeightUnit.kg.index))();
  IntColumn get foodMassUnit =>
      intEnum<FoodMassUnit>().withDefault(Constant(FoodMassUnit.g.index))();
  IntColumn get appearanceMode =>
      intEnum<AppearanceMode>().withDefault(Constant(AppearanceMode.dark.index))();

  BoolColumn get remindersEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get onboardingCompleted => boolean().withDefault(const Constant(false))();
}
