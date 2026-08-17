import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/diary_entries_table.dart';
import '../tables/foods_table.dart';
import '../tables/recipes_table.dart';

part 'diary_dao.g.dart';

// A diary row plus the display name of whichever food/recipe it points to —
// resolved via a left join since exactly one of foodId/recipeId is set.
class DiaryEntryDisplay {
  DiaryEntryDisplay({required this.entry, required this.label});

  final DiaryEntry entry;
  final String label;
}

@DriftAccessor(tables: [DiaryEntries, Foods, Recipes])
class DiaryDao extends DatabaseAccessor<AppDatabase> with _$DiaryDaoMixin {
  DiaryDao(super.db);

  static DateTime normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  Stream<List<DiaryEntryDisplay>> watchEntriesForDate(DateTime date) {
    final day = normalizeDate(date);
    final query = select(diaryEntries).join([
      leftOuterJoin(foods, foods.id.equalsExp(diaryEntries.foodId)),
      leftOuterJoin(recipes, recipes.id.equalsExp(diaryEntries.recipeId)),
    ])
      ..where(diaryEntries.date.equals(day))
      ..orderBy([OrderingTerm.asc(diaryEntries.orderIndex)]);

    return query.watch().map((rows) => [
          for (final row in rows)
            DiaryEntryDisplay(
              entry: row.readTable(diaryEntries),
              // Falls back to a placeholder rather than '' when foodId/
              // recipeId is null with no matching row — the referenced food
              // was deleted (see FoodSearchSheet's delete action), but the
              // entry itself survives with its snapshot macros intact.
              label: row.readTableOrNull(foods)?.name ??
                  row.readTableOrNull(recipes)?.name ??
                  'Alimento eliminado',
            ),
        ]);
  }

  // Used by Progreso's average-macros card over a date range.
  Stream<List<DiaryEntry>> watchEntriesInRange(DateTime start, DateTime end) {
    return (select(diaryEntries)
          ..where((e) =>
              e.date.isBiggerOrEqualValue(normalizeDate(start)) &
              e.date.isSmallerOrEqualValue(normalizeDate(end))))
        .watch();
  }

  Future<int> logFood({
    required DateTime date,
    required MealType mealType,
    required int foodId,
    required double quantityGrams,
    required int orderIndex,
    required double kcal,
    required double proteinG,
    required double carbsG,
    required double fatG,
  }) {
    return into(diaryEntries).insert(DiaryEntriesCompanion.insert(
      date: normalizeDate(date),
      mealType: mealType,
      foodId: Value(foodId),
      quantityGrams: Value(quantityGrams),
      orderIndex: orderIndex,
      kcal: kcal,
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
    ));
  }

  Future<int> logRecipe({
    required DateTime date,
    required MealType mealType,
    required int recipeId,
    required double servings,
    required int orderIndex,
    required double kcal,
    required double proteinG,
    required double carbsG,
    required double fatG,
  }) {
    return into(diaryEntries).insert(DiaryEntriesCompanion.insert(
      date: normalizeDate(date),
      mealType: mealType,
      recipeId: Value(recipeId),
      servings: Value(servings),
      orderIndex: orderIndex,
      kcal: kcal,
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
    ));
  }

  Future<int> nextOrderIndex(DateTime date, MealType mealType) async {
    final day = normalizeDate(date);
    final rows = await (select(diaryEntries)
          ..where((e) => e.date.equals(day) & e.mealType.equalsValue(mealType)))
        .get();
    if (rows.isEmpty) return 0;
    return rows.map((e) => e.orderIndex).reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<void> moveEntryToMeal(int entryId, MealType newMealType) async {
    await (update(diaryEntries)..where((e) => e.id.equals(entryId)))
        .write(DiaryEntriesCompanion(mealType: Value(newMealType)));
  }

  // Re-snapshots the macro columns after a quantity edit — the only case
  // where a diary entry's stored macros are recomputed post-insert.
  Future<void> updateEntryQuantityAndMacros(
    int entryId, {
    double? quantityGrams,
    double? servings,
    required double kcal,
    required double proteinG,
    required double carbsG,
    required double fatG,
  }) async {
    await (update(diaryEntries)..where((e) => e.id.equals(entryId))).write(DiaryEntriesCompanion(
      quantityGrams: quantityGrams != null ? Value(quantityGrams) : const Value.absent(),
      servings: servings != null ? Value(servings) : const Value.absent(),
      kcal: Value(kcal),
      proteinG: Value(proteinG),
      carbsG: Value(carbsG),
      fatG: Value(fatG),
    ));
  }

  Future<int> deleteEntry(int id) => (delete(diaryEntries)..where((e) => e.id.equals(id))).go();
}
