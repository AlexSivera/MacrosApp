import 'package:drift/drift.dart';

import '../../../services/nutrition_engine/meal_plan_macros_calculator.dart';
import '../app_database.dart';
import '../tables/foods_table.dart';
import '../tables/meal_plan_entries_table.dart';
import '../tables/recipes_table.dart';

part 'meal_plan_dao.g.dart';

// A plan row plus the display name of whichever food/recipe it points to —
// resolved via a left join since exactly one of foodId/recipeId is set.
// Falls back to the name snapshotted when the entry was eaten, so an eaten
// entry whose food was later deleted still reads as what it was.
class MealPlanEntryDisplay {
  MealPlanEntryDisplay({required this.entry, required this.label});

  final MealPlanEntry entry;
  final String label;
}

@DriftAccessor(tables: [MealPlanEntries, Foods, Recipes])
class MealPlanDao extends DatabaseAccessor<AppDatabase> with _$MealPlanDaoMixin {
  MealPlanDao(super.db);

  static DateTime normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  List<MealPlanEntryDisplay> _toDisplays(List<TypedResult> rows) => [
        for (final row in rows)
          MealPlanEntryDisplay(
            entry: row.readTable(mealPlanEntries),
            label: row.readTableOrNull(foods)?.name ??
                row.readTableOrNull(recipes)?.name ??
                row.readTable(mealPlanEntries).labelSnapshot ??
                'Alimento eliminado',
          ),
      ];

  JoinedSelectStatement<HasResultSet, dynamic> _joined() => select(mealPlanEntries).join([
        leftOuterJoin(foods, foods.id.equalsExp(mealPlanEntries.foodId)),
        leftOuterJoin(recipes, recipes.id.equalsExp(mealPlanEntries.recipeId)),
      ]);

  Stream<List<MealPlanEntryDisplay>> watchEntriesForDate(DateTime date) {
    final day = normalizeDate(date);
    final query = _joined()
      ..where(mealPlanEntries.date.equals(day))
      ..orderBy([OrderingTerm.asc(mealPlanEntries.orderIndex)]);
    return query.watch().map(_toDisplays);
  }

  // Backs both the weekly planner grid and the monthly overview.
  Stream<List<MealPlanEntryDisplay>> watchEntriesInRange(
    DateTime start,
    DateTime end, {
    bool eatenOnly = false,
  }) {
    var filter = mealPlanEntries.date.isBiggerOrEqualValue(normalizeDate(start)) &
        mealPlanEntries.date.isSmallerOrEqualValue(normalizeDate(end));
    if (eatenOnly) filter = filter & mealPlanEntries.isEaten.equals(true);
    final query = _joined()
      ..where(filter)
      ..orderBy([
        OrderingTerm.asc(mealPlanEntries.date),
        OrderingTerm.asc(mealPlanEntries.orderIndex),
      ]);
    return query.watch().map(_toDisplays);
  }

  Future<MealPlanEntry?> getById(int id) =>
      (select(mealPlanEntries)..where((e) => e.id.equals(id))).getSingleOrNull();

  // eaten: true when added from the Diario (it's being logged, not planned)
  // — the entry is snapshotted straight away via markEaten().
  Future<int> addFood({
    required DateTime date,
    required MealType mealType,
    required int foodId,
    required double quantityGrams,
    required int orderIndex,
    bool eaten = false,
  }) async {
    final id = await into(mealPlanEntries).insert(MealPlanEntriesCompanion.insert(
      date: normalizeDate(date),
      mealType: mealType,
      foodId: Value(foodId),
      quantityGrams: Value(quantityGrams),
      orderIndex: orderIndex,
    ));
    if (eaten) await markEaten(id);
    return id;
  }

  Future<int> addRecipe({
    required DateTime date,
    required MealType mealType,
    required int recipeId,
    required double servings,
    required int orderIndex,
    bool eaten = false,
  }) async {
    final id = await into(mealPlanEntries).insert(MealPlanEntriesCompanion.insert(
      date: normalizeDate(date),
      mealType: mealType,
      recipeId: Value(recipeId),
      servings: Value(servings),
      orderIndex: orderIndex,
    ));
    if (eaten) await markEaten(id);
    return id;
  }

  // Freezes the entry's current live macros and name onto it — from here
  // on, edits to the underlying food/recipe no longer change this entry.
  Future<void> markEaten(int entryId) async {
    final entry = await getById(entryId);
    if (entry == null) return;
    // Its food/recipe was deleted: the existing snapshot is all that is left
    // of it, so never overwrite that with zeros. Checked by lookup, not by
    // a null FK — SQLite doesn't reliably apply the setNull action here.
    final exists = entry.foodId != null
        ? await attachedDatabase.foodsDao.getById(entry.foodId!) != null
        : entry.recipeId != null && await attachedDatabase.recipesDao.getById(entry.recipeId!) != null;
    if (!exists) {
      if (!entry.isEaten) {
        await (update(mealPlanEntries)..where((e) => e.id.equals(entryId)))
            .write(const MealPlanEntriesCompanion(isEaten: Value(true)));
      }
      return;
    }
    final macros = await resolveLiveEntryMacros(attachedDatabase, entry);
    final label = await _liveLabel(entry);
    await (update(mealPlanEntries)..where((e) => e.id.equals(entryId))).write(
      MealPlanEntriesCompanion(
        isEaten: const Value(true),
        kcal: Value(macros.kcal),
        proteinG: Value(macros.proteinG),
        carbsG: Value(macros.carbsG),
        fatG: Value(macros.fatG),
        labelSnapshot: Value(label),
      ),
    );
  }

