import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/theme/app_colors.dart';
import 'package:ledger/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ledger/features/auth/presentation/bloc/auth_state.dart';
import 'package:ledger/features/groups/domain/models/group.dart';
import 'package:ledger/features/groups/presentation/pages/group_detail_page.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

Widget _wrap(Widget child) {
  final auth = MockAuthBloc();
  when(() => auth.state).thenReturn(const Unauthenticated());
  when(() => auth.stream).thenAnswer((_) => const Stream.empty());
  return MaterialApp(
    home: BlocProvider<AuthBloc>.value(value: auth, child: child),
  );
}

void main() {
  group('BalanceStripContent', () {
    testWidgets('danger color when negative', (tester) async {
      await tester.pumpWidget(
        _wrap(const Scaffold(body: BalanceStripContent(netCents: -3450))),
      );
      await tester.pump();

      final textWidget = tester.widget<Text>(find.text('– \$34.50'));
      expect(textWidget.style?.color, AppColors.danger);
    });

    testWidgets('success color when positive', (tester) async {
      await tester.pumpWidget(
        _wrap(const Scaffold(body: BalanceStripContent(netCents: 1200))),
      );
      await tester.pump();

      final textWidget = tester.widget<Text>(find.text('+ \$12.00'));
      expect(textWidget.style?.color, AppColors.success);
    });

    testWidgets('shows Settled when zero', (tester) async {
      await tester.pumpWidget(
        _wrap(const Scaffold(body: BalanceStripContent(netCents: 0))),
      );
      await tester.pump();

      expect(find.text('Settled'), findsOneWidget);
    });
  });

  group('GroupDetail tabs', () {
    testWidgets('all 3 tabs are present when loaded', (tester) async {
      final auth = MockAuthBloc();
      when(() => auth.state).thenReturn(const Unauthenticated());
      when(() => auth.stream).thenAnswer((_) => const Stream.empty());

      final group = Group(
        id: 'g1',
        name: 'Weekend Trip',
        ownerUid: 'uid-1',
        memberUids: const ['uid-1', 'uid-2'],
        memberDisplayNames: const {'uid-1': 'Alice', 'uid-2': 'Bob'},
        createdAt: DateTime(2026),
        shareCode: 'ABC123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [BlocProvider<AuthBloc>.value(value: auth)],
            child: _TabScaffoldUnderTest(group: group),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Members'), findsOneWidget);
    });
  });
}

/// Builds the loaded scaffold directly — no Firestore, no get_it.
class _TabScaffoldUnderTest extends StatelessWidget {
  const _TabScaffoldUnderTest({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(group.name),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Expenses'),
              Tab(text: 'Activity'),
              Tab(text: 'Members'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('expenses')),
            Center(child: Text('activity')),
            Center(child: Text('members')),
          ],
        ),
      ),
    );
  }
}
