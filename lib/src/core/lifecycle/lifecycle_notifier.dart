import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:wiredash/src/core/lifecycle/lifecycle_stub.dart'
    if (dart.library.html) 'package:wiredash/src/core/lifecycle/lifecycle_web.dart';
import 'package:wiredash/src/core/support/widget_binding_support.dart';

/// Exposes [AppLifecycleState] on all flutter supported platforms, including web.
class FlutterAppLifecycleNotifier extends ValueNotifier<AppLifecycleState> {
  /// Returns a version that does not notify by default. It's the creators responsibility to call [value] when needed.
  FlutterAppLifecycleNotifier() : super(AppLifecycleState.detached);

  /// Returns a [FlutterAppLifecycleNotifier] that is connected to the Flutter app lifecycle.
  factory FlutterAppLifecycleNotifier.connected() {
    if (kIsWeb && _isBeforeFlutter3_22()) {
      return createFlutterAppLifecycleNotifierWebBackport();
    }
    return createFlutterAppLifecycleNotifier();
  }

  final List<void Function()> _disposeListeners = [];

  void addOnDisposeListener(void Function() listener) {
    _disposeListeners.add(listener);
  }

  void removeOnDisposeListener(void Function() listener) {
    _disposeListeners.remove(listener);
  }

  @override
  void dispose() {
    for (final listener in _disposeListeners.reversed) {
      listener();
    }
    super.dispose();
  }
}

/// Returns true if the current Flutter version is 3.22 or later
bool _isBeforeFlutter3_22() {
  final dynamic searchAnchor = SearchAnchor(
    builder: (context, c) => const SizedBox(),
    suggestionsBuilder: (context, c) async => [],
  );
  try {
    // this property was added in 3.19.0-8.0.pre https://github.com/flutter/flutter/pull/141223
    // ignore: unnecessary_statements, avoid_dynamic_calls
    searchAnchor.headerHeight;
    return false;
  } catch (e) {
    return true;
  }
}

/// A backwards compatible version of AppLifecycleState.hidden,
/// which returns AppLifecycleState.inactive for Flutter 3.13 and below
// ignore: non_constant_identifier_names
AppLifecycleState AppLifecycleState_hidden_compat() {
  // The hidden state was added in Flutter 3.13
  final AppLifecycleState? hidden = AppLifecycleState.values
      .firstWhereOrNull((element) => element.name == 'hidden');
  // for earlier flutter versions, fallback to inactive
  return hidden ?? AppLifecycleState.inactive;
}

/// Creates a [FlutterAppLifecycleNotifier] connected to [WidgetsBindingObserver]
///
/// It does not support web, before Flutter 3.22. Use [createFlutterAppLifecycleNotifierWebBackport] instead.
FlutterAppLifecycleNotifier createFlutterAppLifecycleNotifier() {
  final notifier = FlutterAppLifecycleNotifier();

  final state = widgetsBindingInstance.lifecycleState;
  if (state != null) {
    notifier.value = state;
  }

  // Can't use AppLifecycleListener, as it was introduced in Flutter3.13
  final observer = LifecycleChangeObserver((state) {
    notifier.value = state;
  });
  widgetsBindingInstance.addObserver(observer);

  notifier.addOnDisposeListener(() {
    widgetsBindingInstance.removeObserver(observer);
  });

  return notifier;
}

class LifecycleChangeObserver extends WidgetsBindingObserver {
  final void Function(AppLifecycleState) onAppLifecycleStateChange;

  LifecycleChangeObserver(
    this.onAppLifecycleStateChange,
  );

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // As of Flutter 3.21, this callback is only supported on Android, iOS, macOS
    onAppLifecycleStateChange(state);
  }
}
