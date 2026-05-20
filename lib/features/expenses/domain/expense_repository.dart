import '../../../core/result/result.dart';
import 'models/expense.dart';

sealed class ExpenseFailure {
  const ExpenseFailure();
}

final class UnknownExpenseFailure extends ExpenseFailure {
  const UnknownExpenseFailure([this.message]);
  final String? message;
}

abstract interface class ExpenseRepository {
  Stream<List<Expense>> watchGroupExpenses(String groupId);

  Future<Result<Expense, ExpenseFailure>> addExpense(Expense expense);

  /// Returns a stream of {groupId → netCents} for [uid] across [groupIds].
  ///
  /// Uses a single collectionGroup query per collection (expenses, settlements)
  /// and reduces client-side. Positive = owed to [uid]; negative = [uid] owes.
  Stream<Map<String, int>> watchUserNetBalanceByGroup({
    required String uid,
    required List<String> groupIds,
  });
}
