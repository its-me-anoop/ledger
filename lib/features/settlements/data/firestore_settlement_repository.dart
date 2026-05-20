import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/result/result.dart';
import '../domain/settlement_repository.dart';
import '../domain/models/settlement.dart';

class FirestoreSettlementRepository implements SettlementRepository {
  FirestoreSettlementRepository({required FirebaseFirestore firestore})
      : _db = firestore;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String groupId) =>
      _db.collection('groups').doc(groupId).collection('settlements');

  @override
  Stream<List<Settlement>> watchGroupSettlements(String groupId) {
    return _col(groupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => _docToSettlement(groupId, doc)).toList(),
        );
  }

  @override
  Future<Result<Settlement, SettlementFailure>> recordSettlement(
    Settlement settlement,
  ) async {
    try {
      final ref = _col(settlement.groupId).doc();
      final now = Timestamp.fromDate(settlement.createdAt);
      await ref.set({
        'fromUid': settlement.fromUid,
        'toUid': settlement.toUid,
        'amount': settlement.amount,
        'createdBy': settlement.fromUid,
        'createdAt': now,
        'groupId': settlement.groupId,
      });
      return Ok(Settlement(
        id: ref.id,
        groupId: settlement.groupId,
        fromUid: settlement.fromUid,
        toUid: settlement.toUid,
        amount: settlement.amount,
        createdAt: settlement.createdAt,
      ));
    } catch (e) {
      debugPrint('[SettlementRepo] recordSettlement error: $e');
      return Err(UnknownSettlementFailure(e.toString()));
    }
  }

  Settlement _docToSettlement(
    String groupId,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return Settlement(
      id: doc.id,
      groupId: groupId,
      fromUid: d['fromUid'] as String,
      toUid: d['toUid'] as String,
      amount: (d['amount'] as num).toInt(),
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }
}
