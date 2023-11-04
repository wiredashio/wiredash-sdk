import 'dart:async';

import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:test/test.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/core/network/wiredash_api.dart';
import 'package:wiredash/src/core/services/services.dart';
import 'package:wiredash/src/core/sync/sync_engine.dart';
import 'package:wiredash/wiredash.dart';

import '../util/mock_api.dart';

void main() {
  group('sync engine', () {
    test('onWiredashInit triggers SdkEvent.appStartDelayed 5s after ', () {
      fakeAsync((async) {
        final syncEngine = SyncEngine();
        addTearDown(() => syncEngine.onWiredashDispose());

        DateTime? lastExecution;
        final testJob = TestJob(
          trigger: [SdkEvent.appStartDelayed],
          block: () {
            lastExecution = clock.now();
          },
        );
        syncEngine.addJob('test', testJob);

        // After init
        syncEngine.onWiredashInit();
        // Jobs listening to appStart are not triggered directly
        async.elapse(const Duration(seconds: 4));
        expect(lastExecution, isNull);

        // but after 5s
        async.elapse(const Duration(seconds: 1));
        expect(lastExecution, isNotNull);
      });
    });

    test('Removing a job does not execute it anymore', () async {
      final syncEngine = SyncEngine();
      addTearDown(() => syncEngine.onWiredashDispose());

      DateTime? lastExecution;
      final testJob = TestJob(
        trigger: [SdkEvent.appStartDelayed],
        block: () {
          lastExecution = clock.now();
        },
      );
      syncEngine.addJob('test', testJob);

      await syncEngine.onWiredashInit();
      expect(lastExecution, isNull);
      final firstRun = lastExecution;

      final removed = syncEngine.removeJob('test');
      expect(removed, testJob);

      await syncEngine.onWiredashInit();
      // did not update, was not executed again
      expect(lastExecution, firstRun);
    });

    test('rebuilding SyncEngine keeps the instance', () async {
      final services = WiredashServices();
      final firstSyncEngine = services.syncEngine;
      // SyncEngine uses the api and submitter. Changing any of those does not
      // create a new instance.
      services.inject<Wiredash>(
        (_) => const Wiredash(
          projectId: 'newId',
          secret: 'newSecret',
          child: SizedBox(),
        ),
      );
      services.inject<WiredashApi>((_) => MockWiredashApi());
      services.inject<FeedbackSubmitter>(
        (sl) => DirectFeedbackSubmitter(sl.watch()),
      );
      final secondSyncEngine = services.syncEngine;
      expect(firstSyncEngine, same(secondSyncEngine));
    });
  });

  test('event listener future', () async {
    final engine = SyncEngine();
    String futureState = '';
    final future = engine
        .onEvent(SdkEvent.appStart)
        .whenComplete(() => futureState = 'complete');
    expect(futureState, '');
    await engine.onWiredashInit();
    expect(futureState, 'complete');
    await future;
  });

  test('completer is only called once', () async {
    final engine = SyncEngine();
    engine.onEvent(SdkEvent.appStart);
    await engine.onWiredashInit();
    // completing the completer twice would throw
    await engine.onWiredashInit();
  });
}

class TestJob extends Job {
  final List<SdkEvent> trigger;
  final FutureOr<void> Function() block;

  TestJob({
    required this.trigger,
    required this.block,
  });

  @override
  Future<void> execute() async {
    await block();
  }

  @override
  bool shouldExecute(SdkEvent event) {
    return trigger.contains(event);
  }
}
