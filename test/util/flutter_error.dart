import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

FlutterErrors captureFlutterErrors() {
  final errors = FlutterErrors();
  final oldPresentHandler = FlutterError.presentError;
  FlutterError.presentError = (details) {
    errors.presentError.add(details);
  };
  addTearDown(() {
    FlutterError.presentError = oldPresentHandler;
  });

  final oldOnErrorHandler = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    errors.onError.add(details);
  };
  addTearDown(() {
    FlutterError.onError = oldOnErrorHandler;
  });

  return errors;
}

class FlutterErrors {
  final List<FlutterErrorDetails> onError = [];
  final List<FlutterErrorDetails> presentError = [];
}
