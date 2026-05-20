import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/settlement_repository.dart';
import 'settlement_event.dart';
import 'settlement_state.dart';

class SettlementBloc extends Bloc<SettlementEvent, SettlementState> {
  SettlementBloc(this._repository) : super(const SettlementIdle()) {
    on<RecordSettlement>(_onRecord);
  }

  final SettlementRepository _repository;

  Future<void> _onRecord(
    RecordSettlement event,
    Emitter<SettlementState> emit,
  ) async {
    emit(const SettlementRecording());
    final result = await _repository.recordSettlement(event.settlement);
    result.when(
      ok: (_) => emit(const SettlementRecorded()),
      err: (failure) => emit(
        SettlementError(
          (failure as UnknownSettlementFailure).message ?? 'Failed to record settlement',
        ),
      ),
    );
  }
}
