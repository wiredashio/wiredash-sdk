import 'dart:convert';

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter/foundation.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wiredash/src/common/device_info/device_info.dart';
import 'package:wiredash/src/common/utils/uuid.dart';
import 'package:wiredash/src/feedback/data/feedback_item.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item_storage.dart';

import '../../util/invocation_catcher.dart';

class FakeSharedPreferences extends Fake implements SharedPreferences {
  final Map<String, Object?> _store = {};

  final MethodInvocationCatcher setStringListInvocations =
      MethodInvocationCatcher('setStringList');
  @override
  Future<bool> setStringList(String key, List<String> value) async {
    final mockedReturnValue =
        setStringListInvocations.addAsyncMethodCall(args: [key, value]);
    if (mockedReturnValue != null) {
      return await mockedReturnValue.value as bool;
    }
    _store[key] = value;
    return true;
  }

  final MethodInvocationCatcher getStringListInvocations =
      MethodInvocationCatcher('getStringList');
  @override
  List<String>? getStringList(String key) {
    final mockedReturnValue =
        getStringListInvocations.addMethodCall(args: [key]);
    if (mockedReturnValue != null) {
      return mockedReturnValue.value as List<String>?;
    }
    return _store[key] as List<String>?;
  }

  final MethodInvocationCatcher setIntInvocations =
      MethodInvocationCatcher('setInt');
  @override
  Future<bool> setInt(String key, int value) async {
    final mockedReturnValue =
        setIntInvocations.addMethodCall(args: [key, value]);
    if (mockedReturnValue != null) {
      return await mockedReturnValue.value as bool;
    }
    _store[key] = value;
    return true;
  }

  final MethodInvocationCatcher getIntInvocations =
      MethodInvocationCatcher('getInt');
  @override
  int? getInt(String key) {
    final mockedReturnValue = getIntInvocations.addMethodCall(args: [key]);
    if (mockedReturnValue != null) {
      return mockedReturnValue.value as int?;
    }
    return _store[key] as int?;
  }
}

class IncrementalUuidV4Generator implements UuidV4Generator {
  var _next = 0;

  @override
  String generate() {
    final now = _next;
    _next++;
    return now.toString();
  }
}

