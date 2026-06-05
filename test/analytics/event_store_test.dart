import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/an4lytics/ev3nt_file_store.dart';
import 'package:wiredash/src/an4lytics/ev3nt_store.dart';

import '../util/flutter_error.dart';

void main() {
  FileAnalyticsEventStore createStore(
    FileSystem fs, {
    Future<SharedPreferences> Function()? sharedPreferences,
  }) {
    return FileAnalyticsEventStore(
      fileSystem: fs,
      directoryProvider: () async => '/support',
      sharedPreferences: sharedPreferences,
    );
  }

  test('saves and reads an event back', () async {
    final store = createStore(MemoryFileSystem.test());
    await store.saveEvent(_event(eventName: 'click'), null);

    final events = await store.getEvents(null);
    expect(events, hasLength(1));
    expect(events.values.single.eventName, 'click');
  });

  // The reason this store exists: a second store instance (= another isolate)
  // reading the same backing directory sees an event the first one just wrote,
  // with no stale per-isolate cache in between.
  test('a second store instance sees an event the first one wrote', () async {
    final fs = MemoryFileSystem.test();
    final isolateA = createStore(fs);
    final isolateB = createStore(fs);

    expect(await isolateB.getEvents(null), isEmpty);

    await isolateA.saveEvent(_event(eventName: 'from_other_isolate'), null);

    final events = await isolateB.getEvents(null);
    expect(events, hasLength(1));
    expect(events.values.single.eventName, 'from_other_isolate');
  });

  test('removeEvent deletes the event', () async {
    final store = createStore(MemoryFileSystem.test());
    await store.saveEvent(_event(), null);
    final key = (await store.getEvents(null)).keys.single;

    await store.removeEvent(key);

    expect(await store.getEvents(null), isEmpty);
  });

  test('ignores and removes an unparsable event file', () async {
    final fs = MemoryFileSystem.test();
    final store = createStore(fs);
    final dir = fs.directory('/support/wiredash/events')
      ..createSync(recursive: true);
    const key = 'io.wiredash.events.default|1234567890|abcdef';
    final file = dir.childFile('${Uri.encodeComponent(key)}.json')
      ..writeAsStringSync('{"invalid": "event"}');

    final errors = captureFlutterErrors();
    final events = await store.getEvents(null);
    errors.restoreDefaultErrorHandlers();

    expect(events, isEmpty);
    expect(errors.warningText, contains('Error when parsing event $key'));
    expect(
      file.existsSync(),
      isFalse,
      reason: 'invalid file should be removed',
    );
  });

  test('deleteOutdatedEvents removes events older than 3 days', () async {
    final now = DateTime.utc(2024, 6, 5);
    await withClock(Clock.fixed(now), () async {
      final store = createStore(MemoryFileSystem.test());
      await store.saveEvent(
        _event(createdAt: now.subtract(const Duration(days: 4))),
        null,
      );
      await store.saveEvent(_event(createdAt: now), null);

      await store.deleteOutdatedEvents();

      expect(await store.getEvents(null), hasLength(1));
    });
  });

  test('migrates events from shared_preferences once', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    const key = 'io.wiredash.events.default|1717286400000|legacy0';
    await prefs.setString(key, jsonEncode(serializeEventV1(_event())));

    final store = createStore(
      MemoryFileSystem.test(),
      sharedPreferences: SharedPreferences.getInstance,
    );

    final events = await store.getEvents(null);

    expect(events, hasLength(1));
    expect(
      prefs.getKeys(),
      isNot(contains(key)),
      reason: 'migrated event should be removed from shared_preferences',
    );
  });
}

AnalyticsEvent _event({
  String eventName = 'test_event',
  DateTime? createdAt,
}) {
  return AnalyticsEvent(
    analyticsId: 'analytics-id',
    createdAt: createdAt ?? DateTime.utc(2024, 6, 2),
    eventName: eventName,
    sdkVersion: 1,
  );
}
