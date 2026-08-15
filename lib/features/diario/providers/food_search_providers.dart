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
