import 'dart:async';
import 'dart:html';
import 'dart:js_util' as js_util;

import 'package:flutter/widgets.dart';
import 'package:wiredash/src/core/lifecycle/lifecycle_notifier.dart';

FlutterAppLifecycleNotifier createFlutterAppLifecycleNotifier() {
  final notifier = FlutterAppLifecycleNotifier();
  final notifierRef = WeakReference(notifier);

  notifier.value = readLifecycleState();

  void onStateChanged(Event _) {
    final notifier = notifierRef.target;
    if (notifier == null) {
      return;
    }
    notifier.value = readLifecycleState();
  }

  document.addEventListener('load', onStateChanged);
  window.addEventListener('focus', onStateChanged);
  window.addEventListener('blur', onStateChanged);
  document.addEventListener('visibilitychange', onStateChanged);

  notifier.addOnDisposeListener(() {
    // unregister listeners when notifier gets disposed
    document.removeEventListener('load', onStateChanged);
    window.removeEventListener('focus', onStateChanged);
    window.removeEventListener('blur', onStateChanged);
    document.removeEventListener('visibilitychange', onStateChanged);
  });

  _onHotRestart().then((_) {
    // Also unregister the listeners when the app is hot-restarted, or it will leak
    // resulting in one listener for each hot-restart (only on web)
    document.removeEventListener('load', onStateChanged);
    window.removeEventListener('focus', onStateChanged);
    window.removeEventListener('blur', onStateChanged);
    document.removeEventListener('visibilitychange', onStateChanged);
  });

  return notifier;
}

AppLifecycleState readLifecycleState() {
  if (document.hidden == true) {
    return AppLifecycleState_hidden_compat();
  }
  final focused = js_util.callMethod(document, 'hasFocus', []);
  if (focused == true) {
    return AppLifecycleState.resumed;
  }
  return AppLifecycleState.inactive;
}

/// Creates a Future that completes when the Flutter app is hot-restarted.
///
/// Flutter web replaces the <flutter-view> element when hot-restarting the app.
/// This function observes when a new <flutter-view> element is added to the DOM, and then completes
///
/// There is currently no clean way to get a hot-restart event https://github.com/flutter/flutter/issues/10437
Future<void> _onHotRestart() async {
  final Completer<void> completer = Completer<void>();

  // Use querySelector to find the 'flt-glass-pane' element and get its parent
  final Node? parentNode = querySelector('flutter-view')?.parent;

  // Ensure parentNode is not null
  if (parentNode == null) {
    completer.completeError('Could not find a <flutter-view> element');
    return;
  }

  final observer = MutationObserver((mutations, observer) {
    final typedMutations = mutations.cast<MutationRecord>();
    for (final MutationRecord mutation in typedMutations) {
      if (mutation.type == 'childList') {
        final addedNodes = mutation.addedNodes ?? <Node>[];
        for (final node in addedNodes) {
          if (node.nodeName == 'FLUTTER-VIEW') {
            completer.complete();
            observer.disconnect();
          }
        }
      }
    }
  });

  observer.observe(parentNode, childList: true, subtree: true);

  return completer.future;
}
