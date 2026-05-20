import 'package:equatable/equatable.dart';

class Group extends Equatable {
  const Group({
    required this.id,
    required this.name,
    required this.ownerUid,
    required this.memberUids,
    required this.memberDisplayNames,
    required this.createdAt,
    required this.shareCode,
  });

  final String id;
  final String name;
  final String ownerUid;
  final List<String> memberUids;

  // uid → displayName map for fast rendering without extra reads.
  final Map<String, String> memberDisplayNames;
  final DateTime createdAt;
  final String shareCode;

  @override
  List<Object?> get props => [
    id,
    name,
    ownerUid,
    memberUids,
    memberDisplayNames,
    createdAt,
    shareCode,
  ];
}
