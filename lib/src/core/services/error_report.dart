import 'dart:io';

import 'package:flutter/foundation.dart';

/// Reports an user errors, that can be resolved by the developer.
///
/// These errors are critical enough to fail tests.
/// For notices, warnings and other information use [reportWiredashInfo].
///
/// The report will be delegated to [FlutterError.onError].
FlutterErrorDetails reportWiredashError(
  Object e,
  StackTrace stack,
  String message,
) {
  if (isInFlutterTest()) {
    // never fail tests
    return reportWiredashInfo(e, stack, message);
  }
  final details = FlutterErrorDetails(
    exception: e,
    stack: stack,
    library: 'wiredash',
    informationCollector: () => [
      DiagnosticsNode.message(message),
    ],
  );

  final reporter = FlutterError.onError;
  if (reporter != null) {
    reporter.call(details);
  }
  return details;
}

/// Reports to the developer and dumps the information into the console
///
/// Does not fail tests, but reports the information to the console.
FlutterErrorDetails reportWiredashInfo(
  Object e,
  StackTrace stack,
  String message, {
  bool ignoreInTests = false,
}) {
  final details = FlutterErrorDetails(
    exception: e,
    stack: stack,
    library: 'wiredash',
    informationCollector: () => [
      DiagnosticsNode.message(message),
    ],
  );
  if (ignoreInTests && isInFlutterTest()) {
    return details;
  }
  final reporter = FlutterError.presentError;
  reporter.call(details);
  return details;
}

bool isInFlutterTest() {
  return Platform.environment.containsKey('FLUTTER_TEST');
}
