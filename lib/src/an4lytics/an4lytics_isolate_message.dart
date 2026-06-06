import 'dart:isolate';

/// Message sent from a background isolate to the main isolate when analytics
/// events were saved and should be routed through a mounted Wiredash widget.
class AnalyticsIsolateMessage {
  const AnalyticsIsolateMessage({
    required this.projectId,
    required this.environment,
    required this.eventName,
    required this.submitImmediately,
  });

  /// Project id used to pick the matching mounted Wiredash widget.
  final String? projectId;

  /// Environment of the event, used only for diagnostics while routing.
  final String? environment;

  /// Event name used only for diagnostics while routing.
  final String eventName;

  /// Whether pending events should bypass the normal debounce and upload now.
  final bool submitImmediately;

  /// Parses a raw isolate payload.
  ///
  /// Throws when the payload is not the list shape produced by [toMessage].
  factory AnalyticsIsolateMessage.fromObject(Object? message) {
    if (message is! List<Object?>) {
      throw ArgumentError.value(message, 'message', 'Expected a list');
    }
    final eventName = message[2];
    if (eventName is! String) {
      throw ArgumentError.value(message, 'message', 'Missing eventName');
    }
    return AnalyticsIsolateMessage(
      projectId: message[0] as String?,
      environment: message[1] as String?,
      eventName: eventName,
      submitImmediately: message[3] == true,
    );
  }

  /// Converts this message into values that can be sent through a [SendPort].
  List<Object?> toMessage() {
    return [
      projectId,
      environment,
      eventName,
      submitImmediately,
    ];
  }
}
