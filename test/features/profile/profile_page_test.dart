import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/features/auth/domain/models/app_user.dart';
import 'package:ledger/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ledger/features/auth/presentation/bloc/auth_state.dart';
import 'package:ledger/features/profile/presentation/pages/profile_page.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

const _user = AppUser(
  uid: 'uid-1',
  email: 'alice@example.com',
  displayName: 'Alice',
);

Widget _wrap(Widget child, {required AuthBloc authBloc}) {
  return MaterialApp(
    home: BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: child,
    ),
  );
}

void main() {
  group('ProfilePage', () {
    testWidgets('shows display name', (tester) async {
      final auth = MockAuthBloc();
      when(() => auth.state).thenReturn(const Authenticated(_user));
      when(() => auth.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_wrap(const ProfilePage(), authBloc: auth));
      await tester.pump();

      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('tapping name reveals inline TextField', (tester) async {
      final auth = MockAuthBloc();
      when(() => auth.state).thenReturn(const Authenticated(_user));
      when(() => auth.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_wrap(const ProfilePage(), authBloc: auth));
      await tester.pump();

      // Before tap: no TextField visible for name editing
      expect(find.byType(TextField), findsNothing);

      // Tap the name row to enter edit mode
      await tester.tap(find.text('Alice'));
      await tester.pump();

      // After tap: TextField should appear
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
