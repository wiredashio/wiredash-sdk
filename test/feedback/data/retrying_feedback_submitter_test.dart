import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wiredash/src/common/network/network_manager.dart';
import 'package:wiredash/src/feedback/data/feedback_item.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item_storage.dart';
import 'package:wiredash/src/feedback/data/retrying_feedback_submitter.dart';

class MockPendingFeedbackItemStorage extends Mock
    implements PendingFeedbackItemStorage {}

class MockNetworkManager extends Mock implements NetworkManager {}

class FakePendingFeedbackItemStorage implements PendingFeedbackItemStorage {
  FakePendingFeedbackItemStorage(this.fs);
  final FileSystem fs;

  final _currentItems = <PendingFeedbackItem>[];
  final _deletedItemIds = <String>[];

  @override
  Future<void> clearPendingItem(PendingFeedbackItem itemToClear) async {
    final screenshot = fs.file(itemToClear.screenshotPath);
    if (await screenshot.exists()) await screenshot.delete();

    _deletedItemIds.add(itemToClear.id);
    _currentItems.remove(itemToClear);
  }

  @override
  Future<PendingFeedbackItem> addPendingItem(
      FeedbackItem item, Uint8List screenshot) async {
    final id = _currentItems.length + 1;
    final screenshotName = '$id.png';
    final screenshotFile =
        await fs.file(screenshotName).writeAsBytes(screenshot);
    final pendingItem = PendingFeedbackItem(
      id: '$id',
      feedbackItem: item,
      screenshotPath: screenshotFile.path,
    );

    _currentItems.add(pendingItem);
    return pendingItem;
  }

  @override
  Future<List<PendingFeedbackItem>> retrieveAllPendingItems() async {
    return List.of(_currentItems);
  }
}

