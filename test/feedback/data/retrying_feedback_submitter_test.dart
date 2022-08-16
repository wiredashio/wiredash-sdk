// ignore_for_file: avoid_redundant_argument_values

import 'package:fake_async/fake_async.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/network/wiredash_api.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item_storage.dart';

import '../../util/mock_api.dart';
import 'pending_feedback_item_storage_test.dart';

void main() {
  group('RetryingFeedbackSubmitter', () {
    late FileSystem fileSystem;
    late PendingFeedbackItemStorage storage;
    late MockWiredashApi mockApi;
    late RetryingFeedbackSubmitter retryingFeedbackSubmitter;

    setUp(() {
      fileSystem = MemoryFileSystem.test();
      final preferences = InMemorySharedPreferences();
      storage = PendingFeedbackItemStorage(
        fileSystem: fileSystem,
        uuidV4Generator: IncrementalUuidV4Generator(),
        dirPathProvider: () async => '.',
        sharedPreferencesProvider: () async => preferences,
      );
      mockApi = MockWiredashApi();
      mockApi.uploadAttachmentInvocations.interceptor = (_) {
        return AttachmentId('123');
      };
      retryingFeedbackSubmitter = RetryingFeedbackSubmitter(
        fileSystem,
        storage,
        mockApi,
      );
    });

    test('submit() - submits the item right away', () async {
      // When submtting feedback
      final item = createFeedback();
      expect(
        await retryingFeedbackSubmitter.submit(item),
        SubmissionState.submitted,
      );

      // Nothing on disk
      final saved = await storage.retrieveAllPendingItems();
      expect(saved, []);
    });

    test('submit() - persists the feedback item properly ', () async {
      // Given no internet
      mockApi.uploadAttachmentInvocations.interceptor = (_) {
        throw "No internet";
      };
      mockApi.sendFeedbackInvocations.interceptor = (_) async {
        throw "No internet";
      };

      // When submtting feedback
      final item = createFeedback();
      expect(
        await retryingFeedbackSubmitter.submit(item),
        SubmissionState.pending,
      );

      // It is persisted on disk
      final saved = await storage.retrieveAllPendingItems();
      expect(saved, [PendingFeedbackItem(id: '0', feedbackItem: item)]);
    });

    test(
        'submit() - does not crash when screenshot file does not exist '
        'anymore for some reason', () async {
      final item = createFeedback(
        attachments: [
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.inMemory(kTransparentImage),
            deviceInfo: testDeviceInfo,
          ),
        ],
      );

      // error at first
      mockApi.uploadAttachmentInvocations.interceptor = (_) {
        throw "No internet";
      };

      // error submission, save file on disk
      expect(
        await retryingFeedbackSubmitter.submit(item),
        SubmissionState.pending,
      );

      // Should've not sent the feedback just yet.
      mockApi.sendFeedbackInvocations.verifyInvocationCount(0);
      expect(await storage.retrieveAllPendingItems(), hasLength(1));

      // Ensure that the screenshot exists, then delete it, and make sure it
      // was deleted successfully.
      expect(fileSystem.file('0.png').existsSync(), isTrue);
      fileSystem.file('0.png').deleteSync();
      expect(fileSystem.file('0.png').existsSync(), isFalse);

      // submission works now
      final uuid = IncrementalUuidV4Generator();
      mockApi.uploadAttachmentInvocations.interceptor = (_) {
        return AttachmentId(uuid.generate());
      };
      // Submit the item without image now
      await retryingFeedbackSubmitter.submitPendingFeedbackItems();

      // Should just submit the feedback item once, without the screenshot, as
      // the file didn't exist.
      mockApi.sendFeedbackInvocations.verifyInvocationCount(1);
      expect(await storage.retrieveAllPendingItems(), hasLength(0));
      expect(
        mockApi.sendFeedbackInvocations.latest[0],
        item.copyWith(attachments: []),
      );
      mockApi.uploadAttachmentInvocations.verifyInvocationCount(1);
    });

    test(
        'submit() - if successful, gets rid of the feedback item '
        'in the storage', () async {
      final item = createFeedback(
        attachments: [
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.inMemory(kTransparentImage),
            deviceInfo: testDeviceInfo,
          ),
        ],
      );

      // error at first
      mockApi.uploadAttachmentInvocations.interceptor = (_) {
        throw "No internet";
      };

      // error submission, save file on disk
      expect(
        await retryingFeedbackSubmitter.submit(item),
        SubmissionState.pending,
      );

      // Should've not sent the feedback just yet.
      mockApi.uploadAttachmentInvocations.verifyInvocationCount(1);
      mockApi.sendFeedbackInvocations.verifyHasNoInvocation();
      final pendingItems = await storage.retrieveAllPendingItems();
      expect(pendingItems, hasLength(1));
      final filePath =
          pendingItems.first.feedbackItem.attachments.first.file.pathToFile;
      expect(fileSystem.file(filePath).existsSync(), isTrue);

      // submission works now
      final uuid = IncrementalUuidV4Generator();
      mockApi.uploadAttachmentInvocations.interceptor = (_) {
        return AttachmentId(uuid.generate());
      };
      // Submit the item with image
      await retryingFeedbackSubmitter.submitPendingFeedbackItems();

      // After submission the storage is empty
      mockApi.uploadAttachmentInvocations.verifyInvocationCount(2);
      expect(await storage.retrieveAllPendingItems(), hasLength(0));
      expect(fileSystem.file(filePath).existsSync(), isFalse);
    });

    test(
        'submit() - when has existing items and submits only the first one '
        'successfully, does not remove the failed items from storage',
        () async {
      // Don't upload while submitting the items
      mockApi.sendFeedbackInvocations.interceptor = (iv) {
        throw "No internet";
      };

      // error submission, save file on disk
      final item = createFeedback(message: '1');
      expect(
        await retryingFeedbackSubmitter.submit(item),
        SubmissionState.pending,
      );
      final item2 = createFeedback(message: '2');
      expect(
        await retryingFeedbackSubmitter.submit(item2),
        SubmissionState.pending,
      );

      // error only the first submission
      var firstFileSubmitted = false;
      mockApi.sendFeedbackInvocations.interceptor = (iv) {
        if (!firstFileSubmitted) {
          firstFileSubmitted = true;
          throw const WiredashApiException(
            message: "Something unexpected happened",
          );
        }
        return null /*void*/;
      };

      await retryingFeedbackSubmitter.submitPendingFeedbackItems();

      // one item was subitted, the other one is still pending
      expect(await storage.retrieveAllPendingItems(), hasLength(1));
      expect(
        mockApi.sendFeedbackInvocations.invocations.length > 1,
        true,
      );

      final lastSendCall = mockApi.sendFeedbackInvocations.latest;
      expect(lastSendCall[0], item2);
    });

    test(
        'submitPendingFeedbackItems() - if fails, retries up to 8 times with exponential backoff',
        () async {
      final item = createFeedback(message: '1');

      final initialTime = DateTime(2000, 01, 01, 00, 00, 00, 000);
      final retryLog = <DateTime>[];

      fakeAsync(
        (async) {
          final clock = async.getClock(initialTime);
          mockApi.sendFeedbackInvocations.interceptor = (iv) {
            retryLog.add(clock.now());
            throw Exception();
          };
          // no retry, just try
          retryingFeedbackSubmitter.submit(item);
          async.elapse(const Duration(minutes: 1));

          // 7 retries
          retryingFeedbackSubmitter.submitPendingFeedbackItems();

          // Hop on the time machine...
          async.elapse(const Duration(minutes: 5));

          // Sending one feedback item should be retried no more than 8 times.
          final sendAttempts =
              mockApi.sendFeedbackInvocations.invocations.where((iv) {
            return iv[0] == item;
          });
          expect(sendAttempts.length, 8);

          // Should've retried sending feedback at these very specific times.
          expect(retryLog, [
            DateTime(2000, 01, 01, 00, 00, 00, 000),
            DateTime(2000, 01, 01, 00, 01, 00, 000),
            DateTime(2000, 01, 01, 00, 01, 02, 000),
            DateTime(2000, 01, 01, 00, 01, 06, 000),
            DateTime(2000, 01, 01, 00, 01, 14, 000),
            DateTime(2000, 01, 01, 00, 01, 30, 000),
            DateTime(2000, 01, 01, 00, 02, 00, 000),
            DateTime(2000, 01, 01, 00, 02, 30, 000),
          ]);
        },
        initialTime: initialTime,
      );

      final items = await storage.retrieveAllPendingItems();
      expect(items, hasLength(1));
      expect(items.first.feedbackItem, item);
    });

    test('submit() - throws UnauthenticatedWiredashApiException', () async {
      final item = createFeedback();

      mockApi.sendFeedbackInvocations.interceptor = (iv) {
        throw UnauthenticatedWiredashApiException(
          Response('error', 401),
          'projectX',
          'abcdefg1234',
        );
      };

      await expectLater(
        () => retryingFeedbackSubmitter.submit(item),
        throwsA(
          isA<UnauthenticatedWiredashApiException>()
              .having((e) => e.projectId, 'projectId', 'projectX')
              .having((e) => e.secret, 'secret', 'abcdefg1234'),
        ),
      );
    });

    test(
        'submitPendingFeedbackItems() - does not retry for UnauthenticatedWiredashApiException',
        () async {
      final item = createFeedback();

      final initialTime = DateTime(2000, 01, 01, 00, 00, 00, 000);
      final retryLog = <DateTime>[];

      fakeAsync(
        (async) {
          final clock = async.getClock(initialTime);
          mockApi.sendFeedbackInvocations.interceptor = (iv) {
            retryLog.add(clock.now());
            if (retryLog.length == 1) {
              throw 'random error';
            }
            throw UnauthenticatedWiredashApiException(
              Response('error', 401),
              'projectX',
              'abcdefg1234',
            );
          };

          // add item (pending)
          retryingFeedbackSubmitter.submit(item).then((value) {
            expect(value, SubmissionState.pending);
          });
          async.elapse(const Duration(minutes: 1));

          // start retry counting from here on
          mockApi.sendFeedbackInvocations.clear();

          // send with retry
          retryingFeedbackSubmitter.submitPendingFeedbackItems();
          // Hop on the time machine...
          async.elapse(const Duration(minutes: 5));

          // Sending one feedback item should not be retried
          mockApi.sendFeedbackInvocations.verifyInvocationCount(1);

          // Log shows only one entry
          expect(retryLog, [
            DateTime(2000, 01, 01, 00, 00, 00, 000), // submit()
            DateTime(2000, 01, 01, 00, 01, 00, 000), // submitPendingFeedback
          ]);
        },
        initialTime: initialTime,
      );

      final items = await storage.retrieveAllPendingItems();
      // UnauthenticatedWiredashApiException removes item
      expect(items, hasLength(0));
    });

    test(
        'submit() - does not retry when server reports missing properties '
        'even deletes the feedback', () async {
      final item = createFeedback();

      mockApi.sendFeedbackInvocations.interceptor = (iv) {
        final response = Response(
          '{"message": "child "deviceInfo" fails because [child "platformOS"'
          ' fails because ["platformOS" is required]]"}',
          400,
        );
        throw WiredashApiException(response: response);
      };

      // submit item fails
      await expectLater(
        () => retryingFeedbackSubmitter.submit(item),
        throwsA(isA<WiredashApiException>()),
      );
      // item is not pending because it will never work
      expect(await storage.retrieveAllPendingItems(), hasLength(0));
    });

    test('submit() - does not retry when server reports unknown property',
        () async {
      final item = createFeedback();

      mockApi.sendFeedbackInvocations.interceptor = (iv) {
        final response = Response(
          '''{"message":"\\"compilationMode\\" is not allowed"}''',
          400,
        );
        throw WiredashApiException(response: response);
      };

      await expectLater(
        () => retryingFeedbackSubmitter.submit(item),
        throwsA(
          isA<WiredashApiException>().having(
            (e) => e.messageFromServer,
            'response',
            '"compilationMode" is not allowed',
          ),
        ),
      );

      // Sending one feedback item should be retried no more than 8 times.
      mockApi.sendFeedbackInvocations.verifyInvocationCount(1);

      // Item has beend deleted
      expect(await storage.retrieveAllPendingItems(), hasLength(0));
    });
  });
}
