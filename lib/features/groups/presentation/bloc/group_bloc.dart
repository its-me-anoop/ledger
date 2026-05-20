import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/group_repository.dart';
import '../../domain/models/group.dart';
import '../../domain/models/group_member.dart';
import 'group_event.dart';
import 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  GroupBloc(this._repository) : super(const GroupsInitial()) {
    on<LoadGroups>(_onLoad);
    on<CreateGroupRequested>(_onCreate);
    on<JoinGroupRequested>(_onJoin);
  }

  final GroupRepository _repository;
  StreamSubscription<List<Group>>? _groupsSubscription;

  Future<void> _onLoad(LoadGroups event, Emitter<GroupState> emit) async {
    emit(const GroupsLoading());
    await emit.onEach<List<Group>>(
      _repository.watchUserGroups(event.uid),
      onData: (groups) => emit(GroupsLoaded(groups)),
      onError: (e, _) => emit(GroupsError(failure: UnknownGroupFailure(e.toString()))),
    );
  }

  Future<void> _onCreate(
    CreateGroupRequested event,
    Emitter<GroupState> emit,
  ) async {
    final current = _currentGroups();
    emit(GroupActionLoading(current));

    final result = await _repository.createGroup(
      name: event.name,
      owner: GroupMember(uid: event.uid, displayName: event.displayName),
    );

    result.when(
      ok: (group) {
        final updated = [group, ...current];
        emit(GroupActionSuccess(groups: updated, newGroup: group));
        emit(GroupsLoaded(updated));
      },
      err: (failure) => emit(GroupsError(failure: failure, groups: current)),
    );
  }

  Future<void> _onJoin(
    JoinGroupRequested event,
    Emitter<GroupState> emit,
  ) async {
    final current = _currentGroups();
    emit(GroupActionLoading(current));

    final result = await _repository.joinGroup(
      shareCode: event.shareCode,
      user: GroupMember(uid: event.uid, displayName: event.displayName),
    );

    result.when(
      ok: (group) {
        final updated = [group, ...current];
        emit(GroupActionSuccess(groups: updated, newGroup: group));
        emit(GroupsLoaded(updated));
      },
      err: (failure) => emit(GroupsError(failure: failure, groups: current)),
    );
  }

  List<Group> _currentGroups() => switch (state) {
    GroupsLoaded(:final groups) => groups,
    GroupActionLoading(:final groups) => groups,
    GroupActionSuccess(:final groups) => groups,
    GroupsError(:final groups) => groups,
    _ => const [],
  };

  @override
  Future<void> close() {
    _groupsSubscription?.cancel();
    return super.close();
  }
}
