import 'package:equatable/equatable.dart';

import '../../domain/group_repository.dart';
import '../../domain/models/group.dart';

sealed class GroupState extends Equatable {
  const GroupState();
}

final class GroupsInitial extends GroupState {
  const GroupsInitial();

  @override
  List<Object?> get props => [];
}

final class GroupsLoading extends GroupState {
  const GroupsLoading();

  @override
  List<Object?> get props => [];
}

final class GroupsLoaded extends GroupState {
  const GroupsLoaded(this.groups);

  final List<Group> groups;

  @override
  List<Object?> get props => [groups];
}

final class GroupActionLoading extends GroupState {
  const GroupActionLoading(this.groups);

  final List<Group> groups;

  @override
  List<Object?> get props => [groups];
}

final class GroupActionSuccess extends GroupState {
  const GroupActionSuccess({required this.groups, required this.newGroup});

  final List<Group> groups;
  final Group newGroup;

  @override
  List<Object?> get props => [groups, newGroup];
}

final class GroupsError extends GroupState {
  const GroupsError({required this.failure, this.groups = const []});

  final GroupFailure failure;
  final List<Group> groups;

  @override
  List<Object?> get props => [failure, groups];
}
