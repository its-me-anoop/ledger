import 'package:ledger/core/result/result.dart';
import 'package:ledger/features/expenses/domain/expense_repository.dart';
import 'package:ledger/features/expenses/domain/models/expense.dart';

class FakeExpenseRepository implements ExpenseRepository {
  FakeExpenseRepository({
    List<Expense>? expenses,
    Result<Expense, ExpenseFailure>? addResult,
  })  : _expenses = expenses ?? [],
        _addResult = addResult;

  final List<Expense> _expenses;
  final Result<Expense, ExpenseFailure>? _addResult;

  @override
  Stream<List<Expense>> watchGroupExpenses(String groupId) =>
      Stream.value(_expenses);

  @override
  Future<Result<Expense, ExpenseFailure>> addExpense(Expense expense) async {
    return _addResult ?? Ok(expense);
  }
}
