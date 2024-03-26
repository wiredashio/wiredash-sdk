import 'package:flutter/widgets.dart';
import 'package:wiredash/src/core/lifecycle/lifecycle_notifier.dart';
import 'package:wiredash/src/core/support/widget_binding_support.dart';

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
