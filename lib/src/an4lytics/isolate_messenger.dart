/// Wakes the main isolate when a background isolate records an analytics event.
///
/// A background isolate (e.g. one spawned via `compute`) only buffers events to
/// disk; it has no shared memory with the main isolate that uploads them.
/// Without a signal the events would wait for the next app lifecycle trigger
/// (app backgrounded, restarted, or another main-isolate event) — which can be
/// hours or days on a long-lived foreground session, exceeding the event TTL.
///
/// The main isolate publishes a port via [registerMainIsolateAnalyticsListener];
/// a background isolate pings it via [notifyMainIsolateOfNewEvent], which makes
/// the main isolate reload pending events from disk and upload them.
///
/// No-op on the web, which has no background isolates (the io variant uses
/// `IsolateNameServer`).
library;

/// Publishes the main isolate's wake-up port and runs [onEvent] with the pinged
/// event's `projectId`, `environment` and `eventName` on each ping.
///
/// Idempotent: the first registration handles any number of Wiredash widgets.
void registerMainIsolateAnalyticsListener(
  void Function(String? projectId, String? environment, String eventName)
      onEvent,
) {}

/// Removes the main isolate's wake-up port. Call when the last Wiredash widget
/// is disposed.
void unregisterMainIsolateAnalyticsListener() {}

/// Pings the main isolate from a background isolate so it routes and uploads the
/// just-saved event. No-op if no main isolate has registered a listener.
void notifyMainIsolateOfNewEvent(
  String? projectId,
  String? environment,
  String eventName,
) {}
