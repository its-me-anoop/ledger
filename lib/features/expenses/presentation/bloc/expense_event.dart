import 'package:equatable/equatable.dart';

import '../../domain/models/expense.dart';

sealed class ExpenseEvent extends Equatable {
  const ExpenseEvent();
}

final class LoadExpenses extends ExpenseEvent {
  const LoadExpenses(this.groupId);

  final String groupId;

  @override
  List<Object?> get props => [groupId];
}

final class AddExpense extends ExpenseEvent {
  const AddExpense(this.expense);

  final Expense expense;

  @override
  List<Object?> get props => [expense];
}
