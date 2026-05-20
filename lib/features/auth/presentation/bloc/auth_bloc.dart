import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/auth_repository.dart';
import '../../domain/models/app_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository) : super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<SignInRequested>(_onSignIn);
    on<SignUpRequested>(_onSignUp);
    on<GoogleSignInRequested>(_onGoogleSignIn);
    on<SignOutRequested>(_onSignOut);
  }

  final AuthRepository _repository;
  StreamSubscription<AppUser?>? _authSubscription;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    await emit.onEach<AppUser?>(
      _repository.authStateChanges(),
      onData: (user) {
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(const Unauthenticated());
        }
      },
    );
  }

  Future<void> _onSignIn(SignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _repository.signInWithEmail(
      email: event.email,
      password: event.password,
    );
    result.when(
      ok: (user) => emit(Authenticated(user)),
      err: (failure) => emit(AuthError(failure)),
    );
  }

  Future<void> _onSignUp(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _repository.signUpWithEmail(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
    );
    result.when(
      ok: (user) => emit(Authenticated(user)),
      err: (failure) => emit(AuthError(failure)),
    );
  }

  Future<void> _onGoogleSignIn(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _repository.signInWithGoogle();
    result.when(
      ok: (user) => emit(Authenticated(user)),
      err: (failure) => emit(AuthError(failure)),
    );
  }

  Future<void> _onSignOut(SignOutRequested event, Emitter<AuthState> emit) async {
    await _repository.signOut();
    emit(const Unauthenticated());
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
