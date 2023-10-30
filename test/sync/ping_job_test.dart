import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/network/wiredash_api.dart';
import 'package:wiredash/src/core/sync/ping_job.dart';
import 'package:wiredash/src/core/wiredash_model.dart';
import 'package:wiredash/src/core/wiredash_widget.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item.dart';
import 'package:wiredash/src/metadata/device_info/device_info_generator.dart';
import 'package:wiredash/src/metadata/meta_data_collector.dart';

import '../feedback/data/pending_feedback_item_storage_test.dart';
import '../util/mock_api.dart';

const tenSeconds = Duration(seconds: 10);

void main() {
  group('Triggering ping', () {
    late MockWiredashApi api;
    late InMemorySharedPreferences prefs;

    Future<SharedPreferences> prefsProvider() async => prefs;

    PingJob createPingJob() => PingJob(
          apiProvider: () => api,
          sharedPreferencesProvider: prefsProvider,
          metaDataCollector: () => FakeMetaDataCollector(),
          uidGenerator: () => IncrementalIdGenerator(),
        );

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
        pingJob.execute();
        async.flushTimers();
        expect(api.pingInvocations.count, 1);
      });
    });

    test('do not ping again within minPingGap window', () {
      fakeAsync((async) {
        final pingJob = createPingJob();
        pingJob.execute();
        async.flushTimers();
        expect(api.pingInvocations.count, 1);

        async.elapse(PingJob.minPingGap - tenSeconds);
        pingJob.execute();
        async.flushTimers();
        expect(api.pingInvocations.count, 1);
      });
    });

    test('ping after minPingGap window', () {
      fakeAsync((async) {
        final pingJob = createPingJob();
        pingJob.execute();
        async.flushTimers();
        expect(api.pingInvocations.count, 1);

        async.elapse(PingJob.minPingGap);
        pingJob.execute();
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
        pingJob.execute();
        async.flushTimers();
        expect(api.pingInvocations.count, 1);

        async.elapse(const Duration(days: 7) - tenSeconds);
        pingJob.execute();
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
          uidGenerator: () => IncrementalIdGenerator(),
        );
        pingJob.execute();
        async.flushTimers();
        expect(api.pingInvocations.count, 1);

        async.elapse(const Duration(days: 7));
        pingJob.execute();
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
          uidGenerator: () => IncrementalIdGenerator(),
        );
        pingJob.execute();
        async.flushTimers();
        expect(api.pingInvocations.count, 1);

        pingJob.execute();
        async.flushTimers();
        expect(api.pingInvocations.count, 2);
      });
    });
  });
}

class FakeMetaDataCollector with Fake implements MetaDataCollector {
  @override
  Future<FixedMetaData> collectFixedMetaData() async {
    return const FixedMetaData(
      flutterInfo: FlutterInfo(
        pixelRatio: 1.0,
        textScaleFactor: 1.0,
        platformLocale: 'en_US',
        platformSupportedLocales: ['en_US', 'de_DE'],
        platformBrightness: Brightness.dark,
        gestureInsets:
            WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
        padding: WiredashWindowPadding(left: 0, top: 66, right: 0, bottom: 0),
        viewInsets:
            WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 685),
        physicalGeometry: Rect.zero,
        physicalSize: Size(1280, 720),
      ),
      deviceInfo: DeviceInfo(deviceModel: 'Pixel 2'),
      buildInfo: BuildInfo(compilationMode: CompilationMode.profile),
      appInfo: AppInfo(),
    );
  }
}
