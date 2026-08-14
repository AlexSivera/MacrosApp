// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'burned_calories_dao.dart';

// ignore_for_file: type=lint
mixin _$BurnedCaloriesDaoMixin on DatabaseAccessor<AppDatabase> {
  $BurnedCaloriesTable get burnedCalories => attachedDatabase.burnedCalories;
  BurnedCaloriesDaoManager get managers => BurnedCaloriesDaoManager(this);
}

class BurnedCaloriesDaoManager {
  final _$BurnedCaloriesDaoMixin _db;
  BurnedCaloriesDaoManager(this._db);
  $$BurnedCaloriesTableTableManager get burnedCalories =>
      $$BurnedCaloriesTableTableManager(
        _db.attachedDatabase,
        _db.burnedCalories,
      );
}
