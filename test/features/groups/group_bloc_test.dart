import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/result/result.dart';
import 'package:ledger/features/groups/domain/group_repository.dart';
import 'package:ledger/features/groups/domain/models/group.dart';
import 'package:ledger/features/groups/presentation/bloc/group_bloc.dart';
import 'package:ledger/features/groups/presentation/bloc/group_event.dart';
import 'package:ledger/features/groups/presentation/bloc/group_state.dart';

import 'fake_group_repository.dart';

final _fakeGroup = Group(
  id: 'group-1',
  name: 'Test Group',
  ownerUid: 'uid-1',
  memberUids: const ['uid-1'],
  memberDisplayNames: const {'uid-1': 'Alice'},
  createdAt: DateTime(2026),
  shareCode: 'ABC123',
);

void main() {
  group('GroupBloc', () {
    group('LoadGroups', () {
      blocTest<GroupBloc, GroupState>(
        'emits [Loading, Loaded(empty)] when no groups exist',
        build: () => GroupBloc(FakeGroupRepository()),
        act: (bloc) => bloc.add(const LoadGroups(uid: 'uid-1')),
        expect: () => [
          const GroupsLoading(),
          const GroupsLoaded([]),
        ],
      );

      blocTest<GroupBloc, GroupState>(
        'emits [Loading, Loaded(groups)] when groups exist',
        build: () => GroupBloc(
          FakeGroupRepository(initialGroups: [_fakeGroup]),
        ),
        act: (bloc) => bloc.add(const LoadGroups(uid: 'uid-1')),
        expect: () => [
          const GroupsLoading(),
          GroupsLoaded([_fakeGroup]),
        ],
      );
    });

    group('CreateGroupRequested', () {
      blocTest<GroupBloc, GroupState>(
        'emits [ActionLoading, ActionSuccess, Loaded] on success',
        build: () => GroupBloc(FakeGroupRepository()),
        act: (bloc) => bloc.add(
          const CreateGroupRequested(
            name: 'Test Group',
            uid: 'uid-1',
            displayName: 'Alice',
          ),
        ),
        expect: () => [
          const GroupActionLoading([]),
          GroupActionSuccess(groups: [_fakeGroup], newGroup: _fakeGroup),
          GroupsLoaded([_fakeGroup]),
        ],
      );

      blocTest<GroupBloc, GroupState>(
        'emits [ActionLoading, GroupsError] on failure',
        build: () => GroupBloc(
          FakeGroupRepository(
            createResult: const Err(UnknownGroupFailure('server error')),
          ),
        ),
        act: (bloc) => bloc.add(
          const CreateGroupRequested(
            name: 'Test Group',
            uid: 'uid-1',
            displayName: 'Alice',
          ),
        ),
        expect: () => [
          const GroupActionLoading([]),
          isA<GroupsError>(),
        ],
      );
    });

    group('JoinGroupRequested', () {
      blocTest<GroupBloc, GroupState>(
        'emits [ActionLoading, ActionSuccess, Loaded] on success',
        build: () => GroupBloc(FakeGroupRepository()),
        act: (bloc) => bloc.add(
          const JoinGroupRequested(
            shareCode: 'ABC123',
            uid: 'uid-1',
            displayName: 'Alice',
          ),
        ),
        expect: () => [
          const GroupActionLoading([]),
          GroupActionSuccess(groups: [_fakeGroup], newGroup: _fakeGroup),
          GroupsLoaded([_fakeGroup]),
        ],
      );

      blocTest<GroupBloc, GroupState>(
        'emits [ActionLoading, GroupsError(InvalidShareCode)] on invalid code',
        build: () => GroupBloc(
          FakeGroupRepository(
            joinResult: const Err(InvalidShareCode()),
          ),
        ),
        act: (bloc) => bloc.add(
          const JoinGroupRequested(
            shareCode: 'XXXXXX',
            uid: 'uid-1',
            displayName: 'Alice',
          ),
        ),
        expect: () => [
          const GroupActionLoading([]),
          isA<GroupsError>(),
        ],
        verify: (bloc) {
          final state = bloc.state as GroupsError;
          expect(state.failure, isA<InvalidShareCode>());
        },
      );
    });
  });
}
