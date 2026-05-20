import '../../../core/result/result.dart';
import 'models/group.dart';
import 'models/group_member.dart';

sealed class GroupFailure {
  const GroupFailure();
}

final class GroupNotFound extends GroupFailure {
  const GroupNotFound();
}

final class InvalidShareCode extends GroupFailure {
  const InvalidShareCode();
}

final class PermissionDenied extends GroupFailure {
  const PermissionDenied();
}

final class UnknownGroupFailure extends GroupFailure {
  const UnknownGroupFailure([this.message]);
  final String? message;
}

abstract interface class GroupRepository {
  Stream<List<Group>> watchUserGroups(String uid);

  Future<Result<Group, GroupFailure>> createGroup({
    required String name,
    required GroupMember owner,
  });

  Future<Result<Group, GroupFailure>> joinGroup({
    required String shareCode,
    required GroupMember user,
  });

  Future<Result<Group, GroupFailure>> getGroup(String id);
}
