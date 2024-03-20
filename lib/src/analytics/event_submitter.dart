import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/analytics/event_store.dart';
import 'package:wiredash/src/core/network/send_events_request.dart';
import 'package:wiredash/src/core/network/wiredash_api.dart';

/// Abstract interface for submitting events to the backend
///
/// Implementations are
/// - [DirectEventSubmitter] for immediate submission of events (usually web)
/// - [PendingEventSubmitter] for batching events within a certain time frame (usually mobile)
abstract class EventSubmitter {
  /// Submits all pending events in [SharedPreferences] to the backend
  Future<void> submitEvents();
}

class DirectEventSubmitter extends PendingEventSubmitter {
  DirectEventSubmitter({
    required super.eventStore,
    required super.api,
    required super.projectId,
  }) : super(throttleDuration: Duration.zero);
}

class PendingEventSubmitter implements EventSubmitter {
  final AnalyticsEventStore eventStore;
  final WiredashApi api;
  final String Function() projectId;

  final Duration throttleDuration;

  PendingEventSubmitter({
    required this.eventStore,
    required this.api,
    required this.projectId,
    this.throttleDuration = const Duration(seconds: 10),
  });

  @override
  Future<void> submitEvents() async {
    final projectId = this.projectId();
    print('Submitting events for $projectId');
    // TODO check last sent event call.
    //  If is was less than 30 seconds ago, start timer
    //  else kick of sending events to backend for this projectId

    await eventStore.deleteOutdatedEvents();
    await eventStore.trimToDiskLimit();
    final toBeSubmitted = await eventStore.getEvents(projectId);

    print('Found ${toBeSubmitted.length} events for submission');
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
      print('Submitted ${toBeSubmitted.length} events');
      for (final key in toBeSubmitted.keys) {
        await eventStore.removeEvent(key);
      }
    } on InvalidEventFormatException catch (e) {
      print('Received error when sending events: $e');
      print('Deleting all events');
      for (final key in toBeSubmitted.keys) {
        await eventStore.removeEvent(key);
      }
    } catch (e) {
      print('Received error when sending events: $e');
      print('Retrying at a later time');
    }
  }
}
