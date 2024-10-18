import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:fake_async/fake_async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/options/environment_loader.dart';
import 'package:wiredash/src/core/sync/ping_job.dart';
import 'package:wiredash/src/core/sync/sync_engine.dart';
import 'package:wiredash/src/core/version.dart';
import 'package:wiredash/src/metadata/meta_data_collector.dart';

import '../feedback/data/pending_feedback_item_storage_test.dart';
import '../util/mock_api.dart';

const tenSeconds = Duration(seconds: 10);

void main() {
  group('Triggering ping', () {
    late MockWiredashApi api;
    late InMemorySharedPreferences prefs;

    Future<SharedPreferences> prefsProvider() async => prefs;

    PingJob createPingJob() {
      final fakeMetaDataCollector = FakeMetaDataCollector();
      final incrementalIdGenerator = IncrementalIdGenerator();
      return PingJob(
        apiProvider: () => api,
        sharedPreferencesProvider: prefsProvider,
        metaDataCollector: () {
          return fakeMetaDataCollector;
        },
        wuidGenerator: () {
          return incrementalIdGenerator;
        },
        environmentLoader: () => MockEnvironmentLoader('prod'),
      );
    }

    setUp(() {
      api = MockWiredashApi();
      api.pingInvocations.interceptor = (invocation) async {
        // 200 success
        return PingResponse();
      };
      prefs = InMemorySharedPreferences();
    });

    test('ping gets submitted', () {
      fakeAsync((async) {
        final pingJob = createPingJob();
        pingJob.execute(SdkEvent.appStartDelayed);
        async.flushTimers();
        expect(api.pingInvocations.count, 1);
      });
    });

    test('ping sends all fields', () {
      fakeAsync((async) {
        final pingJob = createPingJob();
        pingJob.execute(SdkEvent.appStartDelayed);
        async.flushTimers();
        expect(api.pingInvocations.count, 1);
        final body = api.pingInvocations.invocations[0][0]! as PingRequestBody;
        expect(body.analyticsId, '0000000000000000');
        expect(body.buildCommit, null);
        expect(body.buildNumber, '123');
        expect(body.buildVersion, '1.2.3');
        expect(body.bundleId, 'com.example.app');
        expect(body.platformOS, 'android');
        expect(body.platformOSVersion, '13');
        expect(body.platformLocale, 'en_US');
        expect(body.sdkVersion, wiredashSdkVersion);
      });
    });

    test('ping sends buildVersion und buildNumber overrides from environment',
        () {
      fakeAsync((async) {
        final pingJob = createPingJob();
        (pingJob.metaDataCollector() as FakeMetaDataCollector)
            .buildInfoOverride = const BuildInfo(
          buildVersion: '10.0.0',
          buildNumber: '1000',
          compilationMode: CompilationMode.profile,
        );
        pingJob.execute(SdkEvent.appStartDelayed);
        async.flushTimers();
        expect(api.pingInvocations.count, 1);
        final body = api.pingInvocations.invocations[0][0]! as PingRequestBody;
        expect(body.buildNumber, '1000');
        expect(body.buildVersion, '10.0.0');
      });
    });

    test('do not ping again within minPingGap window', () {
      fakeAsync((async) {
        final pingJob = createPingJob();
        pingJob.execute(SdkEvent.appStartDelayed);
        async.flushTimers();
        expect(api.pingInvocations.count, 1);

        async.elapse(PingJob.minPingGap - tenSeconds);
        pingJob.execute(SdkEvent.appStartDelayed);
        async.flushTimers();
        expect(api.pingInvocations.count, 1);
      });
    });

    test('ping after minPingGap window', () {
      fakeAsync((async) {
        final pingJob = createPingJob();
        pingJob.execute(SdkEvent.appStartDelayed);
        async.flushTimers();
        expect(api.pingInvocations.count, 1);

        async.elapse(PingJob.minPingGap);
        pingJob.execute(SdkEvent.appStartDelayed);
        async.flushTimers();
        expect(api.pingInvocations.count, 2);
      });
    });

    test('silence for 1w after KillSwitchException', () {
      fakeAsync((async) {
        api.pingInvocations.interceptor = (invocation) {
          throw const KillSwitchException();
        };
        final pingJob = createPingJob();
        pingJob.execute(SdkEvent.appStartDelayed);
        async.flushTimers();
        expect(api.pingInvocations.count, 1);

        async.elapse(const Duration(days: 7) - tenSeconds);
        pingJob.execute(SdkEvent.appStartDelayed);
        async.flushTimers();
        expect(api.pingInvocations.count, 1);
      });
    });

    test('ping after KillSwitchException resumes after 1w', () {
      fakeAsync((async) {
        api.pingInvocations.interceptor = (invocation) {
          throw const KillSwitchException();
        };
        final pingJob = PingJob(
          apiProvider: () => api,
          sharedPreferencesProvider: prefsProvider,
          metaDataCollector: () => FakeMetaDataCollector(),
          wuidGenerator: () => IncrementalIdGenerator(),
          environmentLoader: () => MockEnvironmentLoader('prod'),
        );
        pingJob.execute(SdkEvent.appStartDelayed);
        async.flushTimers();
        expect(api.pingInvocations.count, 1);

        async.elapse(const Duration(days: 7));
        pingJob.execute(SdkEvent.appStartDelayed);
        async.flushTimers();
        expect(api.pingInvocations.count, 2);
      });
    });

    test('any general Exception thrown by ping does not silence the job', () {
      fakeAsync((async) {
        api.pingInvocations.interceptor = (invocation) {
          throw const SocketException('message');
        };
        final pingJob = PingJob(
          apiProvider: () => api,
          sharedPreferencesProvider: prefsProvider,
          metaDataCollector: () => FakeMetaDataCollector(),
          wuidGenerator: () => IncrementalIdGenerator(),
          environmentLoader: () => MockEnvironmentLoader('prod'),
        );
        pingJob.execute(SdkEvent.appStartDelayed);
        async.flushTimers();
        expect(api.pingInvocations.count, 1);

        pingJob.execute(SdkEvent.appStartDelayed);
        async.flushTimers();
        expect(api.pingInvocations.count, 2);
      });
    });
  });
}

