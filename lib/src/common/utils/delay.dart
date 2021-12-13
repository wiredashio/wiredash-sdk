import 'dart:async';

/// A cancellable version of [Future.delayed]
class Delay {
  Delay(this.duration, {this.errorOnDispose = false}) {
    _timer = Timer(duration, _afterDelay);
  }
  final Duration duration;

  /// When true, the [future] throws an error on complete. When false it never
  /// completes
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
    final timer = _timer;
    if (timer == null) {
      return;
    }
    timer.cancel();
    if (errorOnDispose) {
      _completer.completeError(DelayCancelledException());
    }
  }
}

class DelayCancelledException implements Exception {}
