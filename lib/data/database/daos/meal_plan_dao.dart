import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/foods_table.dart';
import '../tables/meal_plan_entries_table.dart';
import '../tables/recipes_table.dart';

part 'meal_plan_dao.g.dart';

// A plan row plus the display name of whichever food/recipe it points to —
// resolved via a left join since exactly one of foodId/recipeId is set.
class MealPlanEntryDisplay {
  MealPlanEntryDisplay({required this.entry, required this.label});

  final MealPlanEntry entry;
  final String label;
}

@DriftAccessor(tables: [MealPlanEntries, Foods, Recipes])
class MealPlanDao extends DatabaseAccessor<AppDatabase> with _$MealPlanDaoMixin {
  MealPlanDao(super.db);

  static DateTime normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  Stream<List<MealPlanEntryDisplay>> watchEntriesForDate(DateTime date) {
    final day = normalizeDate(date);
    final query = select(mealPlanEntries).join([
      leftOuterJoin(foods, foods.id.equalsExp(mealPlanEntries.foodId)),
      leftOuterJoin(recipes, recipes.id.equalsExp(mealPlanEntries.recipeId)),
    ])
      ..where(mealPlanEntries.date.equals(day))
      ..orderBy([OrderingTerm.asc(mealPlanEntries.orderIndex)]);

    return query.watch().map((rows) => [
          for (final row in rows)
            MealPlanEntryDisplay(
              entry: row.readTable(mealPlanEntries),
              label: row.readTableOrNull(foods)?.name ??
                  row.readTableOrNull(recipes)?.name ??
                  'Alimento eliminado',
            ),
        ]);
  }

  // Backs both the weekly planner grid and the monthly overview.
  Stream<List<MealPlanEntryDisplay>> watchEntriesInRange(DateTime start, DateTime end) {
    final query = select(mealPlanEntries).join([
      leftOuterJoin(foods, foods.id.equalsExp(mealPlanEntries.foodId)),
      leftOuterJoin(recipes, recipes.id.equalsExp(mealPlanEntries.recipeId)),
    ])
      ..where(mealPlanEntries.date.isBiggerOrEqualValue(normalizeDate(start)) &
          mealPlanEntries.date.isSmallerOrEqualValue(normalizeDate(end)))
      ..orderBy([
        OrderingTerm.asc(mealPlanEntries.date),
        OrderingTerm.asc(mealPlanEntries.orderIndex),
      ]);

    return query.watch().map((rows) => [
          for (final row in rows)
            MealPlanEntryDisplay(
              entry: row.readTable(mealPlanEntries),
              label: row.readTableOrNull(foods)?.name ??
                  row.readTableOrNull(recipes)?.name ??
                  'Alimento eliminado',
            ),
        ]);
  }

  Future<int> addFood({
    required DateTime date,
    required MealType mealType,
    required int foodId,
    required double quantityGrams,
    required int orderIndex,
  }) {
    return into(mealPlanEntries).insert(MealPlanEntriesCompanion.insert(
      date: normalizeDate(date),
      mealType: mealType,
      foodId: Value(foodId),
      quantityGrams: Value(quantityGrams),
      orderIndex: orderIndex,
    ));
  }

  Future<int> addRecipe({
    required DateTime date,
    required MealType mealType,
    required int recipeId,
    required double servings,
    required int orderIndex,
  }) {
    return into(mealPlanEntries).insert(MealPlanEntriesCompanion.insert(
      date: normalizeDate(date),
      mealType: mealType,
      recipeId: Value(recipeId),
      servings: Value(servings),
      orderIndex: orderIndex,
    ));
  }

  Future<int> nextOrderIndex(DateTime date, MealType mealType) async {
    final day = normalizeDate(date);
    final rows = await (select(mealPlanEntries)
          ..where((e) => e.date.equals(day) & e.mealType.equalsValue(mealType)))
        .get();
    if (rows.isEmpty) return 0;
    return rows.map((e) => e.orderIndex).reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<void> moveEntry(int entryId, {DateTime? newDate, MealType? newMealType}) async {
    await (update(mealPlanEntries)..where((e) => e.id.equals(entryId))).write(
      MealPlanEntriesCompanion(
        date: newDate != null ? Value(normalizeDate(newDate)) : const Value.absent(),
        mealType: newMealType != null ? Value(newMealType) : const Value.absent(),
      ),
    );
  }

  Future<void> updateEntryQuantity(int entryId, {double? quantityGrams, double? servings}) async {
    await (update(mealPlanEntries)..where((e) => e.id.equals(entryId))).write(
      MealPlanEntriesCompanion(
        quantityGrams: quantityGrams != null ? Value(quantityGrams) : const Value.absent(),
        servings: servings != null ? Value(servings) : const Value.absent(),
      ),
    );
  }

  Future<int> deleteEntry(int id) =>
      (delete(mealPlanEntries)..where((e) => e.id.equals(id))).go();
}
