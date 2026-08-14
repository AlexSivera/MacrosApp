import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/user_profile_table.dart';

part 'user_profile_dao.g.dart';

// Single-row table: the app only ever reads/writes the row with id = 1.
@DriftAccessor(tables: [UserProfile])
class UserProfileDao extends DatabaseAccessor<AppDatabase> with _$UserProfileDaoMixin {
  UserProfileDao(super.db);

  Future<void> ensureDefaultRow() async {
    final existing = await select(userProfile).getSingleOrNull();
    if (existing == null) {
      await into(userProfile).insert(const UserProfileCompanion());
    }
  }

  Stream<UserProfileData?> watchProfile() {
    return (select(userProfile)..limit(1)).watchSingleOrNull();
  }

  Future<UserProfileData?> getProfile() => select(userProfile).getSingleOrNull();

  Future<bool> isOnboardingCompleted() async {
    final existing = await select(userProfile).getSingleOrNull();
    return existing?.onboardingCompleted ?? false;
  }

  Future<void> updateProfile(UserProfileCompanion entry) async {
    final existing = await select(userProfile).getSingleOrNull();
    if (existing == null) {
      await into(userProfile).insert(entry);
    } else {
      await (update(userProfile)..where((p) => p.id.equals(existing.id))).write(entry);
    }
  }
}
