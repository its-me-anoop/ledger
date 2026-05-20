import 'package:equatable/equatable.dart';

sealed class GroupEvent extends Equatable {
  const GroupEvent();
}

final class LoadGroups extends GroupEvent {
  const LoadGroups({required this.uid});

  final String uid;

  @override
  List<Object?> get props => [uid];
}

final class CreateGroupRequested extends GroupEvent {
  const CreateGroupRequested({required this.name, required this.uid, required this.displayName});

  final String name;
  final String uid;
  final String displayName;

  @override
  List<Object?> get props => [name, uid, displayName];
}

final class JoinGroupRequested extends GroupEvent {
  const JoinGroupRequested({
    required this.shareCode,
    required this.uid,
    required this.displayName,
  });

  final String shareCode;
  final String uid;
  final String displayName;

  @override
  List<Object?> get props => [shareCode, uid, displayName];
}
