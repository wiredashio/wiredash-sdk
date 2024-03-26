import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

class FlutterAppLifecycleNotifier extends ValueNotifier<AppLifecycleState> {
  FlutterAppLifecycleNotifier() : super(AppLifecycleState.detached);

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
