// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_ps.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/metadata/meta_data_collector.dart';
import 'package:wiredash/src/metadata/user_meta_data.dart';

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
        appInfo: AppInfo(
          bundleId: 'com.example.app',
          appName: 'Example App',
          version: '1.0.0',
          buildNumber: '12',
        ),
        buildInfo: BuildInfo(
          compilationMode: CompilationMode.debug,
          buildNumber: '65',
          buildCommit: 'abcdefg',
          buildVersion: '1.2.0-dev',
        ),
        deviceId: '8F821AB6-B3A7-41BA-882E-32D8367243C1',
        deviceInfo: DeviceInfo(
          deviceModel: 'Google Pixel 8',
        ),
        flutterInfo: FlutterInfo(
          platformLocale: 'en_US',
          platformSupportedLocales: ['en_US', 'de_DE'],
          padding: WiredashWindowPadding(left: 0, top: 66, right: 0, bottom: 0),
          physicalSize: Size(1080, 2088),
          physicalGeometry: Rect.zero,
          pixelRatio: 2.75,
          platformOS: 'android',
          platformOSVersion: 'RSR1.201013.001',
          platformVersion: '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on'
              ' "android_ia32"',
          textScaleFactor: 1,
          viewInsets:
              WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 685),
          platformBrightness: Brightness.dark,
          gestureInsets:
              WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
        ),
        email: 'email@example.com',
        message: 'Hello world!',
        labels: ['bug'],
        sessionMetadata: CustomizableWiredashMetaData()
          ..userId = 'Testy McTestFace'
          ..custom = {
            'customText': 'text',
            'nestedObject': {'frodo': 'ring', 'sam': 'lembas'},
            'ignoreNull': null, // ignores
            'function': () => null, // reports but doesn't crash
          }
          ..appLocale = 'de_DE',
        sdkVersion: 1,
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
      ).toRequestJson();

      expect(
        body,
        {
          'appLocale': 'de_DE',
          'appName': 'Example App',
          'attachments': [
            {
              'id': 'screenshot_123',
            },
            {
              'id': 'screenshot_124',
            }
          ],
          'buildCommit': 'abcdefg',
          'buildNumber': '65',
          'buildVersion': '1.2.0-dev',
          'bundleId': 'com.example.app',
          'compilationMode': 'debug',
          'customMetaData': {
            'customText': 'text',
            'nestedObject': {'frodo': 'ring', 'sam': 'lembas'},
          },
          'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
          'deviceModel': 'Google Pixel 8',
          'labels': ['bug'],
          'message': 'Hello world!',
          'sdkVersion': 1,
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
        appInfo: AppInfo(
          buildNumber: '1',
          version: '1.0.0',
          bundleId: 'com.example.app',
          appName: 'Example App',
        ),
        buildInfo: BuildInfo(
          compilationMode: CompilationMode.release,
        ),
        deviceId: '8F821AB6-B3A7-41BA-882E-32D8367243C1',
        flutterInfo: FlutterInfo(
          platformLocale: 'en_US',
          platformSupportedLocales: ['en_US', 'de_DE'],
          padding: WiredashWindowPadding(left: 0, top: 66, right: 0, bottom: 0),
          physicalSize: Size(1080, 2088),
          physicalGeometry: Rect.zero,
          pixelRatio: 2.75,
          platformOS: 'android',
          platformOSVersion: 'RSR1.201013.001',
          platformVersion: '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on'
              ' "android_ia32"',
          textScaleFactor: 1,
          viewInsets:
              WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 685),
          platformBrightness: Brightness.dark,
          gestureInsets:
              WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
        ),
        email: '',
        message: 'Hello world!',
        labels: ['bug'],
        sessionMetadata: CustomizableWiredashMetaData()
          ..userId = 'Testy McTestFace'
          ..appLocale = 'de_DE',
        sdkVersion: 1,
        attachments: [],
        deviceInfo: DeviceInfo(
          deviceModel: 'Google Pixel 8',
        ),
      ).toRequestJson();

      expect(
        body,
        {
          'appLocale': 'de_DE',
          'appName': 'Example App',
          'bundleId': 'com.example.app',
          'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
          'deviceModel': 'Google Pixel 8',
          'compilationMode': 'release',
          'labels': ['bug'],
          'message': 'Hello world!',
          'sdkVersion': 1,
          'platformLocale': 'en_US',
          'platformSupportedLocales': ['en_US', 'de_DE'],
          'platformDartVersion':
              '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on'
                  ' "android_ia32"',
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
        appLocale: 'en_US',
        appInfo: AppInfo(
          bundleId: 'com.example.app',
          appName: 'Example App',
          version: '1.0.0',
          buildNumber: '12',
        ),
        buildInfo: BuildInfo(
          compilationMode: CompilationMode.debug,
          // buildInfo wins over appInfo because buildInfo can be overwritten
          // with environment variables
          buildNumber: '65',
          buildCommit: 'abcdefg',
          buildVersion: '1.2.0-dev',
        ),
        deviceId: '8F821AB6-B3A7-41BA-882E-32D8367243C1',
        message: 'Cool app!',
        question:
            'How likely are you to recommend this app to a friend or colleague?',
        platformLocale: 'en_US',
        platformOS: 'android',
        platformOSVersion: '15',
        platformUserAgent: 'my user agent',
        score: PromoterScoreRating.rating6,
        sdkVersion: 173,
        userEmail: 'testy@mctest.face',
        userId: 'Testy McTestFace',
      );
      final body = ps.toRequestJson();

      expect(
        body,
        {
          'appLocale': 'en_US',
          'buildCommit': 'abcdefg',
          'buildNumber': '65',
          'buildVersion': '1.2.0-dev',
          'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
          'message': 'Cool app!',
          'platformLocale': 'en_US',
          'platformOS': 'android',
          'platformOSVersion': '15',
          'platformUserAgent': 'my user agent',
          'question':
              'How likely are you to recommend this app to a friend or colleague?',
          'score': 6,
          'sdkVersion': 173,
          'userEmail': 'testy@mctest.face',
          'userId': 'Testy McTestFace',
        },
      );
    });
  });
}
