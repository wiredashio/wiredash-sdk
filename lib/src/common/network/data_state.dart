abstract class DataState<T> {
  DataState();

  factory DataState.idle() => Idle<T>();

  factory DataState.loading() => Loading<T>();

  factory DataState.success(T response) => Success<T>(response);

  factory DataState.error(dynamic exception) => UncaughtException<T>(exception);

  bool get isIdle => this is Idle;

  bool get isLoading => this is Loading;

  bool get isIdleOrLoading => this is Idle || this is Loading;

  bool get isSuccess => this is Success;

  Success<T>? get success => this is Success ? this as Success<T> : null;

  bool get isError => this is UncaughtException;

  UncaughtException<T>? get error =>
      this is UncaughtException ? this as UncaughtException<T> : null;
}

class Idle<T> extends DataState<T> {
  Idle();
}

class Loading<T> extends DataState<T> {
  Loading();
}

class Success<T> extends DataState<T> {
  Success(this.response);

  final T response;
}

class UncaughtException<T> extends DataState<T> {
  UncaughtException(this.exception);

  final dynamic exception;
}
