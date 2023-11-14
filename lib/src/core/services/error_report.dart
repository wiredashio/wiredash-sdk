import 'package:flutter/foundation.dart';

/// Reports an error within wiredash to [FlutterError.onError], which is critical enough to fail tests
FlutterErrorDetails reportWiredashError(
  Object e,
  StackTrace stack,
  String message,
) {
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
FlutterErrorDetails reportWiredashInfo(
  Object e,
  StackTrace stack,
  String message,
) {
  final details = FlutterErrorDetails(
    exception: e,
    stack: stack,
    library: 'wiredash',
    informationCollector: () => [
      DiagnosticsNode.message(message),
    ],
  );

  final reporter = FlutterError.presentError;
  reporter.call(details);
  return details;
}
