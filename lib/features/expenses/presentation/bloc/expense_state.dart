import 'package:equatable/equatable.dart';

import '../../domain/models/expense.dart';
import '../../../settlements/domain/models/settlement.dart';

sealed class ExpenseState extends Equatable {
  const ExpenseState();
}

final class ExpensesLoading extends ExpenseState {
  const ExpensesLoading();

  @override
  List<Object?> get props => [];
}

final class ExpensesLoaded extends ExpenseState {
  const ExpensesLoaded({
    required this.expenses,
    required this.settlements,
    required this.netBalances,
  });

  final List<Expense> expenses;
  final List<Settlement> settlements;
  /// uid → net cents (positive = owed, negative = owes)
  final Map<String, int> netBalances;

  @override
  List<Object?> get props => [expenses, settlements, netBalances];
}

final class ExpensesError extends ExpenseState {
  const ExpensesError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
