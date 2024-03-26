import 'dart:async';

/// A cancellable version of [Future.delayed]
class Delay {
  Delay(this.duration, {this.errorOnDispose = false}) {
    if (duration == Duration.zero) {
      _completer.complete();
    } else {
      _timer = Timer(duration, _afterDelay);
    }
  }

  final Duration duration;

  /// When true, the [future] throws an error on dispose.
  /// When false the [future] never completes in case of dispose.
  final bool errorOnDispose;

  Timer? _timer;
  final Completer<void> _completer = Completer<void>();

  void _afterDelay() {
    _completer.complete();
    _timer = null;
  }

  Future<void> get future {
    return _completer.future;
  }

  void dispose() {
    _timer?.cancel();
    if (!_completer.isCompleted) {
      if (errorOnDispose) {
        _completer.completeError(DelayCancelledException());
      } else {
        // let future run forever, never complete or error
      }
    }
  }
}

class DelayCancelledException implements Exception {}
