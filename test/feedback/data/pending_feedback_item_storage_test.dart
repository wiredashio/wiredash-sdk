import 'dart:convert';

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:transparent_image/transparent_image.dart';
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

      await withUuidV4Generator(
        mockUuidV4Generator,
        () => storage.persistItem(
          const FeedbackItem(
            deviceInfo: '<device info>',
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
            json.encode({
              'id': '<unique identifier>',
              'feedbackItem': {
                'deviceInfo': '<device info>',
                'email': 'email@example.com',
                'message': 'Hello world!',
                'type': 'bug',
                'user': 'Testy McTestFace'
              },
              'screenshotPath': '/<unique identifier>.png'
            }),
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

      when(mockSharedPreferences
              .getStringList('io.wiredash.pending_feedback_items'))
          .thenReturn([
        json.encode({
          'id': '<existing item id>',
          'feedbackItem': {
            'deviceInfo': '<existing item device info>',
            'email': '<existing item email>',
            'message': '<existing item message>',
            'type': '<existing item type>',
            'user': '<existing item user>'
          },
          'screenshotPath': '<existing item screenshot>'
        }),
      ]);

      await withUuidV4Generator(
        mockUuidV4Generator,
        () => storage.persistItem(
          const FeedbackItem(
            deviceInfo: '<device info>',
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
            json.encode({
              "id": "<existing item id>",
              "feedbackItem": {
                "deviceInfo": "<existing item device info>",
                "email": "<existing item email>",
                "message": "<existing item message>",
                "type": "<existing item type>",
                "user": "<existing item user>"
              },
              "screenshotPath": "<existing item screenshot>"
            }),
            json.encode({
              'id': '<unique identifier>',
              'feedbackItem': {
                'deviceInfo': '<device info>',
                'email': 'email@example.com',
                'message': 'Hello world!',
                'type': 'bug',
                'user': 'Testy McTestFace'
              },
              'screenshotPath': '/<unique identifier>.png'
            }),
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
            'deviceInfo': '<existing item device info>',
            'email': '<existing item email>',
            'message': '<existing item message>',
            'type': '<existing item type>',
            'user': '<existing item user>'
          },
          'screenshotPath': '<existing item screenshot>'
        }),
      ]);

      final item = (await storage.retrieveAllPendingItems()).single;
      await storage.clearPendingItem(item);

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
            'deviceInfo': '<device info for item to be preserved>',
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
            'deviceInfo': '<existing item device info>',
            'email': '<existing item email>',
            'message': '<existing item message>',
            'type': '<existing item type>',
            'user': '<existing item user>'
          },
          'screenshotPath': '<existing item screenshot>'
        }),
      ]);

      final item = (await storage.retrieveAllPendingItems())
          .singleWhere((element) => element.id == '<existing item id>');
      await storage.clearPendingItem(item);

      verify(
        mockSharedPreferences
            .setStringList('io.wiredash.pending_feedback_items', [
          json.encode({
            'id': '<id for item to be preserved>',
            'feedbackItem': {
              'deviceInfo': '<device info for item to be preserved>',
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
  });
}
