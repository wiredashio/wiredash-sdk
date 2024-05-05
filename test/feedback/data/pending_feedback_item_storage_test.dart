import 'dart:convert';
import 'dart:ui';

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item_storage.dart';

import '../../util/flutter_error.dart';
import '../../util/invocation_catcher.dart';

void main() {
  group('PendingFeedbackItemStorage', () {
    late FileSystem fileSystem;
    late InMemorySharedPreferences prefs;
    late WuidGenerator wuidGenerator;
    late PendingFeedbackItemStorage storage;

    setUp(() {
      fileSystem = MemoryFileSystem.test();
      prefs = InMemorySharedPreferences();
      wuidGenerator = IncrementalIdGenerator();
      storage = PendingFeedbackItemStorage(
        fileSystem: fileSystem,
        sharedPreferencesProvider: () async => prefs,
        dirPathProvider: () async => '.',
        wuidGenerator: wuidGenerator,
      );
    });

    List<String> filesOnDisk() =>
        fileSystem.directory('/').listSync().map((it) => it.path).toList()
          ..sort();

    test('can persist one feedback item', () async {
      await fileSystem.file('existing.png').writeAsBytes(kTransparentImage);

      final item = createFeedback(
        attachments: [
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.inMemory(kTransparentImage),
          ),
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.uploaded(AttachmentId('453')),
          ),
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.file('existing.png'),
          ),
        ],
      );
      final pendingItem = await storage.addPendingItem(item);

      expect(
        pendingItem.feedbackItem.attachments![0].file,
        FileDataEventuallyOnDisk.file('00000000.png'),
      );
      expect(
        pendingItem.feedbackItem.attachments![1].file,
        FileDataEventuallyOnDisk.uploaded(AttachmentId('453')),
      );
      expect(
        pendingItem.feedbackItem.attachments![2].file,
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
        '00000000.png',
        'existing.png',
      ]);
    });

    test('store a second item without overriding the first one', () async {
      final firstFeedback = createFeedback(
        attachments: [
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.inMemory(kTransparentImage),
          ),
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.inMemory(kTransparentImage),
          ),
        ],
      );
      final firstItem = await storage.addPendingItem(firstFeedback);

      final secondFeedback = createFeedback(
        attachments: [
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.inMemory(kTransparentImage),
          ),
        ],
      );
      final secondItem = await storage.addPendingItem(secondFeedback);

      expect(
        await storage.retrieveAllPendingItems(),
        [firstItem, secondItem],
      );

      final allAttachments = [
        ...firstItem.feedbackItem.attachments!,
        ...secondItem.feedbackItem.attachments!,
      ];
      // all items must be distinct (different ids)
      expect(allAttachments, allAttachments.toSet().toList());

      // 3 saved files
      expect(filesOnDisk(), [
        '00000000.png',
        '00000001.png',
        '00000002.png',
      ]);
    });

    test('can clear one feedback item', () async {
      final item = createFeedback(
        attachments: [
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.inMemory(kTransparentImage),
          ),
        ],
      );
      final pendingItem = await storage.addPendingItem(item);
      expect(await storage.retrieveAllPendingItems(), [pendingItem]);
      expect(filesOnDisk(), ['00000000.png']);

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
          ),
        ],
      );
      final firstPending = await storage.addPendingItem(first);
      expect(firstPending.id, first.feedbackId);
      expect(filesOnDisk(), ['00000000.png']);

      final second = createFeedback(
        attachments: [
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.inMemory(kTransparentImage),
          ),
        ],
      );
      final secondPending = await storage.addPendingItem(second);
      expect(secondPending.id, second.feedbackId);

      expect(filesOnDisk(), ['00000000.png', '00000001.png']);
      expect(
        await storage.retrieveAllPendingItems(),
        [firstPending, secondPending],
      );

      await storage.clearPendingItem(firstPending.id);

      expect(await storage.retrieveAllPendingItems(), [secondPending]);
      expect(filesOnDisk(), ['00000001.png']);
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
        'screenshotPath': '<screenshot for invalid item>',
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

      final errors = captureFlutterErrors();
      final retrieved = await storage.retrieveAllPendingItems();

      // method returns only valid items
      expect(retrieved.length, 1);

      expect(errors.warnings, isNotEmpty);
      // error was reported to Flutter.onError
      expect(
        errors.warnings[0].stack.toString(),
        stringContainsInOrder([
          'deserializePendingFeedbackItem',
          'PendingFeedbackItemStorage.retrieveAllPendingItems',
        ]),
      );

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
          ),
        ],
      );
      final firstPending = await storage.addPendingItem(first);
      expect(firstPending.id, first.feedbackId);
      expect(filesOnDisk(), ['00000000.png']);

      final second = createFeedback(
        attachments: [
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.inMemory(kTransparentImage),
          ),
        ],
      );
      final secondPending = await storage.addPendingItem(second);
      expect(secondPending.id, second.feedbackId);

      expect(filesOnDisk(), ['00000000.png', '00000001.png']);
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
            ),
          ],
        ),
      );
      await storage.updatePendingItem(update);

      expect(await storage.retrieveAllPendingItems(), [secondPending, update]);
      expect(filesOnDisk(), ['00000001.png']);
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
class IncrementalIdGenerator
    with OnKeyCreatedNotifier
    implements WuidGenerator {
  var _nextInt = 0;

  @override
  String generateId(int length) {
    final now = _nextInt;
    _nextInt++;
    return now.toString().padLeft(length, '0');
  }

  final Map<String, String> _cache = {};

  @override
  Future<String> generatePersistedId(String key, int length) async {
    final cached = _cache[key];
    if (cached != null) {
      return cached;
    }
    return _cache[key] = generateId(length);
  }
}

FeedbackItem createFeedback({
  List<PersistedAttachment>? attachments,
  String? message,
}) {
  return FeedbackItem(
    feedbackId: nanoid(),
    metadata: const AllMetaData(
      appLocale: 'en_US',
      appName: 'MyApp',
      buildCommit: 'ab12345',
      buildNumber: '190',
      buildVersion: '1.9.0',
      bundleId: 'com.example.app',
      compilationMode: CompilationMode.profile,
      custom: {'customKey': 'customValue'},
      deviceModel: 'Google Pixel 8',
      installId: '01234567890123456',
      platformBrightness: Brightness.light,
      platformDartVersion: '3.2.0',
      platformGestureInsets:
          WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
      platformLocale: 'en_US',
      platformOS: 'Android',
      platformOSVersion: '11',
      platformSupportedLocales: ['en_US', 'de_DE'],
      sdkVersion: 200,
      userId: 'Testy McTestFace',
      userEmail: 'email@example.com',
      windowInsets: WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
      windowPadding:
          WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
      windowPixelRatio: 2.0,
      windowSize: Size(800, 1200),
      windowTextScaleFactor: 1.0,
    ),
    attachments: attachments,
    message: message ?? 'Hello world!',
  );
}
