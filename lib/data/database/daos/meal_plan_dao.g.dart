// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_dao.dart';

// ignore_for_file: type=lint
mixin _$MealPlanDaoMixin on DatabaseAccessor<AppDatabase> {
  $MealPlanEntriesTable get mealPlanEntries => attachedDatabase.mealPlanEntries;
  $FoodsTable get foods => attachedDatabase.foods;
  $RecipesTable get recipes => attachedDatabase.recipes;
  MealPlanDaoManager get managers => MealPlanDaoManager(this);
}

class MealPlanDaoManager {
  final _$MealPlanDaoMixin _db;
  MealPlanDaoManager(this._db);
  $$MealPlanEntriesTableTableManager get mealPlanEntries =>
      $$MealPlanEntriesTableTableManager(
        _db.attachedDatabase,
        _db.mealPlanEntries,
      );
  $$FoodsTableTableManager get foods =>
      $$FoodsTableTableManager(_db.attachedDatabase, _db.foods);
  $$RecipesTableTableManager get recipes =>
      $$RecipesTableTableManager(_db.attachedDatabase, _db.recipes);
}
