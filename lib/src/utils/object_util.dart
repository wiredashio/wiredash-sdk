import 'dart:async';

extension ObjectExt on Object? {
  // ignore: no_runtimetype_tostring
  String get instanceName => '$runtimeType@${hashCode.toRadixString(16)}';
}

/// Allows differentiation of default arguments from `null`
const Object defaultArgument = Object();

extension FutureOrExt<T> on FutureOr<T> {
  Future<T> asFuture() {
    return this is Future<T> ? this as Future<T> : Future.value(this as T);
  }
}

extension MapResult1<R, A1> on R Function(A1) {
  T Function(A1) map<T>(T Function(R) mapper) {
    return (it) => mapper(this(it));
  }
}
