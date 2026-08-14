import 'package:drift/drift.dart';

import '../enums.dart';

class BurnedCalories extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  RealColumn get kcal => real()();
  TextColumn get label => text().nullable()();
  IntColumn get source =>
      intEnum<BurnedCalorieSource>().withDefault(Constant(BurnedCalorieSource.manual.index))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
