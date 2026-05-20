import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/features/expenses/domain/models/expense.dart';
import 'package:ledger/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:ledger/features/expenses/presentation/bloc/expense_event.dart';
import 'package:ledger/features/expenses/presentation/bloc/expense_state.dart';

import 'fake_expense_repository.dart';
import 'fake_settlement_repository.dart';

final _expense = Expense(
  id: 'e1',
  groupId: 'g1',
  amount: 300,
  description: 'Coffee',
  paidByUid: 'uid-1',
  splitAmongUids: const ['uid-1', 'uid-2'],
  createdAt: DateTime(2026),
);

ExpenseBloc _bloc({
  List<Expense>? expenses,
}) =>
    ExpenseBloc(
      expenseRepository: FakeExpenseRepository(expenses: expenses),
      settlementRepository: FakeSettlementRepository(),
    );

void main() {
  group('ExpenseBloc', () {
    group('LoadExpenses', () {
      blocTest<ExpenseBloc, ExpenseState>(
        'emits [Loading, Loaded(empty)] when no expenses',
        build: () => _bloc(),
        act: (bloc) => bloc.add(const LoadExpenses('g1')),
        expect: () => [
          const ExpensesLoading(),
          isA<ExpensesLoaded>().having(
            (s) => s.expenses,
            'expenses',
            isEmpty,
          ),
        ],
      );

      blocTest<ExpenseBloc, ExpenseState>(
        'emits [Loading, Loaded] with correct netBalances when expenses exist',
        build: () => _bloc(expenses: [_expense]),
        act: (bloc) => bloc.add(const LoadExpenses('g1')),
        expect: () => [
          const ExpensesLoading(),
          isA<ExpensesLoaded>().having(
            (s) => s.netBalances['uid-1'],
            'payer balance',
            150, // 300 split 2: share=150, rem=0. payer: +300-150=+150. other: -150.
          ),
        ],
      );
    });

    group('AddExpense', () {
      blocTest<ExpenseBloc, ExpenseState>(
        'calls addExpense on repository and does not emit error on success',
        build: () => _bloc(),
        act: (bloc) => bloc.add(AddExpense(_expense)),
        expect: () => <ExpenseState>[],
      );
    });
  });
}
