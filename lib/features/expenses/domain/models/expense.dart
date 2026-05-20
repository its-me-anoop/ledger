import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  const Expense({
    required this.id,
    required this.groupId,
    required this.amount,
    required this.description,
    required this.paidByUid,
    required this.splitAmongUids,
    required this.createdAt,
  });

  final String id;
  final String groupId;
  /// Amount in minor units (cents).
  final int amount;
  final String description;
  final String paidByUid;
  final List<String> splitAmongUids;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    groupId,
    amount,
    description,
    paidByUid,
    splitAmongUids,
    createdAt,
  ];
}
