import 'models/user_profile.dart';

abstract interface class UserRepository {
  Stream<UserProfile?> watchUser(String uid);

  /// Creates or merges the user document (idempotent).
  Future<void> upsertUser(UserProfile profile);

  /// Updates [displayName] in Firestore and [updatedAt] timestamp.
  Future<void> updateDisplayName(String uid, String name);
}
