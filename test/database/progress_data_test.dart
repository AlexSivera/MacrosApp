import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/data/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('watchInRange only returns logs within [start, end]', () async {
    await db.bodyWeightDao.insertLog(BodyWeightLogsCompanion.insert(
      date: DateTime(2026, 1, 1),
      weightKg: 85,
    ));
    await db.bodyWeightDao.insertLog(BodyWeightLogsCompanion.insert(
      date: DateTime(2026, 6, 1),
      weightKg: 80,
    ));
    await db.bodyWeightDao.insertLog(BodyWeightLogsCompanion.insert(
      date: DateTime(2026, 8, 1),
      weightKg: 78,
    ));

    final julyOnward = await db.bodyWeightDao
        .watchInRange(DateTime(2026, 7, 1), DateTime(2026, 12, 31))
        .first;
    expect(julyOnward, hasLength(1));
    expect(julyOnward.first.weightKg, 78);
  });

  test('earliest returns the first-ever logged weight regardless of range', () async {
    await db.bodyWeightDao.insertLog(BodyWeightLogsCompanion.insert(
      date: DateTime(2026, 3, 15),
      weightKg: 90,
    ));
    await db.bodyWeightDao.insertLog(BodyWeightLogsCompanion.insert(
      date: DateTime(2026, 8, 1),
      weightKg: 82,
    ));
    final earliest = await db.bodyWeightDao.earliest();
    expect(earliest!.weightKg, 90);
  });

  test('watchLatest returns the most recently dated log, not the most recently inserted', () async {
    await db.bodyWeightDao.insertLog(BodyWeightLogsCompanion.insert(
      date: DateTime(2026, 8, 10),
      weightKg: 79,
    ));
    // Inserted after, but dated earlier — watchLatest must still prefer the later date.
    await db.bodyWeightDao.insertLog(BodyWeightLogsCompanion.insert(
      date: DateTime(2026, 8, 5),
      weightKg: 81,
    ));
    final latest = await db.bodyWeightDao.watchLatest().first;
    expect(latest!.weightKg, 79);
  });

  test('diary entries in range sum correctly for an average-macros calculation', () async {
    final foodId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Avena',
      kcalPer100g: 389,
      proteinPer100g: 17,
      carbsPer100g: 66,
      fatPer100g: 7,
    ));
    for (final day in [1, 2, 3]) {
      await db.diaryDao.logFood(
        date: DateTime(2026, 8, day),
        mealType: MealType.breakfast,
        foodId: foodId,
        quantityGrams: 100,
        orderIndex: 0,
        kcal: 389,
        proteinG: 17,
        carbsG: 66,
        fatG: 7,
      );
    }
    final entries = await db.diaryDao.watchEntriesInRange(DateTime(2026, 8, 1), DateTime(2026, 8, 7)).first;
    expect(entries, hasLength(3));
    final totalKcal = entries.fold(0.0, (sum, e) => sum + e.kcal);
    expect(totalKcal, closeTo(1167, 0.01));
    // Averaged over the full 7-day range (not just the 3 tracked days).
    expect(totalKcal / 7, closeTo(166.7, 0.1));
  });
}
