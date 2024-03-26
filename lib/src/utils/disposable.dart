/// A disposable resource
abstract class Disposable {
  void dispose();

  bool get isDisposed;

  factory Disposable(void Function() dispose) {
    return _Disposable(dispose);
  }
}

class _Disposable implements Disposable {
  _Disposable(this.callback);

  final void Function() callback;

  bool _disposed = false;

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    callback();
  }

  @override
  bool get isDisposed => _disposed;
}
