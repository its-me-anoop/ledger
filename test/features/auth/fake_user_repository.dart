import 'package:ledger/features/profile/domain/models/user_profile.dart';
import 'package:ledger/features/profile/domain/user_repository.dart';

class FakeUserRepository implements UserRepository {
  final List<String> upsertCalls = [];
  final List<String> updateNameCalls = [];

  @override
  Stream<UserProfile?> watchUser(String uid) => Stream.value(null);

  @override
  Future<void> upsertUser(UserProfile profile) async {
    upsertCalls.add(profile.uid);
  }

  @override
  Future<void> updateDisplayName(String uid, String name) async {
    updateNameCalls.add('$uid:$name');
  }
}
