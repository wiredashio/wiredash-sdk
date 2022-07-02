import 'dart:async';

import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';
import 'package:wiredash/src/core/sync/sync_engine.dart';

void main() {
  group('sync engine', () {
    test('onWiredashInit triggers SdkEvent.sppStart 5s after ', () {
      fakeAsync((async) {
        final syncEngine = SyncEngine();
        addTearDown(() => syncEngine.onWiredashDispose());

        DateTime? lastExecution;
        final testJob = TestJob(
          trigger: [SdkEvent.appStart],
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
