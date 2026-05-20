import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/result/result.dart';
import '../domain/expense_repository.dart';
import '../domain/models/expense.dart';

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
}
