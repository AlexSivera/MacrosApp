import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';

final foodSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

// null = "Todos" — no category filter applied.
final foodCategoryFilterProvider = StateProvider.autoDispose<FoodCategory?>((ref) => null);

final foodSearchResultsProvider = StreamProvider.autoDispose<List<Food>>((ref) {
  final query = ref.watch(foodSearchQueryProvider);
  final category = ref.watch(foodCategoryFilterProvider);
  final foodsDao = ref.watch(appDatabaseProvider).foodsDao;
  return foodsDao.watchFiltered(query: query, category: category);
});

typedef FoodShortcuts = ({List<Food> frequent, List<Food> recent});

// The shortcuts at the top of an unfiltered search: the foods usually eaten
// in the meal being filled ("Frecuentes en Desayuno" — only when a meal is
// known), then the foods logged or planned most recently, newest first,
// without repeating the frequent ones.
final foodShortcutsProvider =
    FutureProvider.autoDispose.family<FoodShortcuts, MealType?>((ref, mealType) async {
  final db = ref.watch(appDatabaseProvider);
  final frequentIds = mealType == null ? const <int>[] : await db.mealPlanDao.frequentFoodIds(mealType);
  final recentIds = (await db.mealPlanDao.recentFoodIds()).where((id) => !frequentIds.contains(id));
  Future<List<Food>> load(Iterable<int> ids) async =>
      (await Future.wait(ids.map(db.foodsDao.getById))).nonNulls.toList();
  return (frequent: await load(frequentIds), recent: await load(recentIds));
});
