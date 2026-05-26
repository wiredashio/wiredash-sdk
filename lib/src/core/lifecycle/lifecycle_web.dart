import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;
import 'package:wiredash/src/core/lifecycle/lifecycle_notifier.dart';

/// Creates a web version of [FlutterAppLifecycleNotifier] that is connected
/// to the web app lifecycle. It is compatible with Flutter versions before
/// Flutter 3.22, where it was added natively to the [WidgetsBindingObserver]
/// lifecycle callback (https://github.com/flutter/engine/pull/44720/)
FlutterAppLifecycleNotifier createFlutterAppLifecycleNotifierWebBackport() {
  final notifier = FlutterAppLifecycleNotifier();
  final notifierRef = WeakReference(notifier);

  notifier.value = readLifecycleState();

  void onStateChanged(web.Event _) {
    final notifier = notifierRef.target;
    if (notifier == null) {
      return;
    }
    notifier.value = readLifecycleState();
  }

  final listener = onStateChanged.toJS;

  web.document.addEventListener('load', listener);
  web.window.addEventListener('focus', listener);
  web.window.addEventListener('blur', listener);
  web.document.addEventListener('visibilitychange', listener);

  void removeAllListeners() {
    web.document.removeEventListener('load', listener);
    web.window.removeEventListener('focus', listener);
    web.window.removeEventListener('blur', listener);
    web.document.removeEventListener('visibilitychange', listener);
  }

  notifier.addOnDisposeListener(removeAllListeners);

  _onHotRestart().then((_) {
    // Also unregister the listeners when the app is hot-restarted, or it will leak
    // resulting in one listener for each hot-restart (only on web)
    removeAllListeners();
  });

  return notifier;
}

AppLifecycleState readLifecycleState() {
  if (web.document.hidden) {
    return AppLifecycleState.hidden;
  }
  if (web.document.hasFocus()) {
    return AppLifecycleState.resumed;
  }
  return AppLifecycleState.inactive;
}

/// Creates a Future that completes when the Flutter app is hot-restarted.
///
/// Flutter web replaces the `<flutter-view>` element when hot-restarting the app.
/// This function observes when a new `<flutter-view>` element is added to the DOM, and then completes
///
/// There is currently no clean way to get a hot-restart event https://github.com/flutter/flutter/issues/10437
Future<void> _onHotRestart() async {
  final Completer<void> completer = Completer<void>();

  final web.Node? parentNode =
      web.document.querySelector('flutter-view')?.parentNode;

  if (parentNode == null) {
    completer.completeError('Could not find a <flutter-view> element');
    return;
  }

  late final web.MutationObserver observer;
  observer = web.MutationObserver(
    (JSArray<web.MutationRecord> entries, web.MutationObserver _) {
      for (var i = 0; i < entries.toDart.length; i++) {
        final mutation = entries.toDart[i];
        if (mutation.type != 'childList') {
          continue;
        }
        final addedNodes = mutation.addedNodes;
        for (var j = 0; j < addedNodes.length; j++) {
          final node = addedNodes.item(j);
          if (node != null && node.nodeName == 'FLUTTER-VIEW') {
            completer.complete();
            observer.disconnect();
            return;
          }
        }
      }
    }.toJS,
  );

  observer.observe(
    parentNode,
    web.MutationObserverInit(childList: true, subtree: true),
  );

  return completer.future;
}
