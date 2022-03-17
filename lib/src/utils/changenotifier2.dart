import 'package:flutter/cupertino.dart';
import 'package:wiredash/src/utils/object_util.dart';

/// A [ChangeNotifier] but better
///
/// Features
/// - Doesn't crash when [dispose] is called multiple times
/// - Knows when disposed [isDisposed]
class ChangeNotifier2 implements ChangeNotifier {
  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  final List<void Function()> listeners = [];

  @override
  void addListener(void Function() listener) {
    if (isDisposed) {
      throw "$instanceName is already disposed.";
    }
    listeners.add(listener);
  }

  @override
  void removeListener(void Function() listener) {
    if (isDisposed) {
      return;
    }
    listeners.remove(listener);
  }

  @override
  @mustCallSuper
  void dispose() {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    listeners.clear();
  }

  @override
  bool get hasListeners => listeners.isNotEmpty;

  @override
  void notifyListeners() {
    final copy = listeners.reversed.toList();
    for (final listener in copy) {
      listener();
    }
    listeners.clear();
  }

  /// Only notifies listeners when not disposed
  void safeNotifyListeners() {
    if (isDisposed) {
      return;
    }
    notifyListeners();
  }
}
