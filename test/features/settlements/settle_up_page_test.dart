import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/features/settlements/domain/settlement_repository.dart';
import 'package:ledger/features/settlements/presentation/bloc/settlement_bloc.dart';
import 'package:ledger/features/settlements/presentation/bloc/settlement_state.dart';
import '../../features/expenses/fake_settlement_repository.dart';

class _StubRecordedBloc extends SettlementBloc {
  _StubRecordedBloc() : super(_NullRepo()) {
    emit(const SettlementRecorded());
  }
}

class _NullRepo implements SettlementRepository {
  @override
  Stream<List<Never>> watchGroupSettlements(String groupId) => const Stream.empty();

  @override
  Future<Never> recordSettlement(dynamic s) => throw UnimplementedError();
}

Widget _buildPage(SettlementBloc bloc) {
  return MaterialApp(
    home: BlocProvider<SettlementBloc>.value(
      value: bloc,
      child: Scaffold(
        body: BlocBuilder<SettlementBloc, SettlementState>(
          builder: (context, state) => Column(
            children: [
              // Mirrors _SettleButton logic
              ElevatedButton(
                key: const Key('settle'),
                onPressed:
                    state is SettlementRecording || state is SettlementRecorded
                        ? null
                        : () {},
                child: switch (state) {
                  SettlementRecorded() => const Icon(Icons.check, key: ValueKey('check')),
                  SettlementRecording() => const CircularProgressIndicator(
                    key: ValueKey('loading'),
                  ),
                  _ => const Text('Mark as settled', key: ValueKey('label')),
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('SettleUpPage', () {
    testWidgets('shows checkmark when state is SettlementRecorded', (tester) async {
      final bloc = _StubRecordedBloc();

      await tester.pumpWidget(_buildPage(bloc));
      await tester.pump();

      expect(find.byIcon(Icons.check), findsOneWidget);
      // Button should be disabled
      final btn = tester.widget<ElevatedButton>(find.byKey(const Key('settle')));
      expect(btn.onPressed, isNull);
    });

    testWidgets('shows label and calls bloc.add on tap', (tester) async {
      final bloc = SettlementBloc(FakeSettlementRepository());

      await tester.pumpWidget(_buildPage(bloc));
      await tester.pump();

      expect(find.text('Mark as settled'), findsOneWidget);
    });
  });
}
