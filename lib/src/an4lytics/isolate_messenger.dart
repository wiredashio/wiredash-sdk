/// Wakes the main isolate when a background isolate records an analytics event.
///
/// A background isolate (e.g. one spawned via `compute`) only buffers events to
/// disk; it has no shared memory with the main isolate that uploads them.
/// Without a signal the events would wait for the next app lifecycle trigger
/// (app backgrounded, restarted, or another main-isolate event) — which can be
/// hours or days on a long-lived foreground session, exceeding the event TTL.
///
/// The main isolate publishes a port via [registerMainIsolateAnalyticsListener];
/// a background isolate pings it via [notifyMainIsolateOfAnalyticsEvent], which
/// makes the main isolate reload pending events from disk and upload them.
///
/// No-op on the web, which has no background isolates (the io variant uses
/// `IsolateNameServer`).
library;

import 'package:wiredash/src/an4lytics/an4lytics_isolate_message.dart';
import 'package:wiredash/src/utils/disposable.dart';

/// Publishes the main isolate's wake-up port.
///
/// The listener is kept alive until the returned disposable is disposed.
Disposable registerMainIsolateAnalyticsListener() {
  return Disposable(() {});
}

/// Pings the main isolate from a background isolate so it routes and uploads
/// pending events. No-op if no main isolate has registered a listener.
void notifyMainIsolateOfAnalyticsEvent(AnalyticsIsolateMessage message) {}
