sealed class Result<T, E> {
  const Result();

  R when<R>({
    required R Function(T value) ok,
    required R Function(E error) err,
  }) {
    return switch (this) {
      Ok<T, E>(:final value) => ok(value),
      Err<T, E>(:final error) => err(error),
    };
  }

  bool get isOk => this is Ok<T, E>;
  bool get isErr => this is Err<T, E>;
}

final class Ok<T, E> extends Result<T, E> {
  const Ok(this.value);
  final T value;
}

final class Err<T, E> extends Result<T, E> {
  const Err(this.error);
  final E error;
}
