import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';

final foodSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final foodSearchResultsProvider = StreamProvider.autoDispose<List<Food>>((ref) {
  final query = ref.watch(foodSearchQueryProvider);
  final foodsDao = ref.watch(appDatabaseProvider).foodsDao;
  return query.trim().isEmpty ? foodsDao.watchAll() : foodsDao.watchSearch(query);
});
