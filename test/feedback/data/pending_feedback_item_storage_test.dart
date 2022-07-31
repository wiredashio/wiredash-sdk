import 'dart:convert';
import 'dart:ui';

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wiredash/src/feedback/_feedback.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item_storage.dart';
import 'package:wiredash/src/metadata/build_info/app_info.dart';
import 'package:wiredash/src/metadata/build_info/build_info.dart';
import 'package:wiredash/src/metadata/device_info/device_info.dart';
import 'package:wiredash/src/utils/uuid.dart';

import '../../util/invocation_catcher.dart';

void main() {
  group('PendingFeedbackItemStorage', () {
    late FileSystem fileSystem;
    late InMemorySharedPreferences prefs;
    late IncrementalUuidV4Generator uuidGenerator;
    late PendingFeedbackItemStorage storage;

    setUp(() {
      fileSystem = MemoryFileSystem.test();
      prefs = InMemorySharedPreferences();
      uuidGenerator = IncrementalUuidV4Generator();
      storage = PendingFeedbackItemStorage(
        fileSystem: fileSystem,
        sharedPreferencesProvider: () async => prefs,
        dirPathProvider: () async => '.',
        uuidV4Generator: uuidGenerator,
      );
    });

    List<String> filesOnDisk() =>
        fileSystem.directory('').listSync().map((it) => it.path).toList()
          ..sort();

    test('can persist one feedback item', () async {
      await fileSystem.file('existing.png').writeAsBytes(kTransparentImage);

      final item = createFeedback(
        attachments: [
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.inMemory(kTransparentImage),
            deviceInfo: testDeviceInfo,
          ),
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.uploaded(AttachmentId('453')),
            deviceInfo: testDeviceInfo,
          ),
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.file('existing.png'),
            deviceInfo: testDeviceInfo,
          ),
        ],
      );
      final pendingItem = await storage.addPendingItem(item);

      expect(
        pendingItem.feedbackItem.attachments[0].file,
        FileDataEventuallyOnDisk.file('0.png'),
      );
      expect(
        pendingItem.feedbackItem.attachments[1].file,
        FileDataEventuallyOnDisk.uploaded(AttachmentId('453')),
      );
      expect(
        pendingItem.feedbackItem.attachments[2].file,
        FileDataEventuallyOnDisk.file('existing.png'),
      );

      expect(
        await storage.retrieveAllPendingItems(),
        [pendingItem],
      );
      // actually check prefs
      expect(prefs.setStringListInvocations.count, 1);
      final saved = prefs._store['io.wiredash.pending_feedback_items'];
      expect(saved, [serializePendingFeedbackItem(pendingItem)]);

      // 0.png because of incrementing uuid
      expect(filesOnDisk(), [
        '0.png',
        'existing.png',
      ]);
    });

    test('store a second item without overriding the first one', () async {
      final firstFeedback = createFeedback(
        attachments: [
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.inMemory(kTransparentImage),
            deviceInfo: testDeviceInfo,
          ),
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.inMemory(kTransparentImage),
            deviceInfo: testDeviceInfo,
          ),
        ],
      );
      final firstItem = await storage.addPendingItem(firstFeedback);

      final secondFeedback = createFeedback(
        attachments: [
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.inMemory(kTransparentImage),
            deviceInfo: testDeviceInfo,
          ),
        ],
      );
      final secondItem = await storage.addPendingItem(secondFeedback);

      expect(
        await storage.retrieveAllPendingItems(),
        [firstItem, secondItem],
      );

      final allAttachments = [
        ...firstItem.feedbackItem.attachments,
        ...secondItem.feedbackItem.attachments,
      ];
      // all items must be distinct (different ids)
      expect(allAttachments, allAttachments.toSet().toList());

      // 3 saved files
      expect(filesOnDisk(), [
        '0.png',
        '1.png',
        '3.png', // uuidGenerator is also used to create the pending item id
      ]);
    });

    test('can clear one feedback item', () async {
      final item = createFeedback(
        attachments: [
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.inMemory(kTransparentImage),
            deviceInfo: testDeviceInfo,
          ),
        ],
      );
      final pendingItem = await storage.addPendingItem(item);
      expect(await storage.retrieveAllPendingItems(), [pendingItem]);
      expect(filesOnDisk(), ['0.png']);

      await storage.clearPendingItem(pendingItem.id);

      expect(await storage.retrieveAllPendingItems(), []);
      expect(filesOnDisk(), []);
    });

    test('when has two items, preserves one while clearing the other one',
        () async {
      final first = createFeedback(
        attachments: [
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.inMemory(kTransparentImage),
            deviceInfo: testDeviceInfo,
          ),
        ],
      );
      final firstPending = await storage.addPendingItem(first);
      expect(firstPending.id, '1');
      expect(filesOnDisk(), ['0.png']);

      final second = createFeedback(
        attachments: [
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.inMemory(kTransparentImage),
            deviceInfo: testDeviceInfo,
          ),
        ],
      );
      final secondPending = await storage.addPendingItem(second);
      expect(secondPending.id, '3');

      expect(filesOnDisk(), ['0.png', '2.png']);
      expect(
        await storage.retrieveAllPendingItems(),
        [firstPending, secondPending],
      );

      await storage.clearPendingItem(firstPending.id);

      expect(await storage.retrieveAllPendingItems(), [secondPending]);
      expect(filesOnDisk(), ['2.png']);
    });

    test('removes items which can not be parsed', () async {
      await fileSystem
          .file('<screenshot for invalid item>')
          .writeAsBytes(kTransparentImage);

      final illegalSerializedItem = json.encode({
        // item has some required properties missing
        'id': '<screenshot for invalid item>',
        'feedbackItem': {
          'email': '<email for item to be preserved>',
          'type': '<type for item to be preserved>',
        },
        'screenshotPath': '<screenshot for invalid item>'
      });

      await fileSystem
          .file('<existing item screenshot>')
          .writeAsBytes(kTransparentImage);

      final pendingSerializedLegalItem = serializePendingFeedbackItem(
        PendingFeedbackItem(
          id: '123',
          feedbackItem: createFeedback(
            attachments: [
              PersistedAttachment.screenshot(
                file:
                    FileDataEventuallyOnDisk.file('<existing item screenshot>'),
                deviceInfo: testDeviceInfo,
              ),
            ],
          ),
        ),
      );

      await prefs.setStringList(
        'io.wiredash.pending_feedback_items',
        [
          illegalSerializedItem,
          pendingSerializedLegalItem,
        ],
      );

      final oldOnErrorHandler = FlutterError.onError;
      late FlutterErrorDetails caught;
      FlutterError.onError = (FlutterErrorDetails details) {
        caught = details;
      };
      addTearDown(() {
        // reset error reporter after test
        FlutterError.onError = oldOnErrorHandler;
      });

      final retrieved = await storage.retrieveAllPendingItems();

      // method returns only valid items
      expect(retrieved.length, 1);

      // error was reported to Flutter.onError
      expect(
        caught.stack.toString(),
        stringContainsInOrder([
          'deserializePendingFeedbackItem',
          'PendingFeedbackItemStorage.retrieveAllPendingItems',
        ]),
      );
      // reset error reporter after successful assertion
      FlutterError.onError = oldOnErrorHandler;

      // add pending item to remove the illegal one
      final newFeedback = createFeedback();
      final pendingItem = await storage.addPendingItem(newFeedback);

      // verify the invalid item was removed, while the legal and new item
      // where saved
      final lastCall = prefs.setStringListInvocations.latest;
      expect(lastCall[0], 'io.wiredash.pending_feedback_items');
      expect(
        lastCall[1],
        [pendingSerializedLegalItem, serializePendingFeedbackItem(pendingItem)],
      );

      // screenshot was deleted as well, leave nothing behind!
      expect(
        fileSystem.file('<screenshot for invalid item>').existsSync(),
        isFalse,
      );

      expect(
        fileSystem.file('<existing item screenshot>').existsSync(),
        isTrue,
      );
    });

    test('updateItem removes file from disk', () async {
      final first = createFeedback(
        attachments: [
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.inMemory(kTransparentImage),
            deviceInfo: testDeviceInfo,
          ),
        ],
      );
      final firstPending = await storage.addPendingItem(first);
      expect(firstPending.id, '1');
      expect(filesOnDisk(), ['0.png']);

      final second = createFeedback(
        attachments: [
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.inMemory(kTransparentImage),
            deviceInfo: testDeviceInfo,
          ),
        ],
      );
      final secondPending = await storage.addPendingItem(second);
      expect(secondPending.id, '3');

      expect(filesOnDisk(), ['0.png', '2.png']);
      expect(
        await storage.retrieveAllPendingItems(),
        [firstPending, secondPending],
      );

      // replace attachment with after upload
      final update = firstPending.copyWith(
        feedbackItem: firstPending.feedbackItem.copyWith(
          attachments: [
            PersistedAttachment.screenshot(
              file: FileDataEventuallyOnDisk.uploaded(AttachmentId('1')),
              deviceInfo: firstPending.feedbackItem.deviceInfo,
            )
          ],
        ),
      );
      await storage.updatePendingItem(update);

      expect(await storage.retrieveAllPendingItems(), [secondPending, update]);
      expect(filesOnDisk(), ['2.png']);
    });
  });
}

