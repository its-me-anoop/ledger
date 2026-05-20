import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/auth_repository.dart';
import '../../domain/models/app_user.dart';
import '../../../../features/profile/domain/models/user_profile.dart';
import '../../../../features/profile/domain/user_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this._repository, {
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<SignInRequested>(_onSignIn);
    on<SignUpRequested>(_onSignUp);
    on<GoogleSignInRequested>(_onGoogleSignIn);
    on<SignOutRequested>(_onSignOut);
  }

  final AuthRepository _repository;
  final UserRepository _userRepository;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    await emit.onEach<AppUser?>(
      _repository.authStateChanges(),
      onData: (user) async {
        if (user != null) {
          await _upsertUser(user);
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
    await result.when(
      ok: (user) async {
        await _upsertUser(user);
        emit(Authenticated(user));
      },
      err: (failure) async => emit(AuthError(failure)),
    );
  }

  Future<void> _onSignUp(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _repository.signUpWithEmail(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
    );
    await result.when(
      ok: (user) async {
        await _upsertUser(user);
        emit(Authenticated(user));
      },
      err: (failure) async => emit(AuthError(failure)),
    );
  }

  Future<void> _onGoogleSignIn(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _repository.signInWithGoogle();
    await result.when(
      ok: (user) async {
        await _upsertUser(user);
        emit(Authenticated(user));
      },
      err: (failure) async => emit(AuthError(failure)),
    );
  }

  Future<void> _onSignOut(SignOutRequested event, Emitter<AuthState> emit) async {
    await _repository.signOut();
    emit(const Unauthenticated());
  }

  Future<void> _upsertUser(AppUser user) async {
    // createdAt is managed server-side (set only on first write).
    // We pass DateTime.now() as a placeholder; the repository implementation
    // ignores it for existing docs and uses FieldValue.serverTimestamp() for
    // new ones — so no client clock is persisted for createdAt.
    final now = DateTime.now();
    await _userRepository.upsertUser(
      UserProfile(
        uid: user.uid,
        displayName: user.displayName,
        email: user.email,
        photoUrl: user.photoUrl,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

}
