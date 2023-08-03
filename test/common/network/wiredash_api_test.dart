// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/network/wiredash_api.dart';
import 'package:wiredash/src/metadata/build_info/app_info.dart';
import 'package:wiredash/src/metadata/build_info/build_info.dart';
import 'package:wiredash/src/metadata/device_info/device_info.dart';

void main() {
  group('Serialize feedback item', () {
    test('toFeedbackBody()', () {
      final oldOnErrorHandler = FlutterError.onError;
      late FlutterErrorDetails caught;
      FlutterError.onError = (FlutterErrorDetails details) {
        caught = details;
      };
      addTearDown(() {
        FlutterError.onError = oldOnErrorHandler;
      });

      final body = PersistedFeedbackItem(
        appInfo: AppInfo(
          appLocale: 'de_DE',
        ),
        buildInfo: BuildInfo(
          compilationMode: CompilationMode.debug,
        ),
        deviceId: '8F821AB6-B3A7-41BA-882E-32D8367243C1',
        deviceInfo: FlutterDeviceInfo(
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
        userId: 'Testy McTestFace',
        sdkVersion: 1,
        customMetaData: {
          'customText': 'text',
          'nestedObject': {'frodo': 'ring', 'sam': 'lembas'},
          'ignoreNull': null, // ignores
          'function': () => null, // reports but doesn't crash
        },
        attachments: [
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.uploaded(
              AttachmentId('screenshot_123'),
            ),
            deviceInfo: FlutterDeviceInfo(
              platformLocale: 'en_US',
              platformSupportedLocales: ['en_US', 'de_DE'],
              padding:
                  WiredashWindowPadding(left: 0, top: 66, right: 0, bottom: 0),
              physicalSize: Size(1080, 2088),
              physicalGeometry: Rect.zero,
              pixelRatio: 2.75,
              platformOS: 'android',
              platformOSVersion: 'RSR1.201013.001',
              platformVersion:
                  '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on'
                  ' "android_ia32"',
              textScaleFactor: 1,
              viewInsets:
                  WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 685),
              platformBrightness: Brightness.dark,
              gestureInsets:
                  WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
            ),
          ),
          PersistedAttachment.screenshot(
            file: FileDataEventuallyOnDisk.uploaded(
              AttachmentId('screenshot_124'),
            ),
            deviceInfo: FlutterDeviceInfo(
              platformLocale: 'de_DE',
              platformSupportedLocales: ['en_US', 'de_DE'],
              padding: WiredashWindowPadding(
                left: 0,
                top: 66,
                right: 0,
                bottom: 360,
              ),
              physicalSize: Size(1080, 2088),
              physicalGeometry: Rect.zero,
              pixelRatio: 2.75,
              platformOS: 'android',
              platformOSVersion: 'RSR1.201013.001',
              platformVersion:
                  '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on'
                  ' "android_ia32"',
              textScaleFactor: 1,
              viewInsets:
                  WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 685),
              platformBrightness: Brightness.dark,
              gestureInsets:
                  WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
            ),
          ),
        ],
      ).toFeedbackBody();

      expect(
        body,
        {
          'appLocale': 'de_DE',
          'compilationMode': 'debug',
          'customMetaData': {
            'customText': 'text',
            'nestedObject': {'frodo': 'ring', 'sam': 'lembas'},
          },
          'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
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
          'attachments': [
            {
              'id': 'screenshot_123',
            },
            {
              'id': 'screenshot_124',
            }
          ],
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
      final body = const PersistedFeedbackItem(
        appInfo: AppInfo(
          appLocale: 'de_DE',
        ),
        buildInfo: BuildInfo(
          compilationMode: CompilationMode.release,
        ),
        deviceId: '8F821AB6-B3A7-41BA-882E-32D8367243C1',
        deviceInfo: FlutterDeviceInfo(
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
        userId: 'Testy McTestFace',
        sdkVersion: 1,
        attachments: [],
      ).toFeedbackBody();

      expect(
        body,
        {
          'appLocale': 'de_DE',
          'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
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
}
