import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
}

final class AuthStarted extends AuthEvent {
  const AuthStarted();

  @override
  List<Object?> get props => [];
}

final class SignInRequested extends AuthEvent {
  const SignInRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class SignUpRequested extends AuthEvent {
  const SignUpRequested({
    required this.email,
    required this.password,
    required this.displayName,
  });

  final String email;
  final String password;
  final String displayName;

  @override
  List<Object?> get props => [email, password, displayName];
}

final class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();

  @override
  List<Object?> get props => [];
}

final class SignOutRequested extends AuthEvent {
  const SignOutRequested();

  @override
  List<Object?> get props => [];
}