class InMemorySharedPreferences extends Fake implements SharedPreferences {
  final Map<String, Object?> _store = {};

  final MethodInvocationCatcher setStringListInvocations =
      MethodInvocationCatcher('setStringList');

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    final mockedReturnValue =
        setStringListInvocations.addAsyncMethodCall<bool>(args: [key, value]);
    if (mockedReturnValue != null) {
      return mockedReturnValue.future;
    }
    _store[key] = value;
    return true;
  }

  final MethodInvocationCatcher getStringListInvocations =
      MethodInvocationCatcher('getStringList');

  @override
  List<String>? getStringList(String key) {
    final mockedReturnValue =
        getStringListInvocations.addMethodCall<List<String>?>(args: [key]);
    if (mockedReturnValue != null) {
      return mockedReturnValue.value;
    }
    return _store[key] as List<String>?;
  }

  final MethodInvocationCatcher setIntInvocations =
      MethodInvocationCatcher('setInt');

  @override
  Future<bool> setInt(String key, int value) async {
    final mockedReturnValue =
        setIntInvocations.addAsyncMethodCall<bool>(args: [key, value]);
    if (mockedReturnValue != null) {
      return mockedReturnValue.future;
    }
    _store[key] = value;
    return true;
  }

  final MethodInvocationCatcher getIntInvocations =
      MethodInvocationCatcher('getInt');

  @override
  int? getInt(String key) {
    final mockedReturnValue =
        getIntInvocations.addMethodCall<int?>(args: [key]);
    if (mockedReturnValue != null) {
      return mockedReturnValue.value;
    }
    return _store[key] as int?;
  }

  final MethodInvocationCatcher setStringInvocations =
      MethodInvocationCatcher('setString');

  @override
  Future<bool> setString(String key, String value) async {
    final mockedReturnValue =
        setStringInvocations.addAsyncMethodCall<bool>(args: [key, value]);
    if (mockedReturnValue != null) {
      return mockedReturnValue.future;
    }
    _store[key] = value;
    return true;
  }

  final MethodInvocationCatcher getStringInvocations =
      MethodInvocationCatcher('getString');

  @override
  String? getString(String key) {
    final mockedReturnValue = getStringInvocations.addMethodCall(args: [key]);
    if (mockedReturnValue != null) {
      return mockedReturnValue.value as String?;
    }
    return _store[key] as String?;
  }
}

/// Creates string IDs that increment
class IncrementalUuidV4Generator implements UuidV4Generator {
  var _next = 0;

  @override
  String generate() {
    final now = _next;
    _next++;
    return now.toString();
  }
}

const testDeviceInfo = FlutterDeviceInfo(
  pixelRatio: 1.0,
  textScaleFactor: 1.0,
  platformLocale: 'en_US',
  platformSupportedLocales: ['en_US', 'de_DE'],
  platformBrightness: Brightness.dark,
  gestureInsets: WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
  padding: WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
  viewInsets: WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
  physicalGeometry: Rect.zero,
  physicalSize: Size(800, 1200),
);

PersistedFeedbackItem createFeedback({
  List<PersistedAttachment>? attachments,
  String? message,
}) {
  return PersistedFeedbackItem(
    appInfo: const AppInfo(appLocale: 'de_DE'),
    buildInfo: const BuildInfo(compilationMode: CompilationMode.release),
    deviceId: '1234',
    deviceInfo: testDeviceInfo,
    email: 'email@example.com',
    message: message ?? 'Hello world!',
    labels: ['bug'],
    userId: 'Testy McTestFace',
    attachments: attachments ?? [],
  );
}
