import 'dart:convert';
import 'dart:ui';

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
import 'package:wiredash/src/feedback/data/pending_feedback_item.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item_storage.dart';
import 'package:wiredash/src/feedback/data/persisted_feedback_item.dart';

import '../../util/invocation_catcher.dart';

class FakeSharedPreferences extends Fake implements SharedPreferences {
  final Map<String, Object?> _store = {};

  final MethodInvocationCatcher setStringListInvocations =
      MethodInvocationCatcher('setStringList');

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    await setStringListInvocations.addMethodCall(args: [key, value]);
    _store[key] = value;
    return true;
  }

  final MethodInvocationCatcher getStringListInvocations =
      MethodInvocationCatcher('getStringList');
  @override
  List<String>? getStringList(String key) {
    final result = getStringListInvocations.addMethodCall(args: [key]);
    if (result != null) {
      return result as List<String>?;
    }
    return _store[key] as List<String>?;
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
          const PersistedFeedbackItem(
            appInfo: AppInfo(
              appLocale: 'de_DE',
            ),
            buildInfo: BuildInfo(compilationMode: CompilationMode.release),
            deviceId: '1234',
            deviceInfo: DeviceInfo(
              pixelRatio: 1.0,
              textScaleFactor: 1.0,
              platformLocale: "en_US",
              platformSupportedLocales: ['en_US', 'de_DE'],
              platformBrightness: Brightness.dark,
              gestureInsets:
                  WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
              padding:
                  WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
              viewInsets:
                  WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
              physicalGeometry: Rect.fromLTRB(0, 0, 0, 0),
              physicalSize: Size(800, 1200),
            ),
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
      expect(latestCall[1], [serializePendingFeedbackItem(pendingItem)]);

      expect(fileSystem.file('0.png').existsSync(), isTrue);
    });

    test('when has an existing item, preserves it while persisting the new one',
        () async {
      await fileSystem
          .file('<existing item screenshot>')
          .writeAsBytes(kTransparentImage);

      final existingItem = json.encode({
        'feedbackItem': {
          'appInfo': {
            'appLocale': 'de_DE',
          },
          'buildInfo': {
            'buildCommit': 'abcdef12',
            'buildNumber': '543',
            'buildVersion': '1.2.3',
            'compilationMode': 'release',
          },
          'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
          'deviceInfo': {
            'gestureInsets': [0.0, 0.0, 0.0, 0.0],
            'padding': [0.0, 66.0, 0.0, 0.0],
            'physicalGeometry': [0.0, 0.0, 0.0, 0.0],
            'physicalSize': [1080.0, 2088.0],
            'pixelRatio': 2.75,
            'platformBrightness': 'dark',
            'platformLocale': "en_US",
            'platformOS': 'android',
            'platformOSBuild': 'RSR1.201013.001',
            'platformSupportedLocales': ['en_US', 'de_DE'],
            'platformVersion':
                '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
            'textScaleFactor': 1.0,
            'viewInsets': [0.0, 0.0, 0.0, 685.0],
          },
          'email': '<existing item email>',
          'message': '<existing item message>',
          'sdkVersion': 1,
          'type': '<existing item type>',
          'user': '<existing item user>',
        },
        'id': '1',
        'screenshotPath': '<existing item screenshot>',
        'version': 1,
      });
      fakeSharedPreferences
          .setStringList('io.wiredash.pending_feedback_items', [existingItem]);

      final pendingFeedbackItem = await withUuidV4Generator(
        uuidGenerator,
        () => storage.addPendingItem(
          const PersistedFeedbackItem(
            appInfo: AppInfo(
              appLocale: 'de_DE',
            ),
            buildInfo: BuildInfo(
              compilationMode: CompilationMode.release,
              buildCommit: 'abcdef13',
              buildNumber: '543',
              buildVersion: '1.2.3',
            ),
            deviceId: '1234',
            deviceInfo: DeviceInfo(
              pixelRatio: 1.0,
              textScaleFactor: 1.0,
              platformLocale: "en_US",
              platformSupportedLocales: ['en_US', 'de_DE'],
              platformBrightness: Brightness.dark,
              gestureInsets:
                  WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
              padding:
                  WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
              viewInsets:
                  WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
              physicalGeometry: Rect.fromLTRB(0, 0, 0, 0),
              physicalSize: Size(800, 1200),
            ),
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
        serializePendingFeedbackItem(pendingFeedbackItem),
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
        'feedbackItem': {
          'appInfo': {
            'appIsDebug': true,
            'appLocale': 'de_DE',
          },
          'buildInfo': {
            'buildCommit': 'abcdef12',
            'buildNumber': '543',
            'buildVersion': '1.2.3',
            'compilationMode': 'release',
          },
          'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
          'deviceInfo': {
            'gestureInsets': [0.0, 0.0, 0.0, 0.0],
            'padding': [0.0, 66.0, 0.0, 0.0],
            'physicalSize': [1080.0, 2088.0],
            'physicalGeometry': [0.0, 0.0, 0.0, 0.0],
            'pixelRatio': 2.75,
            'platformBrightness': 'dark',
            'platformLocale': "en_US",
            'platformOS': 'android',
            'platformOSBuild': 'RSR1.201013.001',
            'platformSupportedLocales': ['en_US', 'de_DE'],
            'platformVersion':
                '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
            'textScaleFactor': 1.0,
            'viewInsets': [0.0, 0.0, 0.0, 685.0],
          },
          'email': '<existing item email>',
          'message': '<existing item message>',
          'sdkVersion': 1,
          'type': '<existing item type>',
          'user': '<existing item user>',
        },
        'id': '<existing item id>',
        'screenshotPath': '<existing item screenshot>',
        'version': 1,
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
        'feedbackItem': {
          'appInfo': {
            'appLocale': 'de_DE',
          },
          'buildInfo': {
            'buildCommit': 'abcdef12',
            'buildNumber': '543',
            'buildVersion': '1.2.3',
            'compilationMode': 'release',
          },
          'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
          'deviceInfo': {
            'gestureInsets': [0.0, 0.0, 0.0, 0.0],
            'padding': [0.0, 66.0, 0.0, 0.0],
            'physicalGeometry': [0.0, 0.0, 0.0, 0.0],
            'physicalSize': [1080.0, 2088.0],
            'pixelRatio': 2.75,
            'platformBrightness': 'dark',
            'platformLocale': "en_US",
            'platformOS': 'android',
            'platformOSBuild': 'RSR1.201013.001',
            'platformSupportedLocales': ['en_US', 'de_DE'],
            'platformVersion':
                '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
            'textScaleFactor': 1.0,
            'viewInsets': [0.0, 0.0, 0.0, 685.0],
          },
          'email': '<existing item email>',
          'message': '<existing item message>',
          'sdkVersion': 1,
          'type': '<existing item type>',
          'user': '<existing item user>',
        },
        'id': '<id for item to be preserved>',
        'screenshotPath': '<screenshot for item to be preserved>',
        'version': 1,
      });
      final item2 = json.encode({
        'feedbackItem': {
          'appInfo': {
            'appIsDebug': true,
            'appLocale': 'de_DE',
          },
          'buildInfo': {
            'buildCommit': 'abcdef12',
            'buildNumber': '543',
            'buildVersion': '1.2.3',
            'compilationMode': 'release',
          },
          'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
          'deviceInfo': {
            'gestureInsets': [0.0, 0.0, 0.0, 0.0],
            'padding': [0.0, 66.0, 0.0, 0.0],
            'physicalSize': [1080.0, 2088.0],
            'physicalGeometry': [0.0, 0.0, 0.0, 0.0],
            'pixelRatio': 2.75,
            'platformBrightness': 'dark',
            'platformLocale': "en_US",
            'platformOS': 'android',
            'platformOSBuild': 'RSR1.201013.001',
            'platformSupportedLocales': ['en_US', 'de_DE'],
            'platformVersion':
                '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
            'textScaleFactor': 1.0,
            'viewInsets': [0.0, 0.0, 0.0, 685.0],
          },
          'email': '<existing item email>',
          'message': '<existing item message>',
          'sdkVersion': 1,
          'type': '<existing item type>',
          'user': '<existing item user>',
        },
        'id': '<existing item id>',
        'screenshotPath': '<existing item screenshot>',
        'version': 1,
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
        'feedbackItem': {
          'appInfo': {
            'appLocale': 'de_DE',
          },
          'buildInfo': {
            'buildCommit': 'abcdef12',
            'buildNumber': '543',
            'buildVersion': '1.2.3',
            'compilationMode': 'release',
          },
          'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
          'deviceInfo': {
            'gestureInsets': [0.0, 0.0, 0.0, 0.0],
            'padding': [0.0, 66.0, 0.0, 0.0],
            'physicalGeometry': [0.0, 0.0, 0.0, 0.0],
            'physicalSize': [1080.0, 2088.0],
            'pixelRatio': 2.75,
            'platformBrightness': 'dark',
            'platformLocale': "en_US",
            'platformOS': 'android',
            'platformOSBuild': 'RSR1.201013.001',
            'platformSupportedLocales': ['en_US', 'de_DE'],
            'platformVersion':
                '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
            'textScaleFactor': 1.0,
            'viewInsets': [0.0, 0.0, 0.0, 685.0],
          },
          'email': '<existing item email>',
          'message': '<existing item message>',
          'sdkVersion': 1,
          'type': '<existing item type>',
          'user': '<existing item user>',
        },
        'id': '1',
        'screenshotPath': '<existing item screenshot>',
        'version': 1,
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
            'deserializePendingFeedbackItem',
            'PendingFeedbackItemStorage.retrieveAllPendingItems',
          ]));
      // reset error reporter after successful assertion
      FlutterError.onError = oldOnErrorHandler;

      // add pending item to remove the illegal one
      final pendingItem = await withUuidV4Generator(
        uuidGenerator,
        () => storage.addPendingItem(
          const PersistedFeedbackItem(
            appInfo: AppInfo(
              appLocale: 'de_DE',
            ),
            buildInfo: BuildInfo(compilationMode: CompilationMode.release),
            deviceId: '1234',
            deviceInfo: DeviceInfo(
              pixelRatio: 1.0,
              textScaleFactor: 1.0,
              platformLocale: "en_US",
              platformSupportedLocales: ['en_US', 'de_DE'],
              platformBrightness: Brightness.dark,
              gestureInsets:
                  WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
              padding:
                  WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
              viewInsets:
                  WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
              physicalGeometry: Rect.fromLTRB(0, 0, 0, 0),
              physicalSize: Size(800, 1200),
            ),
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
      expect(
          lastCall[1], [legalItem, serializePendingFeedbackItem(pendingItem)]);

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
