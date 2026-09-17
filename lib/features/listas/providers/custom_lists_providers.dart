import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';

final customListsProvider = StreamProvider<List<CustomList>>((ref) {
  return ref.watch(appDatabaseProvider).customListsDao.watchLists();
});

// `.family` keyed by listId is safe here (unlike the shopping list's own
// providers) because listId is a route param fixed for the lifetime of
// CustomListDetailScreen — it never changes while the screen stays mounted,
// so there's no churn for `.autoDispose` to mishandle.
final customListItemsProvider = StreamProvider.autoDispose.family<List<CustomListItem>, int>(
  (ref, listId) => ref.watch(appDatabaseProvider).customListsDao.watchItems(listId),
);
