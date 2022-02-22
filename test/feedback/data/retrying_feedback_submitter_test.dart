// ignore_for_file: avoid_redundant_argument_values

import 'dart:typed_data';

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:http_parser/src/media_type.dart';
import 'package:test/test.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wiredash/src/common/network/wiredash_api.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item_storage.dart';
import 'package:wiredash/src/feedback/data/persisted_feedback_item.dart';
import 'package:wiredash/src/feedback/data/retrying_feedback_submitter.dart';

import '../../util/invocation_catcher.dart';
import 'pending_feedback_item_storage_test.dart';

class MockApi implements WiredashApi {
  final MethodInvocationCatcher sendFeedbackInvocations =
      MethodInvocationCatcher('sendFeedback');

  @override
  Future<void> sendFeedback(PersistedFeedbackItem feedback) async {
    return await sendFeedbackInvocations.addMethodCall(args: [feedback]);
  }

  final MethodInvocationCatcher uploadAttachmentInvocations =
      MethodInvocationCatcher('uploadAttachment');

  @override
  Future<AttachmentId> uploadAttachment({
    required Uint8List screenshot,
    required AttachmentType type,
    String? filename,
    MediaType? contentType,
  }) async {
    final response = await uploadAttachmentInvocations.addMethodCall(
      namedArgs: {
        'screenshot': screenshot,
        'type': type,
        'filename': filename,
        'contentType': contentType,
      },
    );
    if (response != null) {
      return response as AttachmentId;
    }
    throw 'Not mocked';
  }
}
//
// class FakePendingFeedbackItemStorage implements PendingFeedbackItemStorage {
//   FakePendingFeedbackItemStorage(this.fs);
//
//   final FileSystem fs;
//
//   final _currentItems = <PendingFeedbackItem>[];
//   final _deletedItemIds = <String>[];
//
//   @override
//   Future<void> clearPendingItem(String itemId) async {
//     final screenshot = fs.file('$itemId.png');
//     if (await screenshot.exists()) await screenshot.delete();
//
//     _deletedItemIds.add(itemId);
//     _currentItems.removeWhere((it) => it.id == itemId);
//   }
//
//   @override
//   Future<PendingFeedbackItem> addPendingItem(PersistedFeedbackItem item) async {
//     final id = _currentItems.length + 1;
//
//     final pendingItem = PendingFeedbackItem(id: '$id', feedbackItem: item);
//     _currentItems.add(pendingItem);
//     return pendingItem;
//   }
//
//   @override
//   Future<List<PendingFeedbackItem>> retrieveAllPendingItems() async {
//     return List.of(_currentItems);
//   }
//
//   @override
//   Future<void> updatePendingItem(PendingFeedbackItem item) async {
//     _currentItems
//       ..removeWhere((it) => item.id == it.id)
//       ..add(item);
//   }
// }

