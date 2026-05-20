import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/expense_repository.dart';
import '../../domain/models/expense.dart';
import '../../domain/services/balance_calculator.dart';
import '../../../settlements/domain/models/settlement.dart';
import '../../../settlements/domain/settlement_repository.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  ExpenseBloc({
    required ExpenseRepository expenseRepository,
    required SettlementRepository settlementRepository,
  })  : _expenseRepo = expenseRepository,
        _settlementRepo = settlementRepository,
        super(const ExpensesLoading()) {
    on<LoadExpenses>(_onLoad);
    on<AddExpense>(_onAdd);
  }

  final ExpenseRepository _expenseRepo;
  final SettlementRepository _settlementRepo;

  Future<void> _onLoad(LoadExpenses event, Emitter<ExpenseState> emit) async {
    emit(const ExpensesLoading());

    await emit.onEach<(List<Expense>, List<Settlement>)>(
      Rx.combineLatest2(
        _expenseRepo.watchGroupExpenses(event.groupId),
        _settlementRepo.watchGroupSettlements(event.groupId),
        (expenses, settlements) => (expenses, settlements),
      ),
      onData: (pair) {
        final (expenses, settlements) = pair;
        final allUids = {
          for (final e in expenses) ...[e.paidByUid, ...e.splitAmongUids],
          for (final s in settlements) ...[s.fromUid, s.toUid],
        }.toList();
        final balances = BalanceCalculator.calculate(
          expenses: expenses,
          settlements: settlements,
          memberUids: allUids,
        );
        emit(ExpensesLoaded(
          expenses: expenses,
          settlements: settlements,
          netBalances: balances,
        ));
      },
      onError: (e, _) => emit(ExpensesError(e.toString())),
    );
  }

  Future<void> _onAdd(AddExpense event, Emitter<ExpenseState> emit) async {
    final result = await _expenseRepo.addExpense(event.expense);
    result.when(
      ok: (_) {},
      err: (failure) => emit(
        ExpensesError((failure as UnknownExpenseFailure).message ?? 'Error'),
      ),
    );
  }
}
