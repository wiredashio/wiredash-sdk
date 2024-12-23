import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:wiredash/src/core/wiredash_widget.dart';
import 'package:wiredash/src/utils/disposable.dart';

/// Holds weak references to the [WiredashState] of all currently mounted
/// Wiredash widgets to send updates to all of them
class WiredashRegistry {
  WiredashRegistry._();

  /// Returns the singleton instance of the [WiredashRegistry]
  ///
  /// Technically, this class is a singleton with all of its bad behaviors.
  /// Assuming that widgets tests do not run in parallel on the same isolate,
  /// this singleton does not cause any issues. When the Wiredash widget is
  /// removed from the widget tree, which happens automatically at the end of
  /// every [testWidgets] test, it is removed automatically from the registry.
  /// Additionally, the registry only holds weak references to the widget states.
  static final WiredashRegistry instance = WiredashRegistry._();

  final List<WeakReference<WiredashState>> _refs = [];

  final Finalizer<Disposable> _finalizer = Finalizer((d) => d.dispose());

  /// Register all [Wiredash] widget state to eventually receive updates
  ///
  /// The order of registration is important.
  ///
  /// The returned Disposable unregisters the [WiredashState] instance from the
  /// registry.
  Disposable register(WiredashState state) {
    if (allWidgets.contains(state)) {
      throw StateError('WiredashState $state is already registered');
    }

    final elementRef = WeakReference(state);
    _refs.add(elementRef);

    // cleanup when the context becomes inaccessible
    _finalizer.attach(
      state.context,
      // the context has been garbage collected, clean up in case
      // the dispose method was not called
      Disposable(() {
        _refs.remove(elementRef);
      }),
    );

    // dispose called manually
    return Disposable(() {
      _refs.remove(elementRef);
    });
  }

  List<WiredashState> get allWidgets {
    purge();
    // Switch to .nonNulls when minSdk is Dart 3.0
    // ignore: deprecated_member_use
    return _refs.map((ref) => ref.target).whereNotNull().toList();
  }

  /// Clears all references
  ///
  /// This method should never been used unless there is a bug in the sdk or
  /// eventually for testing purposes
  ///
  /// Once cleared, all referenced Wiredash widgets will no longer be able to
  /// receive updates via [forEach].
  @visibleForTesting
  void clear() {
    _refs.clear();
  }

  /// Removes all inaccessible references, Widgets that have already been garbage collected
  void purge() {
    for (final ref in _refs) {
      final state = ref.target;
      if (state == null) {
        _refs.remove(ref);
      }
    }
  }
}

extension WiredashRegistryExt on WiredashRegistry {
  int get referenceCount => allWidgets.length;

  List<WiredashState> findByProjectId(String projectId) {
    purge();
    return _refs
        .map((ref) => ref.target)
        .where((state) => state?.widget.projectId == projectId)
        // Switch to .nonNulls when minSdk is Dart 3.0
        // ignore: deprecated_member_use
        .whereNotNull()
        .toList();
  }
}