class FakeMetaDataCollector with Fake implements MetaDataCollector {
  BuildInfo? buildInfoOverride;

  @override
  Future<FixedMetaData> collectFixedMetaData() async {
    return FixedMetaData(
      deviceInfo: const DeviceInfo(
        deviceModel: 'Pixel 2',
        osVersion: '13',
      ),
      buildInfo: buildInfoOverride ??
          const BuildInfo(
            compilationMode: CompilationMode.profile,
          ),
      appInfo: const AppInfo(
        version: '1.2.3',
        buildNumber: '123',
        bundleId: 'com.example.app',
      ),
    );
  }

  @override
  FlutterInfo collectFlutterInfo() {
    return const FlutterInfo(
      pixelRatio: 1.0,
      textScaleFactor: 1.0,
      platformLocale: 'en_US',
      platformSupportedLocales: ['en_US', 'de_DE'],
      platformOS: 'android',
      platformBrightness: Brightness.dark,
      gestureInsets:
          WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
      viewPadding: WiredashWindowPadding(left: 0, top: 66, right: 0, bottom: 0),
      viewInsets: WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 685),
      physicalSize: Size(1280, 720),
    );
  }
}

class MockEnvironmentLoader implements EnvironmentLoader {
  final String environment;

  MockEnvironmentLoader(this.environment);

  @override
  Future<String> getEnvironment() async {
    return environment;
  }

  @override
  Future<bool> isDevEnvironment() {
    // TODO: implement isDevEnvironment
    throw UnimplementedError();
  }
}
