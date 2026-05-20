import 'package:equatable/equatable.dart';

class Settlement extends Equatable {
  const Settlement({
    required this.id,
    required this.groupId,
    required this.fromUid,
    required this.toUid,
    required this.amount,
    required this.createdAt,
  });

  final String id;
  final String groupId;
  final String fromUid;
  final String toUid;
  /// Amount in minor units (cents).
  final int amount;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, groupId, fromUid, toUid, amount, createdAt];
}
