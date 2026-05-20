import '../../../core/result/result.dart';
import 'models/app_user.dart';
import 'models/auth_failure.dart';

abstract interface class AuthRepository {
  Stream<AppUser?> authStateChanges();

  Future<Result<AppUser, AuthFailure>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Result<AppUser, AuthFailure>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  Future<Result<AppUser, AuthFailure>> signInWithGoogle();

  Future<void> signOut();
}
