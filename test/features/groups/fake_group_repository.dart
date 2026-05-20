import 'package:ledger/core/result/result.dart';
import 'package:ledger/features/groups/domain/group_repository.dart';
import 'package:ledger/features/groups/domain/models/group.dart';
import 'package:ledger/features/groups/domain/models/group_member.dart';

final _fakeGroup = Group(
  id: 'group-1',
  name: 'Test Group',
  ownerUid: 'uid-1',
  memberUids: const ['uid-1'],
  memberDisplayNames: const {'uid-1': 'Alice'},
  createdAt: DateTime(2026),
  shareCode: 'ABC123',
);

class FakeGroupRepository implements GroupRepository {
  FakeGroupRepository({
    List<Group>? initialGroups,
    Result<Group, GroupFailure>? createResult,
    Result<Group, GroupFailure>? joinResult,
    Result<Group, GroupFailure>? getResult,
  })  : _groups = initialGroups ?? [],
        _createResult = createResult ?? Ok(_fakeGroup),
        _joinResult = joinResult ?? Ok(_fakeGroup),
        _getResult = getResult ?? Ok(_fakeGroup);

  final List<Group> _groups;
  final Result<Group, GroupFailure> _createResult;
  final Result<Group, GroupFailure> _joinResult;
  final Result<Group, GroupFailure> _getResult;

  @override
  Stream<List<Group>> watchUserGroups(String uid) =>
      Stream.value(_groups);

  @override
  Future<Result<Group, GroupFailure>> createGroup({
    required String name,
    required GroupMember owner,
  }) async => _createResult;

  @override
  Future<Result<Group, GroupFailure>> joinGroup({
    required String shareCode,
    required GroupMember user,
  }) async => _joinResult;

  @override
  Future<Result<Group, GroupFailure>> getGroup(String id) async => _getResult;
}