void main() {
  group('RetryingFeedbackSubmitter', () {
    FileSystem fileSystem;
    FakePendingFeedbackItemStorage fakePendingFeedbackItemStorage;
    MockNetworkManager mockNetworkManager;
    RetryingFeedbackSubmitter retryingFeedbackSubmitter;

    setUp(() {
      fileSystem = MemoryFileSystem.test();
      fakePendingFeedbackItemStorage =
          FakePendingFeedbackItemStorage(fileSystem);
      mockNetworkManager = MockNetworkManager();
      retryingFeedbackSubmitter = RetryingFeedbackSubmitter(
        fileSystem,
        fakePendingFeedbackItemStorage,
        mockNetworkManager,
      );
    });

    test('submit() - persists the feedback item properly', () async {
      const item = FeedbackItem(
        deviceInfo: '<device info>',
        email: 'email@example.com',
        message: 'test post pls ignore',
        type: 'feedback',
        user: 'Testy McTestFace',
      );

      await retryingFeedbackSubmitter.submit(item, kTransparentImage);

      expect(await fileSystem.file('1.png').exists(), isTrue);
      expect(fakePendingFeedbackItemStorage._deletedItemIds, isEmpty);
      expect(fakePendingFeedbackItemStorage._currentItems, [
        const PendingFeedbackItem(
          id: '1',
          feedbackItem: item,
          screenshotPath: '1.png',
        ),
      ]);
    });

    test(
        'submit() - does not crash when screenshot file does not exist anymore for some reason',
        () async {
      const item = FeedbackItem(
        deviceInfo: '<device info>',
        email: 'email@example.com',
        message: 'test post pls ignore',
        type: 'feedback',
        user: 'Testy McTestFace',
      );

      when(mockNetworkManager.sendFeedback(item, any)).thenAnswer((_) async {});

      fakeAsync((async) {
        retryingFeedbackSubmitter.submit(item, kTransparentImage);

        // Ensure that the screenshot exists, then delete it, and make sure it
        // was deleted successfully.
        expect(fileSystem.file('1.png').existsSync(), isTrue);
        fileSystem.file('1.png').deleteSync();
        expect(fileSystem.file('1.png').existsSync(), isFalse);

        // Should've not sent the feedback just yet.
        verifyZeroInteractions(mockNetworkManager);

        // Hop on the time machine...
        async.elapse(const Duration(minutes: 5));

        // Should just submit the feedback item once, without the screenshot, as
        // the file didn't exist.
        verify(mockNetworkManager.sendFeedback(item, null));
        verifyNoMoreInteractions(mockNetworkManager);
      });
    });

    test('submit() - future completes before interacting with NetworkManager',
        () async {
      const item = FeedbackItem(
        deviceInfo: '<device info>',
        email: 'email@example.com',
        message: 'test post pls ignore',
        type: 'feedback',
        user: 'Testy McTestFace',
      );

      await retryingFeedbackSubmitter.submit(item, kTransparentImage);

      verifyZeroInteractions(mockNetworkManager);
    });

    test(
        'submit() - if successful, gets rid of the feedback item in the storage',
        () async {
      const item = FeedbackItem(
        deviceInfo: '<device info>',
        email: 'email@example.com',
        message: 'test post pls ignore',
        type: 'feedback',
        user: 'Testy McTestFace',
      );

      when(mockNetworkManager.sendFeedback(item, kTransparentImage))
          .thenAnswer((_) async {});

      fakeAsync((async) {
        retryingFeedbackSubmitter.submit(item, kTransparentImage);

        // Hop on the time machine...
        async.elapse(const Duration(minutes: 5));

        // Storage should not have the pending feedback item or file anymore.
        expect(fileSystem.file('1.png').existsSync(), isFalse);
        expect(fakePendingFeedbackItemStorage._currentItems, isEmpty);
        expect(fakePendingFeedbackItemStorage._deletedItemIds, ['1']);

        // Feedback should be sent, and only once.
        verify(mockNetworkManager.sendFeedback(item, kTransparentImage));
        verifyNoMoreInteractions(mockNetworkManager);
      });
    });

    test(
        'submit() - when has existing items and submits only the first one successfully, does not remove the failed items from storage',
        () async {
      const item = FeedbackItem(
        deviceInfo: '<device info>',
        email: 'email@example.com',
        message: 'test post pls ignore',
        type: 'feedback',
        user: 'Testy McTestFace',
      );

      // Prepopulate storage with 2 existing items.
      await fakePendingFeedbackItemStorage.addPendingItem(
          item, kTransparentImage);
      await fakePendingFeedbackItemStorage.addPendingItem(
          item, kTransparentImage);

      // Make sure they exist.
      expect(await fileSystem.file('1.png').exists(), isTrue);
      expect(await fileSystem.file('2.png').exists(), isTrue);
      expect(fakePendingFeedbackItemStorage._currentItems, [
        const PendingFeedbackItem(
          id: '1',
          feedbackItem: item,
          screenshotPath: '1.png',
        ),
        const PendingFeedbackItem(
          id: '2',
          feedbackItem: item,
          screenshotPath: '2.png',
        ),
      ]);

      fakeAsync((async) {
        var firstFileSubmitted = false;
        when(mockNetworkManager.sendFeedback(item, kTransparentImage))
            .thenAnswer((_) async {
          if (firstFileSubmitted) throw Exception();
          firstFileSubmitted = true;
        });

        // Persist a new item - in this case with an id of '3' and '3.png' as the
        // screenshot path. Triggers submitting of pending items, starting from '1'.
        retryingFeedbackSubmitter.submit(item, kTransparentImage);

        // Hop on the time machine...
        async.elapse(const Duration(minutes: 5));

        // Storage should not have the item 1 anymore, but 2 and 3 should still
        // be there.
        expect(fileSystem.file('1.png').existsSync(), isFalse);
        expect(fileSystem.file('2.png').existsSync(), isTrue);
        expect(fileSystem.file('3.png').existsSync(), isTrue);
        expect(fakePendingFeedbackItemStorage._deletedItemIds, ['1']);
        expect(fakePendingFeedbackItemStorage._currentItems, [
          const PendingFeedbackItem(
            id: '2',
            feedbackItem: item,
            screenshotPath: '2.png',
          ),
          const PendingFeedbackItem(
            id: '3',
            feedbackItem: item,
            screenshotPath: '3.png',
          ),
        ]);

        verify(mockNetworkManager.sendFeedback(item, kTransparentImage));
      });
    });

    test('submit() - if fails, retries up to 8 times with exponential backoff',
        () async {
      const item = FeedbackItem(
        deviceInfo: '<device info>',
        email: 'email@example.com',
        message: 'test post pls ignore',
        type: 'feedback',
        user: 'Testy McTestFace',
      );

      final initialTime = DateTime(2000, 01, 01, 00, 00, 00, 000);
      final retryLog = <DateTime>[];

      fakeAsync((async) {
        final clock = async.getClock(initialTime);
        when(mockNetworkManager.sendFeedback(item, kTransparentImage))
            .thenAnswer((_) {
          retryLog.add(clock.now());
          throw Exception();
        });

        retryingFeedbackSubmitter.submit(item, kTransparentImage);

        // Hop on the time machine...
        async.elapse(const Duration(minutes: 5));

        // Sending one feedback item should be retried no more than 8 times.
        verify(mockNetworkManager.sendFeedback(item, kTransparentImage))
            .called(8);

        // Should've retried sending feedback at these very specific times.
        expect(retryLog, [
          DateTime(2000, 01, 01, 00, 00, 00, 000),
          DateTime(2000, 01, 01, 00, 00, 02, 000),
          DateTime(2000, 01, 01, 00, 00, 06, 000),
          DateTime(2000, 01, 01, 00, 00, 14, 000),
          DateTime(2000, 01, 01, 00, 00, 30, 000),
          DateTime(2000, 01, 01, 00, 01, 00, 000),
          DateTime(2000, 01, 01, 00, 01, 30, 000),
          DateTime(2000, 01, 01, 00, 02, 00, 000),
        ]);

        expect(fakePendingFeedbackItemStorage._deletedItemIds, isEmpty);
        expect(fakePendingFeedbackItemStorage._currentItems, [
          const PendingFeedbackItem(
            id: '1',
            feedbackItem: item,
            screenshotPath: '1.png',
          ),
        ]);
      }, initialTime: initialTime);
    });
  });
}

// ignore_for_file: avoid_redundant_argument_values