void main() {
  group('RetryingFeedbackSubmitter', () {
    late FileSystem fileSystem;
    late PendingFeedbackItemStorage storage;
    late MockApi mockApi;
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
      mockApi = MockApi();
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
      await retryingFeedbackSubmitter.submit(item);

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
      await retryingFeedbackSubmitter.submit(item);

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
      await retryingFeedbackSubmitter.submit(item);

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
      await retryingFeedbackSubmitter.submit(item);

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

    // test(
    //     'submit() - when has existing items and submits only the first one '
    //     'successfully, does not remove the failed items from storage',
    //     () async {
    //   const item = PersistedFeedbackItem(
    //     appInfo: AppInfo(
    //       appLocale: 'de_DE',
    //     ),
    //     buildInfo: BuildInfo(compilationMode: CompilationMode.release),
    //     deviceId: '1234',
    //     deviceInfo: DeviceInfo(
    //       pixelRatio: 1.0,
    //       textScaleFactor: 1.0,
    //       platformLocale: 'en_US',
    //       platformSupportedLocales: ['en_US', 'de_DE'],
    //       platformBrightness: Brightness.dark,
    //       gestureInsets:
    //           WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
    //       padding: WiredashWindowPadding(left: 0, top: 66, right: 0, bottom: 0),
    //       viewInsets:
    //           WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 685),
    //       physicalGeometry: Rect.zero,
    //       physicalSize: Size(800, 1200),
    //     ),
    //     email: 'email@example.com',
    //     message: 'test post pls ignore',
    //     labels: ['feedback'],
    //     userId: 'Testy McTestFace',
    //   );
    //
    //   // Prepopulate storage with 2 existing items.
    //   await storage.addPendingItem(
    //     item,
    //     kTransparentImage,
    //   );
    //   await storage.addPendingItem(
    //     item,
    //     kTransparentImage,
    //   );
    //
    //   // Make sure they exist.
    //   expect(await fileSystem.file('1.png').exists(), isTrue);
    //   expect(await fileSystem.file('2.png').exists(), isTrue);
    //   expect(storage._currentItems, [
    //     const PendingFeedbackItem(
    //       id: '1',
    //       feedbackItem: item,
    //       screenshotPath: '1.png',
    //     ),
    //     const PendingFeedbackItem(
    //       id: '2',
    //       feedbackItem: item,
    //       screenshotPath: '2.png',
    //     ),
    //   ]);
    //
    //   fakeAsync((async) {
    //     var firstFileSubmitted = false;
    //     mockApi.sendFeedbackInvocations.interceptor = (iv) {
    //       if (firstFileSubmitted) throw Exception();
    //       firstFileSubmitted = true;
    //     };
    //
    //     // Persist a new item - in this case with an id of '3' and '3.png' as
    //     // the screenshot path. Triggers submitting of pending items, starting
    //     // from '1'.
    //     retryingFeedbackSubmitter.submit(item, kTransparentImage);
    //
    //     // Hop on the time machine...
    //     async.elapse(const Duration(minutes: 5));
    //
    //     // Storage should not have the item 1 anymore, but 2 and 3 should still
    //     // be there.
    //     expect(fileSystem.file('1.png').existsSync(), isFalse);
    //     expect(fileSystem.file('2.png').existsSync(), isTrue);
    //     expect(fileSystem.file('3.png').existsSync(), isTrue);
    //     expect(storage._deletedItemIds, ['1']);
    //     expect(storage._currentItems, [
    //       const PendingFeedbackItem(
    //         id: '2',
    //         feedbackItem: item,
    //         screenshotPath: '2.png',
    //       ),
    //       const PendingFeedbackItem(
    //         id: '3',
    //         feedbackItem: item,
    //         screenshotPath: '3.png',
    //       ),
    //     ]);
    //
    //     expect(
    //       mockApi.uploadAttachmentInvocations.invocations.length > 1,
    //       true,
    //     );
    //
    //     final lastUploadCall =
    //         mockApi.uploadAttachmentInvocations.latest;
    //     expect(lastUploadCall[0], kTransparentImage);
    //
    //     expect(
    //       mockApi.sendFeedbackInvocations.invocations.length > 1,
    //       true,
    //     );
    //     final lastSendCall = mockApi.sendFeedbackInvocations.latest;
    //     expect(lastSendCall[0], item);
    //     expect(lastSendCall['images'], hasLength(1));
    //     expect((lastSendCall['images'] as List?)?[0], isA<ImageBlob>());
    //   });
    // });
    //
    // test('submit() - if fails, retries up to 8 times with exponential backoff',
    //     () async {
    //   const item = PersistedFeedbackItem(
    //     appInfo: AppInfo(
    //       appLocale: 'de_DE',
    //     ),
    //     buildInfo: BuildInfo(compilationMode: CompilationMode.release),
    //     deviceId: '1234',
    //     deviceInfo: DeviceInfo(
    //       pixelRatio: 1.0,
    //       textScaleFactor: 1.0,
    //       platformLocale: 'en_US',
    //       platformSupportedLocales: ['en_US', 'de_DE'],
    //       platformBrightness: Brightness.dark,
    //       gestureInsets:
    //           WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
    //       padding: WiredashWindowPadding(left: 0, top: 66, right: 0, bottom: 0),
    //       viewInsets:
    //           WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 685),
    //       physicalGeometry: Rect.zero,
    //       physicalSize: Size(800, 1200),
    //     ),
    //     email: 'email@example.com',
    //     message: 'test post pls ignore',
    //     labels: ['feedback'],
    //     userId: 'Testy McTestFace',
    //   );
    //
    //   final initialTime = DateTime(2000, 01, 01, 00, 00, 00, 000);
    //   final retryLog = <DateTime>[];
    //
    //   fakeAsync(
    //     (async) {
    //       final clock = async.getClock(initialTime);
    //       mockApi.sendFeedbackInvocations.interceptor = (iv) {
    //         retryLog.add(clock.now());
    //         throw Exception();
    //       };
    //
    //       retryingFeedbackSubmitter.submit(item, kTransparentImage);
    //
    //       // Hop on the time machine...
    //       async.elapse(const Duration(minutes: 5));
    //
    //       // Sending one feedback item should be retried no more than 8 times.
    //       final sendAttempts = mockApi
    //           .sendFeedbackInvocations.invocations
    //           .where((iv) {
    //         final matchItem = iv[0] == item;
    //         final matchImage = (iv['images'] as List?)?.length == 1;
    //         return matchItem && matchImage;
    //       });
    //       expect(sendAttempts.length, 8);
    //
    //       // Should've retried sending feedback at these very specific times.
    //       expect(retryLog, [
    //         DateTime(2000, 01, 01, 00, 00, 00, 000),
    //         DateTime(2000, 01, 01, 00, 00, 02, 000),
    //         DateTime(2000, 01, 01, 00, 00, 06, 000),
    //         DateTime(2000, 01, 01, 00, 00, 14, 000),
    //         DateTime(2000, 01, 01, 00, 00, 30, 000),
    //         DateTime(2000, 01, 01, 00, 01, 00, 000),
    //         DateTime(2000, 01, 01, 00, 01, 30, 000),
    //         DateTime(2000, 01, 01, 00, 02, 00, 000),
    //       ]);
    //
    //       expect(storage._deletedItemIds, isEmpty);
    //       expect(storage._currentItems, [
    //         const PendingFeedbackItem(
    //           id: '1',
    //           feedbackItem: item,
    //           screenshotPath: '1.png',
    //         ),
    //       ]);
    //     },
    //     initialTime: initialTime,
    //   );
    // });
    //
    // test('submit() - does not retry for UnauthenticatedWiredashApiException',
    //     () async {
    //   const item = PersistedFeedbackItem(
    //     appInfo: AppInfo(
    //       appLocale: 'de_DE',
    //     ),
    //     buildInfo: BuildInfo(compilationMode: CompilationMode.release),
    //     deviceId: '1234',
    //     deviceInfo: DeviceInfo(
    //       pixelRatio: 1.0,
    //       textScaleFactor: 1.0,
    //       platformLocale: 'en_US',
    //       platformSupportedLocales: ['en_US', 'de_DE'],
    //       platformBrightness: Brightness.dark,
    //       gestureInsets:
    //           WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
    //       padding: WiredashWindowPadding(left: 0, top: 66, right: 0, bottom: 0),
    //       viewInsets:
    //           WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 685),
    //       physicalGeometry: Rect.zero,
    //       physicalSize: Size(800, 1200),
    //     ),
    //     email: 'email@example.com',
    //     message: 'test post pls ignore',
    //     labels: ['feedback'],
    //     userId: 'Testy McTestFace',
    //   );
    //
    //   final initialTime = DateTime(2000, 01, 01, 00, 00, 00, 000);
    //   final retryLog = <DateTime>[];
    //
    //   fakeAsync(
    //     (async) {
    //       final clock = async.getClock(initialTime);
    //       mockApi.sendFeedbackInvocations.interceptor = (iv) {
    //         retryLog.add(clock.now());
    //         throw UnauthenticatedWiredashApiException(
    //           Response('error', 401),
    //           'projectX',
    //           'abcdefg1234',
    //         );
    //       };
    //
    //       retryingFeedbackSubmitter.submit(item, kTransparentImage);
    //
    //       // Hop on the time machine...
    //       async.elapse(const Duration(minutes: 5));
    //
    //       // Sending one feedback item should be retried no more than 8 times.
    //       mockApi.sendFeedbackInvocations.verifyInvocationCount(1);
    //
    //       // Log shows only one entry
    //       expect(retryLog, [
    //         DateTime(2000, 01, 01, 00, 00, 00, 000),
    //       ]);
    //
    //       expect(storage._deletedItemIds, isEmpty);
    //       expect(storage._currentItems, [
    //         const PendingFeedbackItem(
    //           id: '1',
    //           feedbackItem: item,
    //           screenshotPath: '1.png',
    //         ),
    //       ]);
    //     },
    //     initialTime: initialTime,
    //   );
    // });
    //
    // test('submit() - does not retry when server reports missing properties',
    //     () async {
    //   const item = PersistedFeedbackItem(
    //     appInfo: AppInfo(
    //       appLocale: 'de_DE',
    //     ),
    //     buildInfo: BuildInfo(compilationMode: CompilationMode.release),
    //     deviceId: '1234',
    //     deviceInfo: DeviceInfo(
    //       pixelRatio: 1.0,
    //       textScaleFactor: 1.0,
    //       platformLocale: 'en_US',
    //       platformSupportedLocales: ['en_US', 'de_DE'],
    //       platformBrightness: Brightness.dark,
    //       gestureInsets:
    //           WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
    //       padding: WiredashWindowPadding(left: 0, top: 66, right: 0, bottom: 0),
    //       viewInsets:
    //           WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 685),
    //       physicalGeometry: Rect.zero,
    //       physicalSize: Size(800, 1200),
    //     ),
    //     email: 'email@example.com',
    //     message: 'test post pls ignore',
    //     labels: ['feedback'],
    //     userId: 'Testy McTestFace',
    //   );
    //
    //   fakeAsync((async) {
    //     mockApi.sendFeedbackInvocations.interceptor = (iv) {
    //       final response = Response(
    //         '{"message": "child "deviceInfo" fails because [child "platformOS"'
    //         ' fails because ["platformOS" is required]]"}',
    //         400,
    //       );
    //       throw WiredashApiException(response: response);
    //     };
    //
    //     retryingFeedbackSubmitter.submit(item, kTransparentImage);
    //     async.elapse(const Duration(seconds: 1));
    //
    //     // Sending one feedback item should be retried no more than 8 times.
    //     mockApi.sendFeedbackInvocations.verifyInvocationCount(1);
    //
    //     // Item has beend deleted
    //     expect(storage._deletedItemIds, ['1']);
    //     expect(storage._currentItems, isEmpty);
    //   });
    // });
    //
    // test('submit() - does not retry when server reports unknown property',
    //     () async {
    //   const item = PersistedFeedbackItem(
    //     appInfo: AppInfo(
    //       appLocale: 'de_DE',
    //     ),
    //     buildInfo: BuildInfo(compilationMode: CompilationMode.release),
    //     deviceId: '1234',
    //     deviceInfo: DeviceInfo(
    //       pixelRatio: 1.0,
    //       textScaleFactor: 1.0,
    //       platformLocale: 'en_US',
    //       platformSupportedLocales: ['en_US', 'de_DE'],
    //       platformBrightness: Brightness.dark,
    //       gestureInsets:
    //           WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
    //       padding: WiredashWindowPadding(left: 0, top: 66, right: 0, bottom: 0),
    //       viewInsets:
    //           WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 685),
    //       physicalGeometry: Rect.zero,
    //       physicalSize: Size(800, 1200),
    //     ),
    //     email: 'email@example.com',
    //     message: 'test post pls ignore',
    //     labels: ['feedback'],
    //     userId: 'Testy McTestFace',
    //   );
    //
    //   fakeAsync((async) {
    //     mockApi.sendFeedbackInvocations.interceptor = (iv) {
    //       final response =
    //           Response('{"message":""compilationMode" is not allowed"}', 400);
    //       throw WiredashApiException(response: response);
    //     };
    //
    //     retryingFeedbackSubmitter.submit(item, kTransparentImage);
    //     async.elapse(const Duration(seconds: 1));
    //
    //     // Sending one feedback item should be retried no more than 8 times.
    //     mockApi.sendFeedbackInvocations.verifyInvocationCount(1);
    //
    //     // Item has beend deleted
    //     expect(storage._deletedItemIds, ['1']);
    //     expect(storage._currentItems, isEmpty);
    //   });
    // });
  });
}