void main() {
  group('PendingFeedbackItemStorage', () {
    late FileSystem fileSystem;
    late FakeSharedPreferences fakeSharedPreferences;
    late IncrementalUuidV4Generator uuidGenerator;
    late PendingFeedbackItemStorage storage;

    setUp(() {
      fileSystem = MemoryFileSystem.test();
      fakeSharedPreferences = FakeSharedPreferences();
      uuidGenerator = IncrementalUuidV4Generator();
      storage = PendingFeedbackItemStorage(
        fileSystem,
        () async => fakeSharedPreferences,
        () async => '',
      );
    });

    test('can persist one feedback item', () async {
      final pendingItem = await withUuidV4Generator(
        uuidGenerator,
        () => storage.addPendingItem(
          const FeedbackItem(
            deviceInfo: DeviceInfo(),
            email: 'email@example.com',
            message: 'Hello world!',
            type: 'bug',
            user: 'Testy McTestFace',
          ),
          kTransparentImage,
        ),
      );

      final latestCall = fakeSharedPreferences.setStringListInvocations.latest;
      expect(latestCall[0], 'io.wiredash.pending_feedback_items');
      expect(latestCall[1], [json.encode(pendingItem.toJson())]);

      expect(fileSystem.file('0.png').existsSync(), isTrue);
    });

    test('when has an existing item, preserves it while persisting the new one',
        () async {
      await fileSystem
          .file('<existing item screenshot>')
          .writeAsBytes(kTransparentImage);

      final existingItem = json.encode({
        'id': '1',
        'feedbackItem': {
          'deviceInfo': {
            'appIsDebug': true,
            'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
            'locale': 'en_US',
            'padding': [0.0, 66.0, 0.0, 0.0],
            'physicalSize': [1080.0, 2088.0],
            'pixelRatio': 2.75,
            'platformOS': 'android',
            'platformOSBuild': 'RSR1.201013.001',
            'platformVersion':
                '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
            'textScaleFactor': 1.0,
            'viewInsets': [0.0, 0.0, 0.0, 685.0],
          },
          'email': '<existing item email>',
          'message': '<existing item message>',
          'type': '<existing item type>',
          'user': '<existing item user>',
          'sdkVersion': 1,
        },
        'screenshotPath': '<existing item screenshot>'
      });
      fakeSharedPreferences
          .setStringList('io.wiredash.pending_feedback_items', [existingItem]);

      final pendingFeedbackItem = await withUuidV4Generator(
        uuidGenerator,
        () => storage.addPendingItem(
          const FeedbackItem(
            deviceInfo: DeviceInfo(),
            email: 'email@example.com',
            message: 'Hello world!',
            type: 'bug',
            user: 'Testy McTestFace',
          ),
          kTransparentImage,
        ),
      );

      final lastCall = fakeSharedPreferences.setStringListInvocations.latest;
      expect(lastCall[0], 'io.wiredash.pending_feedback_items');
      expect(lastCall[1], [
        existingItem,
        json.encode(
          pendingFeedbackItem.toJson(),
        )
      ]);

      expect(
          fileSystem.file('<existing item screenshot>').existsSync(), isTrue);

      expect(fileSystem.file('0.png').existsSync(), isTrue);
    });

    test('can clear one feedback item', () async {
      await fileSystem
          .file('<existing item screenshot>')
          .writeAsBytes(kTransparentImage);

      expect(
        fileSystem.file('<existing item screenshot>').existsSync(),
        isTrue,
      );

      final pendingItem = json.encode({
        'id': '<existing item id>',
        'feedbackItem': {
          'deviceInfo': {
            'appIsDebug': true,
            'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
            'locale': 'en_US',
            'padding': [0.0, 66.0, 0.0, 0.0],
            'physicalSize': [1080.0, 2088.0],
            'pixelRatio': 2.75,
            'platformOS': 'android',
            'platformOSBuild': 'RSR1.201013.001',
            'platformVersion':
                '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
            'textScaleFactor': 1.0,
            'viewInsets': [0.0, 0.0, 0.0, 685.0],
          },
          'email': '<existing item email>',
          'message': '<existing item message>',
          'type': '<existing item type>',
          'user': '<existing item user>',
          'sdkVersion': 1,
        },
        'screenshotPath': '<existing item screenshot>'
      });

      await fakeSharedPreferences
          .setStringList('io.wiredash.pending_feedback_items', [pendingItem]);

      await storage.clearPendingItem('<existing item id>');

      final saved = fakeSharedPreferences
          .getStringList('io.wiredash.pending_feedback_items');
      expect(saved, []);

      expect(
        fileSystem.file('<existing item screenshot>').existsSync(),
        isFalse,
      );
    });

    test('when has two items, preserves one while clearing the other one',
        () async {
      await fileSystem
          .file('<screenshot for item to be preserved>')
          .writeAsBytes(kTransparentImage);

      await fileSystem
          .file('<existing item screenshot>')
          .writeAsBytes(kTransparentImage);

      expect(
        fileSystem.file('<screenshot for item to be preserved>').existsSync(),
        isTrue,
      );

      expect(
        fileSystem.file('<existing item screenshot>').existsSync(),
        isTrue,
      );

      final item1 = json.encode({
        'id': '<id for item to be preserved>',
        'feedbackItem': {
          'deviceInfo': {
            'appIsDebug': true,
            'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
            'locale': 'en_US',
            'padding': [0.0, 66.0, 0.0, 0.0],
            'physicalSize': [1080.0, 2088.0],
            'pixelRatio': 2.75,
            'platformOS': 'android',
            'platformOSBuild': 'RSR1.201013.001',
            'platformVersion':
                '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
            'textScaleFactor': 1.0,
            'viewInsets': [0.0, 0.0, 0.0, 685.0],
          },
          'email': '<email for item to be preserved>',
          'message': '<message for item to be preserved>',
          'type': '<type for item to be preserved>',
          'user': '<item user for item to be preserved>',
          'sdkVersion': 1,
        },
        'screenshotPath': '<screenshot for item to be preserved>'
      });
      final item2 = json.encode({
        'id': '<existing item id>',
        'feedbackItem': {
          'deviceInfo': {
            'appIsDebug': true,
            'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
            'locale': 'en_US',
            'padding': [0.0, 66.0, 0.0, 0.0],
            'physicalSize': [1080.0, 2088.0],
            'pixelRatio': 2.75,
            'platformOS': 'android',
            'platformOSBuild': 'RSR1.201013.001',
            'platformVersion':
                '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
            'textScaleFactor': 1.0,
            'viewInsets': [0.0, 0.0, 0.0, 685.0],
          },
          'email': '<existing item email>',
          'message': '<existing item message>',
          'type': '<existing item type>',
          'user': '<existing item user>',
          'sdkVersion': 1,
        },
        'screenshotPath': '<existing item screenshot>'
      });
      await fakeSharedPreferences
          .setStringList('io.wiredash.pending_feedback_items', [item1, item2]);

      await storage.clearPendingItem('<existing item id>');

      final lastCall = fakeSharedPreferences.setStringListInvocations.latest;
      expect(lastCall[0], 'io.wiredash.pending_feedback_items');
      expect(lastCall[1], [item1]);

      expect(
        fileSystem.file('<screenshot for item to be preserved>').existsSync(),
        isTrue,
      );

      expect(
        fileSystem.file('<existing item screenshot>').existsSync(),
        isFalse,
      );
    });

    test(
        'does not crash when clearing an item and the screenshot file does not exist',
        () async {
      final item = json.encode({
        'id': '<existing item id>',
        'feedbackItem': {
          'deviceInfo': {},
          'email': '<existing item email>',
          'message': '<existing item message>',
          'type': '<existing item type>',
          'user': '<existing item user>'
        },
        'screenshotPath': '<existing item screenshot>'
      });
      await fakeSharedPreferences
          .setStringList('io.wiredash.pending_feedback_items', [item]);
      await storage.clearPendingItem('<existing item id>');

      // If the test didn't crash until this point, it's considered a passing test.
    });

    test('removes items which can not be parsed', () async {
      await fileSystem
          .file('<screenshot for invalid item>')
          .writeAsBytes(kTransparentImage);

      await fileSystem
          .file('<existing item screenshot>')
          .writeAsBytes(kTransparentImage);

      expect(
        fileSystem.file('<screenshot for invalid item>').existsSync(),
        isTrue,
      );

      expect(
        fileSystem.file('<existing item screenshot>').existsSync(),
        isTrue,
      );

      final illegalItem = json.encode({
        // item has some required properties missing
        'id': '<screenshot for invalid item>',
        'feedbackItem': {
          'email': '<email for item to be preserved>',
          'type': '<type for item to be preserved>',
        },
        'screenshotPath': '<screenshot for invalid item>'
      });

      final legalItem = json.encode({
        'id': '<id for item to be preserved>',
        'feedbackItem': {
          'deviceInfo': {
            'appIsDebug': true,
            'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
            'locale': 'en_US',
            'padding': [0.0, 66.0, 0.0, 0.0],
            'physicalSize': [1080.0, 2088.0],
            'pixelRatio': 2.75,
            'platformOS': 'android',
            'platformOSBuild': 'RSR1.201013.001',
            'platformVersion':
                '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
            'textScaleFactor': 1.0,
            'viewInsets': [0.0, 0.0, 0.0, 685.0],
          },
          'email': '<email for item to be preserved>',
          'message': '<message for item to be preserved>',
          'type': '<type for item to be preserved>',
          'user': '<item user for item to be preserved>',
          'sdkVersion': 1,
        },
        'screenshotPath': '<screenshot for item to be preserved>'
      });

      await fakeSharedPreferences.setStringList(
          'io.wiredash.pending_feedback_items', [illegalItem, legalItem]);

      final oldOnErrorHandler = FlutterError.onError;
      late FlutterErrorDetails caught;
      FlutterError.onError = (FlutterErrorDetails details) {
        caught = details;
      };

      final retrieved = await storage.retrieveAllPendingItems();

      // method returns only valid items
      expect(retrieved.length, 1);

      // error was reported to Flutter.onError
      expect(
          caught.stack.toString(),
          stringContainsInOrder([
            'PendingFeedbackItem.fromJson',
            'PendingFeedbackItemStorage.retrieveAllPendingItems',
          ]));
      // reset error reporter after successful assertion
      FlutterError.onError = oldOnErrorHandler;

      // add pending item to remove the illegal one
      final pendingItem = await withUuidV4Generator(
        uuidGenerator,
        () => storage.addPendingItem(
          const FeedbackItem(
            deviceInfo: DeviceInfo(),
            email: 'email@example.com',
            message: 'Hello world!',
            type: 'bug',
            user: 'Testy McTestFace',
          ),
          kTransparentImage,
        ),
      );

      // verify the invalid item was removed, while the legal and new item
      // where saved
      final lastCall = fakeSharedPreferences.setStringListInvocations.latest;
      expect(lastCall[0], 'io.wiredash.pending_feedback_items');
      expect(lastCall[1], [legalItem, json.encode(pendingItem.toJson())]);

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
  });
}
