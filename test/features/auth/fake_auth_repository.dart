import 'package:ledger/core/result/result.dart';
import 'package:ledger/features/auth/domain/auth_repository.dart';
import 'package:ledger/features/auth/domain/models/app_user.dart';
import 'package:ledger/features/auth/domain/models/auth_failure.dart';

const _fakeUser = AppUser(
  uid: 'uid-1',
  email: 'test@example.com',
  displayName: 'Test User',
);

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.authStreamValues = const [null],
    Result<AppUser, AuthFailure>? signInResult,
    Result<AppUser, AuthFailure>? signUpResult,
    Result<AppUser, AuthFailure>? googleResult,
  })  : _signInResult = signInResult ?? const Ok(_fakeUser),
        _signUpResult = signUpResult ?? const Ok(_fakeUser),
        _googleResult = googleResult ?? const Ok(_fakeUser);

  final List<AppUser?> authStreamValues;
  final Result<AppUser, AuthFailure> _signInResult;
  final Result<AppUser, AuthFailure> _signUpResult;
  final Result<AppUser, AuthFailure> _googleResult;

  bool signedOut = false;

  @override
  Stream<AppUser?> authStateChanges() => Stream.fromIterable(authStreamValues);

  @override
  Future<Result<AppUser, AuthFailure>> signInWithEmail({
    required String email,
    required String password,
  }) async => _signInResult;

  @override
  Future<Result<AppUser, AuthFailure>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async => _signUpResult;

  @override
  Future<Result<AppUser, AuthFailure>> signInWithGoogle() async => _googleResult;

  @override
  Future<void> signOut() async => signedOut = true;
}
