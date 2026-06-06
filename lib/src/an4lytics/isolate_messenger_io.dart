import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:wiredash/src/an4lytics/an4lytics_isolate_message.dart';
import 'package:wiredash/src/an4lytics/an4lytics_upload_router.dart';
import 'package:wiredash/src/core/services/error_report.dart';
import 'package:wiredash/src/utils/disposable.dart';

/// Name under which the main isolate publishes its analytics wake-up port in the
/// process-wide [IsolateNameServer]. See `isolate_messenger.dart`.
const String _portName = 'io.wiredash.analytics.events';

ReceivePort? _receivePort;
final _registrations = <Object, StackTrace>{};

/// Publishes the main isolate's wake-up port.
Disposable registerMainIsolateAnalyticsListener() {
  final token = Object();
  _registrations[token] = StackTrace.current;
  if (_receivePort != null) {
    // Already listening. Keep the shared port alive until this registration is
    // disposed too.
    return Disposable(() => _disposeMainIsolateAnalyticsListener(token));
  }
  final port = ReceivePort();
  // Drop a mapping left over from a previous run (e.g. after a hot restart),
  // otherwise registering the new port would fail.
  IsolateNameServer.removePortNameMapping(_portName);
  final registered =
      IsolateNameServer.registerPortWithName(port.sendPort, _portName);
  if (!registered) {
    _registrations.remove(token);
    port.close();
    return Disposable(() {});
  }
  _receivePort = port;
  port.listen((message) {
    final AnalyticsIsolateMessage analyticsMessage;
    try {
      // The port name is process-global, so ignore anything that isn't the
      // [projectId, environment, eventName] shape we send.
      analyticsMessage = AnalyticsIsolateMessage.fromObject(message);
    } catch (e, stack) {
      reportWiredashInfo(
        e,
        stack,
        'Received malformed analytics isolate message: $message',
      );
      return;
    }
    if (_registrations.isEmpty) {
      return;
    }
    final registeredAt = _registrations.values.first;
    unawaited(_notifyMatchingWiredashInstance(analyticsMessage, registeredAt));
  });
  return Disposable(() => _disposeMainIsolateAnalyticsListener(token));
}

void _disposeMainIsolateAnalyticsListener(Object token) {
  _registrations.remove(token);
  if (_registrations.isNotEmpty) {
    return;
  }
  IsolateNameServer.removePortNameMapping(_portName);
  _receivePort?.close();
  _receivePort = null;
}

/// Pings the main isolate from a background isolate.
void notifyMainIsolateOfAnalyticsEvent(AnalyticsIsolateMessage message) {
  _sendMainIsolateAnalyticsMessage(message.toMessage());
}

@visibleForTesting
void sendRawMainIsolateAnalyticsMessage(Object? message) {
  _sendMainIsolateAnalyticsMessage(message);
}

void _sendMainIsolateAnalyticsMessage(Object? message) {
  final sendPort = IsolateNameServer.lookupPortByName(_portName);
  sendPort?.send(message);
}

Future<void> _notifyMatchingWiredashInstance(
  AnalyticsIsolateMessage message,
  StackTrace registeredAt,
) async {
  try {
    await notifyMatchingWiredashInstance(message);
  } catch (e, stack) {
    reportWiredashInfo(
      e,
      stack,
      'Analytics isolate message routing failed. '
      'The listener was registered at:\n$registeredAt',
    );
  }
}
