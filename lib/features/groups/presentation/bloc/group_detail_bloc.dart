import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/group_repository.dart';
import 'group_detail_event.dart';
import 'group_detail_state.dart';

class GroupDetailBloc extends Bloc<GroupDetailEvent, GroupDetailState> {
  GroupDetailBloc(this._repository) : super(const GroupDetailLoading()) {
    on<LoadGroupDetail>(_onLoad);
  }

  final GroupRepository _repository;

  Future<void> _onLoad(
    LoadGroupDetail event,
    Emitter<GroupDetailState> emit,
  ) async {
    emit(const GroupDetailLoading());
    final result = await _repository.getGroup(event.groupId);
    result.when(
      ok: (group) => emit(GroupDetailLoaded(group)),
      err: (failure) => switch (failure) {
        GroupNotFound() => emit(const GroupDetailNotFound()),
        _ => emit(GroupDetailError(failure.toString())),
      },
    );
  }
}
