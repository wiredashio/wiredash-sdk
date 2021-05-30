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
    late SyncEngine syncEngine;

    setUp(() {
      api = _MockWiredashApi();
      prefs = FakeSharedPreferences();
      syncEngine = SyncEngine(api, () async => prefs);
      addTearDown(() => syncEngine.dispose());
    });

    test('Never opened Wiredash does not trigger ping', () {
      fakeAsync((async) {
        syncEngine.onWiredashInitialized();
        async.elapse(const Duration(seconds: 10));
        expect(api.pingInvocations.count, 0);
      });
    });

    test(
        'appstart pings when the user submitted feedback/sent message '
        'in the last 30 days (delayed by 2 seconds)', () {
      fakeAsync((async) {
        // Given last feedback 29 days ago
        syncEngine.rememberFeedbackSubmission();
        async.elapse(const Duration(days: 29));

        // Given last sync 2 hours ago
        prefs.setInt(SyncEngine.lastSuccessfulPingKey, clock.now().millisecond);
        async.elapse(const Duration(hours: 2));

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
        syncEngine.onUserOpenedWiredash();
        async.elapse(const Duration(milliseconds: 1));
        expect(api.pingInvocations.count, 1);
      });
    });
  });
}

class _MockWiredashApi extends Fake implements WiredashApi {
  final MethodInvocationCatcher pingInvocations =
      MethodInvocationCatcher('ping');

  @override
  Future<PingResponse> ping() async {
    await pingInvocations.addMethodCall();
    throw "Not implemented";
  }
}
