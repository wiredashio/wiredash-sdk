import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Consumes all [FlutterError.onError] and [FlutterError.presentError] calls
/// during this test and makes them accessible as list for assertions.
FlutterErrors captureFlutterErrors() {
  final errors = FlutterErrors();
  final oldPresentHandler = FlutterError.presentError;
  FlutterError.presentError = (details) {
    errors._presentError.add(details);
  };
  addTearDown(() {
    FlutterError.presentError = oldPresentHandler;
  });

  final oldOnErrorHandler = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    errors._onError.add(details);
  };
  addTearDown(() {
    FlutterError.onError = oldOnErrorHandler;
  });

  return errors;
}

/// A summary of [FlutterError.onError] and [FlutterError.presentError] calls
class FlutterErrors {
  List<FlutterErrorDetails> get onError => List.unmodifiable(_onError);
  final List<FlutterErrorDetails> _onError = [];

  List<FlutterErrorDetails> get presentError =>
      List.unmodifiable(_presentError);
  final List<FlutterErrorDetails> _presentError = [];
}
