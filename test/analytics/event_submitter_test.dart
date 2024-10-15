import 'package:async/async.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:wiredash/src/analytics/event_store.dart';
import 'package:wiredash/src/analytics/event_submitter.dart';
import 'package:wiredash/src/core/version.dart';

import '../util/mock_api.dart';
import '../util/wiredash_tester.dart';

void main() {
  group('DebounceEventSubmitter', () {
    testWidgets('sends initial event after initialThrottleDuration',
        (tester) async {
      final store = InMemoryEventStore.withDefaults();
      final api = MockWiredashApi();
      final DebounceEventSubmitter submitter = DebounceEventSubmitter(
        eventStore: store,
        api: api,
        projectId: () => 'project-abc',
        initialThrottleDuration: const Duration(days: 1),
      );
      addTearDown(() => submitter.dispose());

      await store.saveEvent(
        AnalyticsEvent(
          eventName: 'test',
          analyticsId: nanoid(length: 16),
          createdAt: clock.now(),
          sdkVersion: wiredashSdkVersion,
        ),
        'project-abc',
      );

      // start debounce timer
      final future = ResultFuture(submitter.submitEvents());
      await tester.pump(const Duration(hours: 23));
      expect(api.sendEventsInvocations.invocations, isEmpty);
      await tester.pump(const Duration(hours: 1));
      expect(api.sendEventsInvocations.invocations, hasLength(1));
      expect(future.isComplete, isTrue);
    });

    testWidgets('cancel timer after dispose', (tester) async {
      final store = InMemoryEventStore.withDefaults();
      final api = MockWiredashApi();
      final DebounceEventSubmitter submitter = DebounceEventSubmitter(
        eventStore: store,
        api: api,
        projectId: () => 'project-abc',
        initialThrottleDuration: const Duration(days: 1),
      );

      await store.saveEvent(
        AnalyticsEvent(
          eventName: 'test',
          analyticsId: nanoid(length: 16),
          createdAt: clock.now(),
          sdkVersion: wiredashSdkVersion,
        ),
        'project-abc',
      );

      // start debounce timer
      final future = ResultFuture(submitter.submitEvents());
      await tester.pumpSmart(minimumDuration: const Duration(seconds: 10));

      expect(api.sendEventsInvocations.invocations, isEmpty);

      // cancel timer
      submitter.dispose();

      // future never completes
      expect(future.isComplete, isFalse);

      // does not send any events
      await tester.pumpSmart(minimumDuration: const Duration(seconds: 30));
      expect(api.sendEventsInvocations.invocations, isEmpty);
    });
  });
}

class InMemoryEventStore implements AnalyticsEventStore {
  final Map<String, AnalyticsEvent> _events = {};

  // ignore: unreachable_from_main
  InMemoryEventStore({
    required this.cutOffAfter,
    required this.maximumDiskSizeInBytes,
  });

  InMemoryEventStore.withDefaults()
      : cutOffAfter = const Duration(days: 30),
        maximumDiskSizeInBytes = 1024 * 1024;

  final Duration cutOffAfter;
  final int maximumDiskSizeInBytes;

  @override
  Future<void> deleteOutdatedEvents() async {
    _events.removeWhere((key, value) {
      final cutOff = clock.now().subtract(cutOffAfter);
      return value.createdAt!.isBefore(cutOff);
    });
  }

  @override
  Future<Map<String, AnalyticsEvent>> getEvents(String? projectId) async {
    return Map.fromEntries(
      _events.entries.where((element) {
        return element.key.startsWith(projectId ?? 'default');
      }),
    );
  }

  @override
  Future<void> removeEvent(String key) async {
    _events.remove(key);
  }

  @override
  Future<void> saveEvent(AnalyticsEvent event, String? projectId) async {
    final project = projectId ?? 'default';
    _events['$project-${_count++}'] = event;
  }

  static int _count = 0;

  @override
  Future<void> trimToDiskLimit() async {
    // noop
  }

  @override
  Future<void> wipe() async {
    _events.clear();
  }
}
