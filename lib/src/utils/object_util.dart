extension ObjectExt on Object? {
  // ignore: no_runtimetype_tostring
  String get instanceName => '$runtimeType@${hashCode.toRadixString(16)}';
}

/// Allows differentiation of default arguments from `null`
const Object defaultArgument = Object();
