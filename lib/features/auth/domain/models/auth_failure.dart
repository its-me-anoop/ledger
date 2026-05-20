sealed class AuthFailure {
  const AuthFailure();
}

final class InvalidEmail extends AuthFailure {
  const InvalidEmail();
}

final class WrongPassword extends AuthFailure {
  const WrongPassword();
}

final class UserNotFound extends AuthFailure {
  const UserNotFound();
}

final class EmailAlreadyInUse extends AuthFailure {
  const EmailAlreadyInUse();
}

final class WeakPassword extends AuthFailure {
  const WeakPassword();
}

final class NetworkFailure extends AuthFailure {
  const NetworkFailure();
}

final class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure([this.message]);
  final String? message;
}
