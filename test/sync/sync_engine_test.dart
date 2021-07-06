import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';
import 'package:wiredash/src/common/network/wiredash_api.dart';
import 'package:wiredash/src/sync/sync_engine.dart';

import '../feedback/data/pending_feedback_item_storage_test.dart';
import '../util/invocation_catcher.dart';

void main() {
  group('Triggering ping', () {
    late _MockWiredashApi api;
    late FakeSharedPreferences prefs;

    setUp(() {
      api = _MockWiredashApi();
      prefs = FakeSharedPreferences();
    });

    test('Never opened Wiredash does not trigger ping', () {
      fakeAsync((async) {
        final syncEngine = SyncEngine(api, () async => prefs);
        addTearDown(() => syncEngine.dispose());
        syncEngine.onWiredashInitialized();
        async.elapse(const Duration(seconds: 10));
        expect(api.pingInvocations.count, 0);
      });
    });

    test(
        'appstart pings when the user submitted feedback/sent message '
        'in the last 30 days (delayed by 2 seconds)', () {
      fakeAsync((async) {
        final syncEngine = SyncEngine(api, () async => prefs);
        addTearDown(() => syncEngine.dispose());

        // Given last feedback 29 days ago
        syncEngine.rememberFeedbackSubmission();
        async.elapse(const Duration(days: 29));

        // Given last sync 6 hours ago
        prefs.setInt(SyncEngine.lastSuccessfulPingKey,
            clock.now().millisecondsSinceEpoch);
        async.elapse(const Duration(hours: 6));

        syncEngine.onWiredashInitialized();
        async.elapse(const Duration(milliseconds: 1990));
        expect(api.pingInvocations.count, 0);
        async.elapse(const Duration(milliseconds: 100));
        expect(api.pingInvocations.count, 1);
      });
    });

    test('opening wiredash triggers ping immediately', () {
      fakeAsync((async) {
        expect(api.pingInvocations.count, 0);
        final syncEngine = SyncEngine(api, () async => prefs);
        addTearDown(() => syncEngine.dispose());
        syncEngine.onUserOpenedWiredash();
        async.flushTimers();
        expect(api.pingInvocations.count, 1);
      });
    });

    test('opening the app twice within 3h gap does nothing', () {
      fakeAsync((async) {
        // Given last ping was almost 3h ago
        prefs.setInt(SyncEngine.lastSuccessfulPingKey,
            clock.now().millisecondsSinceEpoch);
        async.elapse(const Duration(hours: 2, minutes: 59));
        expect(api.pingInvocations.count, 0);

        final syncEngine = SyncEngine(api, () async => prefs);
        addTearDown(() => syncEngine.dispose());
        syncEngine.onWiredashInitialized();
        async.flushTimers();
        expect(api.pingInvocations.count, 0);
      });
    });

    test('opening wiredash within 3h gap triggers ping', () {
      fakeAsync((async) {
        // Given last ping was almost 3h ago
        prefs.setInt(SyncEngine.lastSuccessfulPingKey,
            clock.now().millisecondsSinceEpoch);
        async.elapse(const Duration(hours: 2, minutes: 59));
        expect(api.pingInvocations.count, 0);

        final syncEngine = SyncEngine(api, () async => prefs);
        addTearDown(() => syncEngine.dispose());
        syncEngine.onUserOpenedWiredash();
        async.flushTimers();
        expect(api.pingInvocations.count, 1);
      });
    });

    group('Kill Switch', () {
      test('will silence ping on wiredash initialize', () {
        // We really, really, really don't want million of wiredash users
        // to kill our backend when something hits the fan
        fakeAsync((async) {
          // user opened app before
          prefs.setInt(SyncEngine.lastSuccessfulPingKey,
              clock.now().millisecondsSinceEpoch);
          async.elapse(const Duration(days: 1));

          // Silence SDK for two days
          api.pingInvocations.interceptor = (_) async {
            throw KillSwitchException(clock.now().add(const Duration(days: 2)));
          };

          var syncEngine = SyncEngine(api, () async => prefs);
          addTearDown(() => syncEngine.dispose());

          // When SDK receives `silentUntil`, the sdk stops pinging automatically
          syncEngine.onWiredashInitialized();
          async.flushTimers();
          expect(api.pingInvocations.count, 1);

          // doesn't ping within 2 day periode
          async.elapse(const Duration(days: 1));
          syncEngine.dispose();
          syncEngine = SyncEngine(api, () async => prefs);
          addTearDown(() => syncEngine.dispose());
          syncEngine.onWiredashInitialized();
          async.flushTimers();
          expect(api.pingInvocations.count, 1);

          // When the silent duration is over (day 3)
          // the sdk pings again on appstart
          async.elapse(const Duration(days: 2));
          syncEngine.dispose();
          syncEngine = SyncEngine(api, () async => prefs);
          addTearDown(() => syncEngine.dispose());
          syncEngine.onWiredashInitialized();
          async.flushTimers();
          expect(api.pingInvocations.count, 2);
        });
      });

      test('Not silent when manually open wiredash', () {
        fakeAsync((async) {
          // user opened app before
          prefs.setInt(SyncEngine.lastSuccessfulPingKey,
              clock.now().millisecondsSinceEpoch);
          async.elapse(const Duration(days: 1));

          // Silence SDK for two days
          api.pingInvocations.interceptor = (_) async {
            throw KillSwitchException(clock.now().add(const Duration(days: 2)));
          };

          // When SDK receives `silentUntil`, the sdk stops pinging
          var syncEngine = SyncEngine(api, () async => prefs);
          addTearDown(() => syncEngine.dispose());
          syncEngine.onWiredashInitialized();
          async.flushTimers();
          expect(api.pingInvocations.count, 1);

          // app start, silenced, no ping
          syncEngine = SyncEngine(api, () async => prefs);
          addTearDown(() => syncEngine.dispose());
          syncEngine.onWiredashInitialized();
          async.flushTimers();
          expect(api.pingInvocations.count, 1);

          // manual open, pings
          syncEngine = SyncEngine(api, () async => prefs);
          addTearDown(() => syncEngine.dispose());
          syncEngine.onUserOpenedWiredash();
          expect(api.pingInvocations.count, 2);
        });
      });
    });
  });
}

class _MockWiredashApi extends Fake implements WiredashApi {
  final MethodInvocationCatcher pingInvocations =
      MethodInvocationCatcher('ping');

  @override
  Future<PingResponse> ping() async {
    final mockedReturnValue = pingInvocations.addAsyncMethodCall();
    if (mockedReturnValue != null) {
      return await mockedReturnValue.value as PingResponse;
    }
    throw "Not implemented";
  }
}
