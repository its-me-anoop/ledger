import 'package:equatable/equatable.dart';

sealed class GroupDetailEvent extends Equatable {
  const GroupDetailEvent();
}

final class LoadGroupDetail extends GroupDetailEvent {
  const LoadGroupDetail(this.groupId);

  final String groupId;

  @override
  List<Object?> get props => [groupId];
}
