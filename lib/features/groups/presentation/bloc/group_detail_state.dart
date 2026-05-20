import 'package:equatable/equatable.dart';

import '../../domain/models/group.dart';

sealed class GroupDetailState extends Equatable {
  const GroupDetailState();
}

final class GroupDetailLoading extends GroupDetailState {
  const GroupDetailLoading();

  @override
  List<Object?> get props => [];
}

final class GroupDetailLoaded extends GroupDetailState {
  const GroupDetailLoaded(this.group);

  final Group group;

  @override
  List<Object?> get props => [group];
}

final class GroupDetailNotFound extends GroupDetailState {
  const GroupDetailNotFound();

  @override
  List<Object?> get props => [];
}

final class GroupDetailError extends GroupDetailState {
  const GroupDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
