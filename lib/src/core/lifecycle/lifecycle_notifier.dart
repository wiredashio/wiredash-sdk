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
