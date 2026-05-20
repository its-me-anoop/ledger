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
}
