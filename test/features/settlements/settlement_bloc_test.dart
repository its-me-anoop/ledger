import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/result/result.dart';
import 'package:ledger/features/settlements/domain/models/settlement.dart';
import 'package:ledger/features/settlements/domain/settlement_repository.dart';
import 'package:ledger/features/settlements/presentation/bloc/settlement_bloc.dart';
import 'package:ledger/features/settlements/presentation/bloc/settlement_event.dart';
import 'package:ledger/features/settlements/presentation/bloc/settlement_state.dart';

import '../../features/expenses/fake_settlement_repository.dart';

final _settlement = Settlement(
  id: '',
  groupId: 'g1',
  fromUid: 'uid-2',
  toUid: 'uid-1',
  amount: 3450,
  createdAt: DateTime(2026),
);

void main() {
  group('SettlementBloc', () {
    group('RecordSettlement', () {
      blocTest<SettlementBloc, SettlementState>(
        'emits [Recording, Recorded] on success',
        build: () => SettlementBloc(FakeSettlementRepository()),
        act: (bloc) => bloc.add(RecordSettlement(_settlement)),
        expect: () => [
          const SettlementRecording(),
          const SettlementRecorded(),
        ],
      );

      blocTest<SettlementBloc, SettlementState>(
        'emits [Recording, Error] on failure',
        build: () => SettlementBloc(
          FakeSettlementRepository(
            recordResult: const Err(UnknownSettlementFailure('network error')),
          ),
        ),
        act: (bloc) => bloc.add(RecordSettlement(_settlement)),
        expect: () => [
          const SettlementRecording(),
          isA<SettlementError>().having(
            (s) => s.message,
            'message',
            'network error',
          ),
        ],
      );
    });
  });
}
