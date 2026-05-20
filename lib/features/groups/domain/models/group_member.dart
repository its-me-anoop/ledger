import 'package:equatable/equatable.dart';

class GroupMember extends Equatable {
  const GroupMember({
    required this.uid,
    required this.displayName,
    this.photoUrl,
  });

  final String uid;
  final String displayName;
  final String? photoUrl;

  @override
  List<Object?> get props => [uid, displayName, photoUrl];
}