  // Back to "planned": drops the snapshot so it tracks the live food again.
  Future<void> markPlanned(int entryId) async {
    await (update(mealPlanEntries)..where((e) => e.id.equals(entryId))).write(
      const MealPlanEntriesCompanion(
        isEaten: Value(false),
        kcal: Value(null),
        proteinG: Value(null),
        carbsG: Value(null),
        fatG: Value(null),
      ),
    );
  }

  Future<String?> _liveLabel(MealPlanEntry entry) async {
    if (entry.foodId != null) return (await attachedDatabase.foodsDao.getById(entry.foodId!))?.name ?? entry.labelSnapshot;
    if (entry.recipeId != null) {
      return (await attachedDatabase.recipesDao.getById(entry.recipeId!))?.name ??
          entry.labelSnapshot;
    }
    return entry.labelSnapshot;
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

  // Changing an eaten entry's quantity re-snapshots it at the new amount —
  // the user is correcting what they ate, not editing the food.
  Future<void> updateEntryQuantity(int entryId, {double? quantityGrams, double? servings}) async {
    await (update(mealPlanEntries)..where((e) => e.id.equals(entryId))).write(
      MealPlanEntriesCompanion(
        quantityGrams: quantityGrams != null ? Value(quantityGrams) : const Value.absent(),
        servings: servings != null ? Value(servings) : const Value.absent(),
      ),
    );
    final entry = await getById(entryId);
    if (entry != null && entry.isEaten) await markEaten(entryId);
  }

  Future<int> deleteEntry(int id) =>
      (delete(mealPlanEntries)..where((e) => e.id.equals(id))).go();

  // "Deshacer" after a delete: puts the exact same row (same id, snapshot
  // and all) back.
  Future<void> restoreEntry(MealPlanEntry entry) =>
      into(mealPlanEntries).insert(entry, mode: InsertMode.insertOrReplace);

  // Most recently logged/planned distinct foods, newest first — the
  // "Recientes" shortcut at the top of the food search.
  Future<List<int>> recentFoodIds({int limit = 8}) async {
    final rows = await (select(mealPlanEntries)
          ..where((e) => e.foodId.isNotNull())
          ..orderBy([(e) => OrderingTerm.desc(e.id)])
          ..limit(200))
        .get();
    final ids = <int>[];
    for (final row in rows) {
      if (!ids.contains(row.foodId)) ids.add(row.foodId!);
      if (ids.length == limit) break;
    }
    return ids;
  }

  // The grams used the last time this food was logged or planned, if ever.
  Future<double?> lastFoodQuantityGrams(int foodId) async {
    final row = await (select(mealPlanEntries)
          ..where((e) => e.foodId.equals(foodId) & e.quantityGrams.isNotNull())
          ..orderBy([(e) => OrderingTerm.desc(e.id)])
          ..limit(1))
        .getSingleOrNull();
    return row?.quantityGrams;
  }

  // The foods used most often in one meal slot ("Frecuentes en Desayuno"),
  // counted over that slot's latest 300 entries so old habits fade out. Ties
  // go to the most recently used; foods used only once aren't habits yet.
  Future<List<int>> frequentFoodIds(MealType mealType, {int limit = 5, int minUses = 2}) async {
    final rows = await (select(mealPlanEntries)
          ..where((e) => e.foodId.isNotNull() & e.mealType.equalsValue(mealType))
          ..orderBy([(e) => OrderingTerm.desc(e.id)])
          ..limit(300))
        .get();
    // Insertion order = most recent first, which breaks count ties below.
    final counts = <int, int>{};
    for (final row in rows) {
      counts.update(row.foodId!, (n) => n + 1, ifAbsent: () => 1);
    }
    final ids = counts.keys.where((id) => counts[id]! >= minUses).toList();
    final recency = {for (final (i, id) in counts.keys.indexed) id: i};
    ids.sort((a, b) {
      final byCount = counts[b]!.compareTo(counts[a]!);
      return byCount != 0 ? byCount : recency[a]!.compareTo(recency[b]!);
    });
    return ids.take(limit).toList();
  }

  // "Repetir de ayer": copies every entry of one meal slot onto another day.
  // Returns how many entries were copied (0 if the source slot was empty).
  Future<int> copyMeal({
    required DateTime fromDate,
    required DateTime toDate,
    required MealType mealType,
    required bool eaten,
  }) async {
    final source = await (select(mealPlanEntries)
          ..where((e) =>
              e.date.equals(normalizeDate(fromDate)) & e.mealType.equalsValue(mealType))
          ..orderBy([(e) => OrderingTerm.asc(e.orderIndex)]))
        .get();
    var orderIndex = await nextOrderIndex(toDate, mealType);
    var copied = 0;
    await transaction(() async {
      for (final entry in source) {
        if (entry.foodId == null && entry.recipeId == null) continue;
        final id = await into(mealPlanEntries).insert(MealPlanEntriesCompanion.insert(
          date: normalizeDate(toDate),
          mealType: mealType,
          foodId: Value(entry.foodId),
          recipeId: Value(entry.recipeId),
          quantityGrams: Value(entry.quantityGrams),
          servings: Value(entry.servings),
          orderIndex: orderIndex++,
        ));
        if (eaten) await markEaten(id);
        copied++;
      }
    });
    return copied;
  }

  // One-off backfill for the v8 migration: every entry up to today counts
  // as eaten (that's what the merged Diario/Plan showed as consumed before
  // the planned/eaten split existed), snapshotted from today's live values.
  Future<void> backfillEatenUpTo(DateTime day) async {
    final rows = await (select(mealPlanEntries)
          ..where((e) => e.date.isSmallerOrEqualValue(normalizeDate(day))))
        .get();
    for (final row in rows) {
      await markEaten(row.id);
    }
  }
}
