import 'package:equatable/equatable.dart';

import '../../domain/models/app_user.dart';
import '../../domain/models/auth_failure.dart';

sealed class AuthState extends Equatable {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  List<Object?> get props => [];
}

final class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  List<Object?> get props => [];
}

final class Authenticated extends AuthState {
  const Authenticated(this.user);

  final AppUser user;

  @override
  List<Object?> get props => [user];
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();

  @override
  List<Object?> get props => [];
}

final class AuthError extends AuthState {
  const AuthError(this.failure);

  final AuthFailure failure;

  @override
  List<Object?> get props => [failure];
}
