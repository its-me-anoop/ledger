import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../expenses/domain/expense_repository.dart';
import 'user_balances_event.dart';
import 'user_balances_state.dart';

class UserBalancesBloc extends Bloc<UserBalancesEvent, UserBalancesState> {
  UserBalancesBloc(this._expenseRepository) : super(const UserBalancesInitial()) {
    on<LoadUserBalances>(_onLoad);
  }

  final ExpenseRepository _expenseRepository;

  Future<void> _onLoad(
    LoadUserBalances event,
    Emitter<UserBalancesState> emit,
  ) async {
    await emit.onEach<Map<String, int>>(
      _expenseRepository.watchUserNetBalanceByGroup(
        uid: event.uid,
        groupIds: event.groupIds,
      ),
      onData: (map) => emit(UserBalancesLoaded(map)),
      onError: (e, _) => emit(UserBalancesError(e.toString())),
    );
  }
}
