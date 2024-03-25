import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/analytics/event_store.dart';
import 'package:wiredash/src/core/network/send_events_request.dart';

/// Abstract interface for submitting events to the backend
///
/// Implementations are
/// - [DirectEventSubmitter] for immediate submission of events (usually web)
/// - [DebounceEventSubmitter] for batching events within a certain time frame (usually mobile)
abstract class EventSubmitter {
  /// Submits all pending events in [SharedPreferences] to the backend
  Future<void> submitEvents();
}

class DirectEventSubmitter extends DebounceEventSubmitter {
  DirectEventSubmitter({
    required super.eventStore,
    required super.api,
    required super.projectId,
  }) : super(throttleDuration: Duration.zero);
}

class DebounceEventSubmitter implements EventSubmitter {
  final AnalyticsEventStore eventStore;
  final WiredashApi api;
  final String Function() projectId;

  final Duration throttleDuration;

  DebounceEventSubmitter({
    required this.eventStore,
    required this.api,
    required this.projectId,
    this.throttleDuration = const Duration(seconds: 10),
  });

  @override
  Future<void> submitEvents() async {
    final projectId = this.projectId();
    // TODO check last sent event call.
    //  If is was less than 30 seconds ago, start timer
    //  else kick of sending events to backend for this projectId

    await eventStore.deleteOutdatedEvents();
    await eventStore.trimToDiskLimit();
    final toBeSubmitted = await eventStore.getEvents(projectId);

    if (toBeSubmitted.isEmpty) {
      return;
    }

    final List<RequestEvent> requestEvents = toBeSubmitted.values.map((event) {
      return RequestEvent(
        analyticsId: event.analyticsId,
        buildCommit: event.buildCommit,
        buildNumber: event.buildNumber,
        buildVersion: event.buildVersion,
        bundleId: event.bundleId,
        createdAt: event.createdAt,
        eventData: event.eventData,
        eventName: event.eventName,
        platformOS: event.platformOS,
        platformOSVersion: event.platformOSVersion,
        platformLocale: event.platformLocale,
        sdkVersion: event.sdkVersion,
      );
    }).toList();

    try {
      await api.sendEvents(requestEvents);
      for (final key in toBeSubmitted.keys) {
        await eventStore.removeEvent(key);
      }
    } on InvalidEventFormatException catch (e, stack) {
      reportWiredashInfo(
        e,
        stack,
        'Some events where rejected by the backend.',
      );
      for (final key in toBeSubmitted.keys) {
        await eventStore.removeEvent(key);
      }
    } catch (e, stack) {
      reportWiredashInfo(
        e,
        stack,
        'Could not submit events to backend. Retrying later.',
      );
    }
  }
}
