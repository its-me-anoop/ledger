import 'package:equatable/equatable.dart';

sealed class UserBalancesEvent extends Equatable {
  const UserBalancesEvent();
}

final class LoadUserBalances extends UserBalancesEvent {
  const LoadUserBalances({required this.uid, required this.groupIds});

  final String uid;
  final List<String> groupIds;

  @override
  List<Object?> get props => [uid, groupIds];
}
