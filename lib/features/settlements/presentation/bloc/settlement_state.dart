import 'package:equatable/equatable.dart';

sealed class SettlementState extends Equatable {
  const SettlementState();
}

final class SettlementIdle extends SettlementState {
  const SettlementIdle();

  @override
  List<Object?> get props => [];
}

final class SettlementRecording extends SettlementState {
  const SettlementRecording();

  @override
  List<Object?> get props => [];
}

final class SettlementRecorded extends SettlementState {
  const SettlementRecorded();

  @override
  List<Object?> get props => [];
}

final class SettlementError extends SettlementState {
  const SettlementError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
