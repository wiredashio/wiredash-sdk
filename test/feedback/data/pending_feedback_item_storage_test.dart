import 'dart:convert';

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter/foundation.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wiredash/src/common/device_info/device_info.dart';
import 'package:wiredash/src/common/utils/uuid.dart';
import 'package:wiredash/src/feedback/data/feedback_item.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item_storage.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockUuidV4Generator extends Mock implements UuidV4Generator {}

void main() {
  group('PendingFeedbackItemStorage', () {
    FileSystem fileSystem;
    MockSharedPreferences mockSharedPreferences;
    MockUuidV4Generator mockUuidV4Generator;
    PendingFeedbackItemStorage storage;

    setUp(() {
      fileSystem = MemoryFileSystem.test();
      mockSharedPreferences = MockSharedPreferences();
      mockUuidV4Generator = MockUuidV4Generator();
      storage = PendingFeedbackItemStorage(
        fileSystem,
        () async => mockSharedPreferences,
        () async => '',
      );
    });

    test('can persist one feedback item', () async {
      when(mockUuidV4Generator.generate()).thenReturn('<unique identifier>');

      final pendingItem = await withUuidV4Generator(
        mockUuidV4Generator,
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

      verify(
        mockSharedPreferences.setStringList(
          'io.wiredash.pending_feedback_items',
          [
            json.encode(pendingItem.toJson()),
          ],
        ),
      );

      expect(fileSystem.file('<unique identifier>.png').existsSync(), isTrue);
    });

    test('when has an existing item, preserves it while persisting the new one',
        () async {
      when(mockUuidV4Generator.generate()).thenReturn('<unique identifier>');

      await fileSystem
          .file('<existing item screenshot>')
          .writeAsBytes(kTransparentImage);

      final existingItem = json.encode({
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
            'platformOSVersion': 'RSR1.201013.001',
            'dartVersion':
                '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
            'textScaleFactor': 1.0,
            'viewInsets': [0.0, 0.0, 0.0, 685.0],
          },
          'email': '<existing item email>',
          'message': '<existing item message>',
          'type': '<existing item type>',
          'user': '<existing item user>'
        },
        'screenshotPath': '<existing item screenshot>'
      });
      when(mockSharedPreferences
              .getStringList('io.wiredash.pending_feedback_items'))
          .thenReturn([existingItem]);

      final pendingFeedbackItem = await withUuidV4Generator(
        mockUuidV4Generator,
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

      verify(
        mockSharedPreferences.setStringList(
          'io.wiredash.pending_feedback_items',
          [
            existingItem,
            json.encode(pendingFeedbackItem.toJson()),
          ],
        ),
      );

      expect(
        fileSystem.file('<existing item screenshot>').existsSync(),
        isTrue,
      );

      expect(fileSystem.file('<unique identifier>.png').existsSync(), isTrue);
    });

    test('can clear one feedback item', () async {
      await fileSystem
          .file('<existing item screenshot>')
          .writeAsBytes(kTransparentImage);

      expect(
        fileSystem.file('<existing item screenshot>').existsSync(),
        isTrue,
      );

      when(mockSharedPreferences
              .getStringList('io.wiredash.pending_feedback_items'))
          .thenReturn([
        json.encode({
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
              'platformOSVersion': 'RSR1.201013.001',
              'dartVersion':
                  '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
              'textScaleFactor': 1.0,
              'viewInsets': [0.0, 0.0, 0.0, 685.0],
            },
            'email': '<existing item email>',
            'message': '<existing item message>',
            'type': '<existing item type>',
            'user': '<existing item user>'
          },
          'screenshotPath': '<existing item screenshot>'
        }),
      ]);

      await storage.clearPendingItem('<existing item id>');

      verify(
        mockSharedPreferences
            .setStringList('io.wiredash.pending_feedback_items', []),
      );

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

      when(mockSharedPreferences
              .getStringList('io.wiredash.pending_feedback_items'))
          .thenReturn([
        json.encode({
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
              'platformOSVersion': 'RSR1.201013.001',
              'dartVersion':
                  '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
              'textScaleFactor': 1.0,
              'viewInsets': [0.0, 0.0, 0.0, 685.0],
            },
            'email': '<email for item to be preserved>',
            'message': '<message for item to be preserved>',
            'type': '<type for item to be preserved>',
            'user': '<item user for item to be preserved>'
          },
          'screenshotPath': '<screenshot for item to be preserved>'
        }),
        json.encode({
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
              'platformOSVersion': 'RSR1.201013.001',
              'dartVersion':
                  '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
              'textScaleFactor': 1.0,
              'viewInsets': [0.0, 0.0, 0.0, 685.0],
            },
            'email': '<existing item email>',
            'message': '<existing item message>',
            'type': '<existing item type>',
            'user': '<existing item user>'
          },
          'screenshotPath': '<existing item screenshot>'
        }),
      ]);

      await storage.clearPendingItem('<existing item id>');

      verify(
        mockSharedPreferences
            .setStringList('io.wiredash.pending_feedback_items', [
          json.encode({
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
                'platformOSVersion': 'RSR1.201013.001',
                'dartVersion':
                    '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
                'textScaleFactor': 1.0,
                'viewInsets': [0.0, 0.0, 0.0, 685.0],
              },
              'email': '<email for item to be preserved>',
              'message': '<message for item to be preserved>',
              'type': '<type for item to be preserved>',
              'user': '<item user for item to be preserved>'
            },
            'screenshotPath': '<screenshot for item to be preserved>'
          }),
        ]),
      );

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
      when(mockSharedPreferences
              .getStringList('io.wiredash.pending_feedback_items'))
          .thenReturn([
        json.encode({
          'id': '<existing item id>',
          'feedbackItem': {
            'deviceInfo': {},
            'email': '<existing item email>',
            'message': '<existing item message>',
            'type': '<existing item type>',
            'user': '<existing item user>'
          },
          'screenshotPath': '<existing item screenshot>'
        }),
      ]);

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
            'platformOSVersion': 'RSR1.201013.001',
            'dartVersion':
                '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
            'textScaleFactor': 1.0,
            'viewInsets': [0.0, 0.0, 0.0, 685.0],
          },
          'email': '<email for item to be preserved>',
          'message': '<message for item to be preserved>',
          'type': '<type for item to be preserved>',
          'user': '<item user for item to be preserved>'
        },
        'screenshotPath': '<screenshot for item to be preserved>'
      });

      when(mockSharedPreferences
              .getStringList('io.wiredash.pending_feedback_items'))
          .thenReturn([illegalItem, legalItem]);

      final oldOnErrorHandler = FlutterError.onError;
      FlutterErrorDetails caught;
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
      when(mockUuidV4Generator.generate()).thenReturn('<unique identifier>');
      final pendingItem = await withUuidV4Generator(
        mockUuidV4Generator,
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
      verify(mockSharedPreferences.setStringList(
          'io.wiredash.pending_feedback_items',
          [legalItem, json.encode(pendingItem.toJson())]));

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
