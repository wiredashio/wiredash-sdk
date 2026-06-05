import 'dart:isolate';
import 'dart:ui';

/// Name under which the main isolate publishes its analytics wake-up port in the
/// process-wide [IsolateNameServer]. See `isolate_messenger.dart`.
const String _portName = 'io.wiredash.analytics.events';

ReceivePort? _receivePort;

/// Publishes the main isolate's wake-up port and runs [onEvent] with the pinged
/// event's `projectId`, `environment` and `eventName`.
void registerMainIsolateAnalyticsListener(
  void Function(String? projectId, String? environment, String eventName)
      onEvent,
) {
  if (_receivePort != null) {
    // Already listening. [onEvent] routes to the matching instance, so a single
    // registration is enough regardless of how many widgets mount.
    return;
  }
  final port = ReceivePort();
  // Drop a mapping left over from a previous run (e.g. after a hot restart),
  // otherwise registering the new port would fail.
  IsolateNameServer.removePortNameMapping(_portName);
  final registered =
      IsolateNameServer.registerPortWithName(port.sendPort, _portName);
  if (!registered) {
    port.close();
    return;
  }
  _receivePort = port;
  port.listen((message) {
    try {
      // The port name is process-global, so ignore anything that isn't the
      // [projectId, environment, eventName] shape we send.
      final list = message as List<Object?>;
      onEvent(list[0] as String?, list[1] as String?, list[2]! as String);
    } catch (_) {
      // Malformed message from a foreign sender; ignore it.
    }
  });
}

/// Removes the main isolate's wake-up port.
void unregisterMainIsolateAnalyticsListener() {
  IsolateNameServer.removePortNameMapping(_portName);
  _receivePort?.close();
  _receivePort = null;
}

/// Pings the main isolate from a background isolate.
void notifyMainIsolateOfNewEvent(
  String? projectId,
  String? environment,
  String eventName,
) {
  final sendPort = IsolateNameServer.lookupPortByName(_portName);
  sendPort?.send(<Object?>[projectId, environment, eventName]);
}
