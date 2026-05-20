import 'package:equatable/equatable.dart';

sealed class UserBalancesState extends Equatable {
  const UserBalancesState();
}

final class UserBalancesInitial extends UserBalancesState {
  const UserBalancesInitial();

  @override
  List<Object?> get props => [];
}

final class UserBalancesLoaded extends UserBalancesState {
  const UserBalancesLoaded(this.netByGroup);

  /// groupId → netCents (positive = owed, negative = owes)
  final Map<String, int> netByGroup;

  @override
  List<Object?> get props => [netByGroup];
}

final class UserBalancesError extends UserBalancesState {
  const UserBalancesError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
