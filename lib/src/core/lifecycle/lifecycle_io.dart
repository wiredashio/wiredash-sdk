import 'package:flutter/widgets.dart';
import 'package:wiredash/src/core/lifecycle/lifecycle_notifier.dart';
import 'package:wiredash/src/core/support/widget_binding_support.dart';

FlutterAppLifecycleNotifier createFlutterAppLifecycleNotifier() {
  final notifier = FlutterAppLifecycleNotifier();

  final state = widgetsBindingInstance.lifecycleState;
  if (state != null) {
    notifier.value = state;
  }

  // As of March 24, the supported platform are Android, iOS, macOS
  final appLifecycleListener = AppLifecycleListener(
    onStateChange: (state) {
      notifier.value = state;
    },
  );
  notifier.addOnDisposeListener(() {
    appLifecycleListener.dispose();
  });

  return notifier;
}
