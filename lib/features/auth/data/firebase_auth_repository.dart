import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/result/result.dart';
import '../domain/auth_repository.dart';
import '../domain/models/app_user.dart';
import '../domain/models/auth_failure.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  }) : _auth = firebaseAuth,
       _googleSignIn = googleSignIn;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().map(
      (user) => user == null ? null : _toAppUser(user),
    );
  }

  @override
  Future<Result<AppUser, AuthFailure>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Ok(_toAppUser(credential.user!));
    } on FirebaseAuthException catch (e) {
      return Err(_mapFirebaseException(e));
    } catch (_) {
      return const Err(UnknownAuthFailure());
    }
  }

  @override
  Future<Result<AppUser, AuthFailure>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(displayName);
      await credential.user?.reload();
      final refreshed = _auth.currentUser!;
      return Ok(_toAppUser(refreshed));
    } on FirebaseAuthException catch (e) {
      return Err(_mapFirebaseException(e));
    } catch (_) {
      return const Err(UnknownAuthFailure());
    }
  }

  @override
  Future<Result<AppUser, AuthFailure>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const Err(UnknownAuthFailure('Sign-in cancelled'));
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      return Ok(_toAppUser(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      return Err(_mapFirebaseException(e));
    } catch (_) {
      return const Err(UnknownAuthFailure());
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  AppUser _toAppUser(User user) {
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? user.email?.split('@').first ?? 'User',
      photoUrl: user.photoURL,
    );
  }

  AuthFailure _mapFirebaseException(FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-email' => const InvalidEmail(),
      'wrong-password' || 'invalid-credential' => const WrongPassword(),
      'user-not-found' => const UserNotFound(),
      'email-already-in-use' => const EmailAlreadyInUse(),
      'weak-password' => const WeakPassword(),
      'network-request-failed' => const NetworkFailure(),
      _ => UnknownAuthFailure(e.message),
    };
  }
}
