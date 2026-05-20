import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/result/result.dart';
import '../domain/group_repository.dart';
import '../domain/models/group.dart';
import '../domain/models/group_member.dart';

class FirestoreGroupRepository implements GroupRepository {
  FirestoreGroupRepository({required FirebaseFirestore firestore})
      : _db = firestore;

  final FirebaseFirestore _db;

  @override
  Stream<List<Group>> watchUserGroups(String uid) {
    return _db
        .collection('groups')
        .where('memberUids', arrayContains: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_docToGroup).toList());
  }

  @override
  Future<Result<Group, GroupFailure>> createGroup({
    required String name,
    required GroupMember owner,
  }) async {
    try {
      final code = _generateShareCode();
      final groupRef = _db.collection('groups').doc();
      final codeRef = _db.collection('shareCodes').doc(code);
      final memberRef = groupRef.collection('members').doc(owner.uid);

      final now = Timestamp.now();
      final batch = _db.batch();

      batch.set(groupRef, {
        'name': name,
        'createdBy': owner.uid,
        'shareCode': code,
        'memberUids': [owner.uid],
        'createdAt': now,
      });

      batch.set(memberRef, {
        'displayName': owner.displayName,
        'photoUrl': owner.photoUrl,
        'joinedAt': now,
        'role': 'admin',
      });

      batch.set(codeRef, {
        'groupId': groupRef.id,
        'createdAt': now,
      });

      await batch.commit();

      final group = Group(
        id: groupRef.id,
        name: name,
        ownerUid: owner.uid,
        memberUids: [owner.uid],
        memberDisplayNames: {owner.uid: owner.displayName},
        createdAt: now.toDate(),
        shareCode: code,
      );
      return Ok(group);
    } catch (e) {
      debugPrint('[GroupRepo] createGroup error: $e');
      return Err(UnknownGroupFailure(e.toString()));
    }
  }

  @override
  Future<Result<Group, GroupFailure>> joinGroup({
    required String shareCode,
    required GroupMember user,
  }) async {
    try {
      final codeDoc =
          await _db.collection('shareCodes').doc(shareCode.toUpperCase()).get();
      if (!codeDoc.exists) return const Err(InvalidShareCode());

      final groupId = codeDoc.data()!['groupId'] as String;
      final groupRef = _db.collection('groups').doc(groupId);
      final memberRef = groupRef.collection('members').doc(user.uid);
      final now = Timestamp.now();

      final batch = _db.batch();
      batch.update(groupRef, {
        'memberUids': FieldValue.arrayUnion([user.uid]),
      });
      batch.set(memberRef, {
        'displayName': user.displayName,
        'photoUrl': user.photoUrl,
        'joinedAt': now,
        'role': 'member',
      });
      await batch.commit();

      final result = await getGroup(groupId);
      return result;
    } catch (e) {
      debugPrint('[GroupRepo] joinGroup error: $e');
      return Err(UnknownGroupFailure(e.toString()));
    }
  }

  @override
  Future<Result<Group, GroupFailure>> getGroup(String id) async {
    try {
      final snap = await _db.collection('groups').doc(id).get();
      if (!snap.exists) return const Err(GroupNotFound());
      return Ok(_docToGroup(snap));
    } catch (e) {
      debugPrint('[GroupRepo] getGroup error: $e');
      return Err(UnknownGroupFailure(e.toString()));
    }
  }

  Group _docToGroup(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final uids = List<String>.from(data['memberUids'] as List? ?? []);
    return Group(
      id: doc.id,
      name: data['name'] as String,
      ownerUid: data['createdBy'] as String,
      memberUids: uids,
      memberDisplayNames: const {},
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      shareCode: data['shareCode'] as String,
    );
  }

  static const _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  String _generateShareCode() {
    final rng = Random.secure();
    return List.generate(6, (_) => _chars[rng.nextInt(_chars.length)]).join();
  }
}
