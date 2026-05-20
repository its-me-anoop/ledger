import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/features/profile/domain/models/user_profile.dart';
import 'package:ledger/features/profile/domain/user_repository.dart';

class FakeUserRepository implements UserRepository {
  final Map<String, UserProfile> _store = {};
  final List<String> updateDisplayNameCalls = [];

  @override
  Stream<UserProfile?> watchUser(String uid) =>
      Stream.value(_store[uid]);

  @override
  Future<void> upsertUser(UserProfile profile) async {
    final existing = _store[profile.uid];
    if (existing == null) {
      // First write: store as-is including createdAt.
      _store[profile.uid] = profile;
    } else {
      // Subsequent writes: preserve createdAt, merge only mutable fields.
      _store[profile.uid] = UserProfile(
        uid: existing.uid,
        displayName: profile.displayName,
        email: profile.email,
        photoUrl: profile.photoUrl,
        createdAt: existing.createdAt,
        updatedAt: profile.updatedAt,
      );
    }
  }

  @override
  Future<void> updateDisplayName(String uid, String name) async {
    updateDisplayNameCalls.add('$uid:$name');
    final existing = _store[uid];
    if (existing != null) {
      _store[uid] = UserProfile(
        uid: existing.uid,
        displayName: name,
        email: existing.email,
        photoUrl: existing.photoUrl,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }
}

void main() {
  group('FakeUserRepository.updateDisplayName', () {
    test('records the call', () async {
      final repo = FakeUserRepository();
      await repo.upsertUser(UserProfile(
        uid: 'uid-1',
        displayName: 'Alice',
        email: 'alice@example.com',
        photoUrl: null,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ));

      await repo.updateDisplayName('uid-1', 'Alice B');

      expect(repo.updateDisplayNameCalls, ['uid-1:Alice B']);
    });

    test('updates stored display name', () async {
      final repo = FakeUserRepository();
      await repo.upsertUser(UserProfile(
        uid: 'uid-1',
        displayName: 'Alice',
        email: 'alice@example.com',
        photoUrl: null,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ));

      await repo.updateDisplayName('uid-1', 'Alicia');

      final profile = await repo.watchUser('uid-1').first;
      expect(profile?.displayName, 'Alicia');
    });

    test('does not throw when uid is not present', () async {
      final repo = FakeUserRepository();
      await expectLater(
        repo.updateDisplayName('unknown', 'X'),
        completes,
      );
    });
  });

  group('FakeUserRepository.upsertUser', () {
    test('stores new profile', () async {
      final repo = FakeUserRepository();
      const uid = 'uid-2';
      await repo.upsertUser(UserProfile(
        uid: uid,
        displayName: 'Bob',
        email: 'bob@example.com',
        photoUrl: null,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ));

      final profile = await repo.watchUser(uid).first;
      expect(profile?.displayName, 'Bob');
    });

    test('upsert is idempotent — second write wins for mutable fields', () async {
      final repo = FakeUserRepository();
      const uid = 'uid-3';
      final base = UserProfile(
        uid: uid,
        displayName: 'Carol',
        email: 'carol@example.com',
        photoUrl: null,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
      await repo.upsertUser(base);
      await repo.upsertUser(base.copyWith(displayName: 'Caroline'));

      final profile = await repo.watchUser(uid).first;
      expect(profile?.displayName, 'Caroline');
    });

    test('upsertUser twice preserves createdAt from first write', () async {
      final repo = FakeUserRepository();
      const uid = 'uid-4';
      final originalCreatedAt = DateTime(2025, 1, 1);

      await repo.upsertUser(UserProfile(
        uid: uid,
        displayName: 'Dave',
        email: 'dave@example.com',
        photoUrl: null,
        createdAt: originalCreatedAt,
        updatedAt: originalCreatedAt,
      ));

      // Second upsert simulates a subsequent sign-in with a newer timestamp.
      final laterDate = DateTime(2026, 6, 1);
      await repo.upsertUser(UserProfile(
        uid: uid,
        displayName: 'Dave Updated',
        email: 'dave@example.com',
        photoUrl: null,
        createdAt: laterDate,
        updatedAt: laterDate,
      ));

      final profile = await repo.watchUser(uid).first;
      // Mutable fields updated.
      expect(profile?.displayName, 'Dave Updated');
      // createdAt must be the original, not the overwrite value.
      expect(profile?.createdAt, originalCreatedAt);
    });
  });
}
