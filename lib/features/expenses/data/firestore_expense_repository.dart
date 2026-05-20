import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../../../core/result/result.dart';
import '../domain/expense_repository.dart';
import '../domain/models/expense.dart';
import '../domain/services/balance_calculator.dart';
import '../../settlements/domain/models/settlement.dart';

class FirestoreExpenseRepository implements ExpenseRepository {
  FirestoreExpenseRepository({required FirebaseFirestore firestore})
      : _db = firestore;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String groupId) =>
      _db.collection('groups').doc(groupId).collection('expenses');

  @override
  Stream<List<Expense>> watchGroupExpenses(String groupId) {
    return _col(groupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => _docToExpense(groupId, doc)).toList());
  }

  @override
  Future<Result<Expense, ExpenseFailure>> addExpense(Expense expense) async {
    try {
      final ref = _col(expense.groupId).doc();
      final now = Timestamp.fromDate(expense.createdAt);
      await ref.set({
        'description': expense.description,
        'amount': expense.amount,
        'paidBy': expense.paidByUid,
        'splitAmong': expense.splitAmongUids,
        'createdBy': expense.paidByUid,
        'createdAt': now,
        'groupId': expense.groupId,
      });
      return Ok(Expense(
        id: ref.id,
        groupId: expense.groupId,
        amount: expense.amount,
        description: expense.description,
        paidByUid: expense.paidByUid,
        splitAmongUids: expense.splitAmongUids,
        createdAt: expense.createdAt,
      ));
    } catch (e) {
      debugPrint('[ExpenseRepo] addExpense error: $e');
      return Err(UnknownExpenseFailure(e.toString()));
    }
  }

  @override
  Stream<Map<String, int>> watchUserNetBalanceByGroup({
    required String uid,
    required List<String> groupIds,
  }) {
    if (groupIds.isEmpty) return Stream.value({});

    // Firestore whereIn supports up to 30 values per query.
    // For MVP, chunk at 30 and merge. Most users have far fewer groups.
    final chunks = _chunk(groupIds, 30);

    Stream<List<Expense>> expenseStream = Stream.value([]);
    Stream<List<Settlement>> settlementStream = Stream.value([]);

    for (final chunk in chunks) {
      final eChunk = _db
          .collectionGroup('expenses')
          .where('groupId', whereIn: chunk)
          .snapshots()
          .map((s) => s.docs
              .map((d) => _docToExpenseFromGroup(d))
              .whereType<Expense>()
              .toList());

      final sChunk = _db
          .collectionGroup('settlements')
          .where('groupId', whereIn: chunk)
          .snapshots()
          .map((s) => s.docs
              .map((d) => _docToSettlementFromGroup(d))
              .whereType<Settlement>()
              .toList());

      expenseStream = Rx.combineLatest2(
        expenseStream,
        eChunk,
        (a, b) => [...a, ...b],
      );
      settlementStream = Rx.combineLatest2(
        settlementStream,
        sChunk,
        (a, b) => [...a, ...b],
      );
    }

    return Rx.combineLatest2(
      expenseStream,
      settlementStream,
      (expenses, settlements) => _reduceByGroup(uid, groupIds, expenses, settlements),
    );
  }

  /// Reduces all expenses + settlements into a {groupId → netCents} map
  /// for the given [uid].
  static Map<String, int> _reduceByGroup(
    String uid,
    List<String> groupIds,
    List<Expense> expenses,
    List<Settlement> settlements,
  ) {
    final result = <String, int>{for (final g in groupIds) g: 0};

    for (final gid in groupIds) {
      final gExpenses = expenses.where((e) => e.groupId == gid).toList();
      final gSettlements = settlements.where((s) => s.groupId == gid).toList();

      final allUids = {
        for (final e in gExpenses) ...[e.paidByUid, ...e.splitAmongUids],
        for (final s in gSettlements) ...[s.fromUid, s.toUid],
      }.toList();

      if (allUids.isEmpty) continue;

      final balances = BalanceCalculator.calculate(
        expenses: gExpenses,
        settlements: gSettlements,
        memberUids: allUids,
      );
      result[gid] = balances[uid] ?? 0;
    }

    return result;
  }

  Expense _docToExpense(
    String groupId,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return Expense(
      id: doc.id,
      groupId: groupId,
      amount: (d['amount'] as num).toInt(),
      description: d['description'] as String,
      paidByUid: d['paidBy'] as String,
      splitAmongUids: List<String>.from(d['splitAmong'] as List? ?? []),
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Expense? _docToExpenseFromGroup(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data();
    if (d == null) return null;
    final groupId = d['groupId'] as String?;
    if (groupId == null) return null;
    return Expense(
      id: doc.id,
      groupId: groupId,
      amount: (d['amount'] as num).toInt(),
      description: d['description'] as String,
      paidByUid: d['paidBy'] as String,
      splitAmongUids: List<String>.from(d['splitAmong'] as List? ?? []),
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Settlement? _docToSettlementFromGroup(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data();
    if (d == null) return null;
    final groupId = d['groupId'] as String?;
    if (groupId == null) return null;
    return Settlement(
      id: doc.id,
      groupId: groupId,
      fromUid: d['fromUid'] as String,
      toUid: d['toUid'] as String,
      amount: (d['amount'] as num).toInt(),
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  static List<List<T>> _chunk<T>(List<T> list, int size) {
    final result = <List<T>>[];
    for (var i = 0; i < list.length; i += size) {
      result.add(list.sublist(i, i + size < list.length ? i + size : list.length));
    }
    return result;
  }
}

