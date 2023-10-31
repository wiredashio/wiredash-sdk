// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_ps.dart';
import 'package:wiredash/src/_wiredash_internal.dart';

void main() {
  group('Serialize feedback item', () {
    test('FeedbackBody.toJson()', () {
      final oldOnErrorHandler = FlutterError.onError;
      late FlutterErrorDetails caught;
      FlutterError.onError = (FlutterErrorDetails details) {
        caught = details;
      };
      addTearDown(() {
        FlutterError.onError = oldOnErrorHandler;
      });

      final body = FeedbackItem(
        attachments: [
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.uploaded(
              AttachmentId('screenshot_123'),
            ),
          ),
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.uploaded(
              AttachmentId('screenshot_124'),
            ),
          ),
        ],
        message: 'Hello world!',
        labels: ['bug', 'lbl-1234'],
        metadata: AllMetaData(
          buildVersion: '1.2.0-dev',
          buildNumber: '65',
          buildCommit: 'abcdefg',
          appLocale: 'de_DE',
          windowPixelRatio: 2.75,
          installId: '8F821AB6-B3A7-41BA-882E-32D8367243C1',
          sdkVersion: 174,
          compilationMode: CompilationMode.release,
          windowTextScaleFactor: 1.0,
          userEmail: 'email@example.com',
          platformLocale: 'en_US',
          platformSupportedLocales: ['en_US', 'de_DE'],
          platformBrightness: Brightness.dark,
          platformGestureInsets:
              WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
          windowPadding:
              WiredashWindowPadding(left: 0, top: 66, right: 0, bottom: 0),
          windowInsets:
              WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 685),
          physicalGeometry: Rect.zero,
          windowSize: Size(1080, 2088),
          appName: 'Example App',
          bundleId: 'com.example.app',
          custom: {
            'customText': 'text',
            'nestedObject': {'frodo': 'ring', 'sam': 'lembas'},
            'ignoreNull': null, // ignores
            'function': () => null, // reports but doesn't crash
          },
          deviceModel: 'Google Pixel 8',
          platformOS: 'android',
          platformOSVersion: 'RSR1.201013.001',
          platformDartVersion:
              '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on '
              '"android_ia32"',
          userId: 'Testy McTestFace',
        ),
      ).toRequestJson();

      expect(
        body,
        {
          'attachments': [
            {
              'id': 'screenshot_123',
            },
            {
              'id': 'screenshot_124',
            }
          ],
          'labels': ['bug', 'lbl-1234'],
          'message': 'Hello world!',
          'metadata': {
            'appLocale': 'de_DE',
            'appName': 'Example App',
            'buildCommit': 'abcdefg',
            'buildNumber': '65',
            'buildVersion': '1.2.0-dev',
            'bundleId': 'com.example.app',
            'compilationMode': 'release',
            'custom': {
              'customText': 'text',
              'nestedObject': {'frodo': 'ring', 'sam': 'lembas'},
            },
            'installId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
            'deviceModel': 'Google Pixel 8',
            'sdkVersion': 174,
            'platformLocale': 'en_US',
            'platformSupportedLocales': ['en_US', 'de_DE'],
            'platformDartVersion':
                '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200)'
                    ' on "android_ia32"',
            'platformOS': 'android',
            'platformOSVersion': 'RSR1.201013.001',
            'userEmail': 'email@example.com',
            'userId': 'Testy McTestFace',
            'physicalGeometry': [0.0, 0.0, 0.0, 0.0],
            'platformBrightness': 'dark',
            'platformGestureInsets': [0.0, 0.0, 0.0, 0.0],
            'windowPixelRatio': 2.75,
            'windowSize': [1080.0, 2088.0],
            'windowTextScaleFactor': 1.0,
            'windowInsets': [0.0, 0.0, 0.0, 685.0],
            'windowPadding': [0.0, 66.0, 0.0, 0.0],
          },
        },
      );
      expect(
        caught.toString(),
        stringContainsInOrder([
          'customMetaData',
          'property function',
        ]),
      );
    });

    test('empty email should not be sent as empty string', () {
      final body = FeedbackItem(
        attachments: [],
        message: 'Hello world!',
        labels: ['bug', 'lbl-1234'],
        metadata: AllMetaData(
          buildVersion: '1.2.0-dev',
          buildNumber: '65',
          buildCommit: 'abcdefg',
          appLocale: 'de_DE',
          windowPixelRatio: 2.75,
          installId: '8F821AB6-B3A7-41BA-882E-32D8367243C1',
          sdkVersion: 174,
          compilationMode: CompilationMode.release,
          windowTextScaleFactor: 1.0,
          platformLocale: 'en_US',
          platformSupportedLocales: ['en_US', 'de_DE'],
          platformBrightness: Brightness.dark,
          platformGestureInsets:
              WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
          windowPadding:
              WiredashWindowPadding(left: 0, top: 66, right: 0, bottom: 0),
          windowInsets:
              WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 685),
          physicalGeometry: Rect.zero,
          windowSize: Size(1080, 2088),
          appName: 'Example App',
          bundleId: 'com.example.app',
          custom: {
            'customText': 'text',
            'nestedObject': {'frodo': 'ring', 'sam': 'lembas'},
          },
          deviceModel: 'Google Pixel 8',
          platformOS: 'android',
          platformOSVersion: 'RSR1.201013.001',
          platformDartVersion:
              '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on '
              '"android_ia32"',
          userId: 'Testy McTestFace',
          userEmail: '', // empty string
        ),
      ).toRequestJson();

      expect(
        body,
        {
          'labels': ['bug', 'lbl-1234'],
          'message': 'Hello world!',
          'metadata': {
            'appLocale': 'de_DE',
            'appName': 'Example App',
            'buildCommit': 'abcdefg',
            'buildNumber': '65',
            'buildVersion': '1.2.0-dev',
            'bundleId': 'com.example.app',
            'compilationMode': 'release',
            'custom': {
              'customText': 'text',
              'nestedObject': {'frodo': 'ring', 'sam': 'lembas'},
            },
            'installId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
            'deviceModel': 'Google Pixel 8',
            'sdkVersion': 174,
            'platformLocale': 'en_US',
            'platformSupportedLocales': ['en_US', 'de_DE'],
            'platformDartVersion':
                '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200)'
                    ' on "android_ia32"',
            'platformOS': 'android',
            'platformOSVersion': 'RSR1.201013.001',
            'userId': 'Testy McTestFace',
            'physicalGeometry': [0.0, 0.0, 0.0, 0.0],
            'platformBrightness': 'dark',
            'platformGestureInsets': [0.0, 0.0, 0.0, 0.0],
            'windowPixelRatio': 2.75,
            'windowSize': [1080.0, 2088.0],
            'windowTextScaleFactor': 1.0,
            'windowInsets': [0.0, 0.0, 0.0, 685.0],
            'windowPadding': [0.0, 66.0, 0.0, 0.0],
          },
        },
      );
    });

    test('parse official error message', () {
      final exception = WiredashApiException(
        message: 'sdk message',
        response: Response(
          '''{"errorCode":-1,"errorMessage":"Cannot read properties of undefined (reading '0')"}''',
          400,
        ),
      );
      expect(exception.message, 'sdk message');
      expect(
        exception.messageFromServer,
        "[-1] Cannot read properties of undefined (reading '0')",
      );
    });
  });

  group('Serialize Promoter Score', () {
    test('PromoterScoreRequestBody.toBody()', () {
      final ps = PromoterScoreRequestBody(
        message: 'Cool app!',
        question:
            'How likely are you to recommend this app to a friend or colleague?',
        score: PromoterScoreRating.rating6,
        metadata: AllMetaData(
          buildVersion: '1.2.3',
          buildNumber: '543',
          buildCommit: 'abcdefg',
          appLocale: 'de_DE',
          windowPixelRatio: 2.75,
          installId: '8F821AB6-B3A7-41BA-882E-32D8367243C1',
          sdkVersion: 174,
          compilationMode: CompilationMode.release,
          windowTextScaleFactor: 1.0,
          userEmail: 'email@example.com',
          platformLocale: 'en_US',
          platformSupportedLocales: ['en_US', 'de_DE'],
          platformBrightness: Brightness.dark,
          platformGestureInsets:
              WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
          windowPadding:
              WiredashWindowPadding(left: 0, top: 66, right: 0, bottom: 0),
          windowInsets:
              WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 685),
          physicalGeometry: Rect.zero,
          windowSize: Size(1280, 720),
          appName: 'Example App',
          bundleId: 'com.example.app',
          custom: {
            'customText': 'text',
            'nestedObject': {'frodo': 'ring', 'sam': 'lembas'},
          },
          deviceModel: 'Google Pixel 8',
          platformOS: 'android',
          platformOSVersion: 'RSR1.201013.001',
          platformDartVersion:
              '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on '
              '"android_ia32"',
          userId: 'Testy McTestFace',
        ),
      );
      final body = ps.toRequestJson();

      expect(
        body,
        {
          'message': 'Cool app!',
          'question':
              'How likely are you to recommend this app to a friend or colleague?',
          'score': 6,
          'metadata': {
            'appLocale': 'de_DE',
            'appName': 'Example App',
            'buildCommit': 'abcdefg',
            'buildNumber': '543',
            'buildVersion': '1.2.3',
            'bundleId': 'com.example.app',
            'compilationMode': 'release',
            'custom': {
              'customText': 'text',
              'nestedObject': {'frodo': 'ring', 'sam': 'lembas'},
            },
            'installId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
            'deviceModel': 'Google Pixel 8',
            'sdkVersion': 174,
            'platformLocale': 'en_US',
            'platformSupportedLocales': ['en_US', 'de_DE'],
            'platformDartVersion':
                '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200)'
                    ' on "android_ia32"',
            'platformOS': 'android',
            'platformOSVersion': 'RSR1.201013.001',
            'userId': 'Testy McTestFace',
            'userEmail': 'email@example.com',
            'physicalGeometry': [0.0, 0.0, 0.0, 0.0],
            'platformBrightness': 'dark',
            'platformGestureInsets': [0.0, 0.0, 0.0, 0.0],
            'windowPixelRatio': 2.75,
            'windowSize': [1280.0, 720.0],
            'windowTextScaleFactor': 1.0,
            'windowInsets': [0.0, 0.0, 0.0, 685.0],
            'windowPadding': [0.0, 66.0, 0.0, 0.0],
          },
        },
      );
    });
  });

  test('API points towards production API', () {
    final wiredashApiFile = File('lib/src/core/network/wiredash_api.dart');
    final content = wiredashApiFile.readAsStringSync();
    expect(content, contains('https://api.wiredash.io/sdk'));
    expect(content, isNot(contains('https://api.wiredash.dev/sdk')));
  });
}
