import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../domain/models/user_profile.dart';
import '../domain/user_repository.dart';

class FirestoreUserRepository implements UserRepository {
  FirestoreUserRepository({required FirebaseFirestore firestore})
      : _db = firestore;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid);

  @override
  Stream<UserProfile?> watchUser(String uid) {
    return _doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return _fromDoc(snap);
    });
  }

  @override
  Future<void> upsertUser(UserProfile profile) async {
    try {
      final ref = _doc(profile.uid);
      await _db.runTransaction((tx) async {
        final snap = await tx.get(ref);
        if (snap.exists) {
          // Doc already exists: only merge mutable fields, never touch createdAt.
          tx.update(ref, {
            'displayName': profile.displayName,
            'email': profile.email,
            'photoUrl': profile.photoUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // First time this user is written: set all fields including createdAt.
          tx.set(ref, {
            'displayName': profile.displayName,
            'email': profile.email,
            'photoUrl': profile.photoUrl,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      debugPrint('[UserRepo] upsertUser error: $e');
    }
  }

  @override
  Future<void> updateDisplayName(String uid, String name) async {
    try {
      await _doc(uid).update({
        'displayName': name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('[UserRepo] updateDisplayName error: $e');
    }
  }

  static UserProfile _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return UserProfile(
      uid: doc.id,
      displayName: d['displayName'] as String? ?? '',
      email: d['email'] as String? ?? '',
      photoUrl: d['photoUrl'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
