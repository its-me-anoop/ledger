import 'package:equatable/equatable.dart';

import '../../domain/models/settlement.dart';

sealed class SettlementEvent extends Equatable {
  const SettlementEvent();
}

final class RecordSettlement extends SettlementEvent {
  const RecordSettlement(this.settlement);

  final Settlement settlement;

  @override
  List<Object?> get props => [settlement];
}
