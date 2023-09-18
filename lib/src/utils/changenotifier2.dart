import 'package:flutter/foundation.dart';
import 'package:wiredash/src/utils/object_util.dart';

/// A [ChangeNotifier] but better
///
/// Features
/// - Doesn't crash when [dispose] is called multiple times
/// - Knows when disposed [isDisposed]
class ChangeNotifier2 implements ChangeNotifier {
  /// If true, the event [ObjectCreated] for this instance was dispatched to
  /// [MemoryAllocations].
  ///
  /// As [ChangedNotifier] is used as mixin, it does not have constructor,
  /// so we use [addListener] to dispatch the event.
  bool _creationDispatched = false;

  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  final List<void Function()> listeners = [];

  ChangeNotifier2() {
    if (_kFlutterMemoryAllocationsEnabled) {
      maybeDispatchObjectCreation();
    }
  }

  @override
  void addListener(void Function() listener) {
    if (isDisposed) {
      throw "$instanceName is already disposed.";
    }

    if (_kFlutterMemoryAllocationsEnabled) {
      maybeDispatchObjectCreation();
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
    if (kFlutterMemoryAllocationsEnabled && _creationDispatched) {
      MemoryAllocations.instance.dispatchObjectDisposed(object: this);
    }
  }

  @override
  bool get hasListeners => listeners.isNotEmpty;

  @override
  void notifyListeners() {
    final copy = listeners.reversed.toList();
    for (final listener in copy) {
      listener();
    }
  }

  /// Only notifies listeners when not disposed
  void safeNotifyListeners() {
    if (isDisposed) {
      return;
    }
    notifyListeners();
  }

  @override
  // ignore: override_on_non_overriding_member
  void maybeDispatchObjectCreation() {
    // Tree shaker does not include this method and the class MemoryAllocations
    // if kFlutterMemoryAllocationsEnabled is false.
    if (_kFlutterMemoryAllocationsEnabled && !_creationDispatched) {
      MemoryAllocations.instance.dispatchObjectCreated(
        library: 'package:wiredash/src/utils/changenotifier2.dart',
        className: '$ChangeNotifier2',
        object: this,
      );
      _creationDispatched = true;
    }
  }
}

const bool _kMemoryAllocations =
    bool.fromEnvironment('flutter.memory_allocations');

/// Copy of [kFlutterMemoryAllocationsEnabled] to be backwards compatible with
/// Flutter 3.13 and earlier
const bool _kFlutterMemoryAllocationsEnabled =
    _kMemoryAllocations || kDebugMode;
