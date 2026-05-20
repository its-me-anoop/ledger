import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/result/result.dart';
import 'package:ledger/features/auth/domain/models/app_user.dart';
import 'package:ledger/features/auth/domain/models/auth_failure.dart';
import 'package:ledger/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ledger/features/auth/presentation/bloc/auth_event.dart';
import 'package:ledger/features/auth/presentation/bloc/auth_state.dart';

import 'fake_auth_repository.dart';

const _user = AppUser(
  uid: 'uid-1',
  email: 'test@example.com',
  displayName: 'Test User',
);

void main() {
  group('AuthBloc', () {
    group('AuthStarted', () {
      blocTest<AuthBloc, AuthState>(
        'emits Unauthenticated when stream yields null',
        build: () => AuthBloc(
          FakeAuthRepository(authStreamValues: [null]),
        ),
        act: (bloc) => bloc.add(const AuthStarted()),
        expect: () => [const Unauthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits Authenticated when stream yields a user',
        build: () => AuthBloc(
          FakeAuthRepository(authStreamValues: [_user]),
        ),
        act: (bloc) => bloc.add(const AuthStarted()),
        expect: () => [const Authenticated(_user)],
      );
    });

    group('SignInRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [Loading, Authenticated] on success',
        build: () => AuthBloc(FakeAuthRepository()),
        act: (bloc) => bloc.add(
          const SignInRequested(email: 'a@b.com', password: 'pass'),
        ),
        expect: () => [const AuthLoading(), const Authenticated(_user)],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [Loading, AuthError] on failure',
        build: () => AuthBloc(
          FakeAuthRepository(signInResult: const Err(WrongPassword())),
        ),
        act: (bloc) => bloc.add(
          const SignInRequested(email: 'a@b.com', password: 'bad'),
        ),
        expect: () => [
          const AuthLoading(),
          const AuthError(WrongPassword()),
        ],
      );
    });

    group('SignUpRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [Loading, Authenticated] on success',
        build: () => AuthBloc(FakeAuthRepository()),
        act: (bloc) => bloc.add(
          const SignUpRequested(
            email: 'a@b.com',
            password: 'pass',
            displayName: 'Alice',
          ),
        ),
        expect: () => [const AuthLoading(), const Authenticated(_user)],
      );
    });

    group('GoogleSignInRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [Loading, Authenticated] on success',
        build: () => AuthBloc(FakeAuthRepository()),
        act: (bloc) => bloc.add(const GoogleSignInRequested()),
        expect: () => [const AuthLoading(), const Authenticated(_user)],
      );
    });

    group('SignOutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits Unauthenticated after sign out',
        build: () => AuthBloc(FakeAuthRepository()),
        seed: () => const Authenticated(_user),
        act: (bloc) => bloc.add(const SignOutRequested()),
        expect: () => [const Unauthenticated()],
      );
    });
  });
}
