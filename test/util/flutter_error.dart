import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Consumes all [FlutterError.onError] and [FlutterError.presentError] calls
/// during this test and makes them accessible as list for assertions.
FlutterErrors captureFlutterErrors() {
  final errors = FlutterErrors(FlutterError.onError, FlutterError.presentError);
  FlutterError.presentError = (details) {
    errors._presentError.add(details);
  };
  FlutterError.onError = (FlutterErrorDetails details) {
    errors._onError.add(details);
  };

  addTearDown(() {
    errors.restoreDefaultErrorHandlers();
  });

  return errors;
}

/// A summary of [FlutterError.onError] and [FlutterError.presentError] calls
class FlutterErrors {
  final FlutterExceptionHandler? _originalOnError;
  final FlutterExceptionHandler _originalPresentError;

  FlutterErrors(
    this._originalOnError,
    this._originalPresentError,
  );

  List<FlutterErrorDetails> get onError => List.unmodifiable(_onError);
  final List<FlutterErrorDetails> _onError = [];

  List<FlutterErrorDetails> get presentError =>
      List.unmodifiable(_presentError);
  final List<FlutterErrorDetails> _presentError = [];

  void restoreDefaultErrorHandlers() {
    FlutterError.onError = _originalOnError;
    FlutterError.presentError = _originalPresentError;
  }

  String get presentErrorText {
    final renderer = TextTreeRenderer(wrapWidth: 100000);
    return presentError.map((e) {
      return renderer.render(e.toDiagnosticsNode());
    }).join('\n');
  }
}
