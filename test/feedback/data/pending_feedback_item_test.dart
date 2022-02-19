// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'dart:ui';

import 'package:test/test.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item.dart';
import 'package:wiredash/src/feedback/data/persisted_feedback_item.dart';

void main() {
  final _full = PendingFeedbackItem(
    id: 'abc123',
    feedbackItem: PersistedFeedbackItem(
      appInfo: AppInfo(
        appLocale: 'de_DE',
      ),
      attachments: [
        PersistedAttachment.screenshot(
          file: FileDataEventuallyOnDisk.file(File('path/to/file.png')),
          deviceInfo: DeviceInfo(
            pixelRatio: 2.75,
            platformOS: 'android',
            platformOSVersion: 'RSR1.201013.001',
            platformVersion:
                '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on '
                '"android_ia32"',
            textScaleFactor: 1,
            platformLocale: 'en_US',
            platformSupportedLocales: ['en_US', 'de_DE'],
            platformBrightness: Brightness.dark,
            gestureInsets:
                WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
            padding:
                WiredashWindowPadding(left: 0, top: 66, right: 0, bottom: 0),
            viewInsets:
                WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 685),
            physicalGeometry: Rect.zero,
            physicalSize: Size(1080, 2088),
          ),
        )
      ],
      buildInfo: BuildInfo(
        buildVersion: '1.2.3',
        buildNumber: '543',
        buildCommit: 'abcdef12',
        compilationMode: CompilationMode.profile,
      ),
      customMetaData: {
        'customText': 'text',
        'nestedObject': {'frodo': 'ring', 'sam': 'lembas'},
      },
      deviceId: '8F821AB6-B3A7-41BA-882E-32D8367243C1',
      deviceInfo: DeviceInfo(
        pixelRatio: 2.75,
        platformOS: 'android',
        platformOSVersion: 'RSR1.201013.001',
        platformVersion: '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on '
            '"android_ia32"',
        textScaleFactor: 1,
        platformLocale: 'en_US',
        platformSupportedLocales: ['en_US', 'de_DE'],
        platformBrightness: Brightness.dark,
        gestureInsets:
            WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
        padding: WiredashWindowPadding(left: 0, top: 66, right: 0, bottom: 0),
        viewInsets:
            WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 685),
        physicalGeometry: Rect.zero,
        physicalSize: Size(1080, 2088),
      ),
      email: 'email@example.com',
      message: 'Hello world!',
      labels: ['bug', 'lbl-1234'],
      userId: 'Testy McTestFace',
      sdkVersion: 1,
    ),
  );

  const _minimal = PendingFeedbackItem(
    id: 'abc123',
    feedbackItem: PersistedFeedbackItem(
      appInfo: AppInfo(
        appLocale: 'en_US',
      ),
      attachments: [],
      buildInfo: BuildInfo(compilationMode: CompilationMode.profile),
      deviceId: '1234',
      deviceInfo: DeviceInfo(
        pixelRatio: 1.0,
        textScaleFactor: 1.0,
        platformLocale: 'en_US',
        platformSupportedLocales: ['en_US', 'de_DE'],
        platformBrightness: Brightness.dark,
        gestureInsets:
            WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
        padding: WiredashWindowPadding(left: 0, top: 66, right: 0, bottom: 0),
        viewInsets:
            WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 685),
        physicalGeometry: Rect.zero,
        physicalSize: Size(1280, 720),
      ),
      message: 'Hello world!',
      sdkVersion: 12,
    ),
  );

  group('PendingFeedbackItem', () {
    test('Full fromJson()', () {
      expect(
        PendingFeedbackItemParserV2.fromJson({
          'id': 'abc123',
          'feedbackItem': {
            'appInfo': {
              'appLocale': 'de_DE',
            },
            'attachments': [
              {
                'path': 'path/to/file.png',
                'deviceInfo': {
                  'padding': [0, 66, 0, 0],
                  'physicalSize': [1080, 2088],
                  'appIsDebug': true,
                  'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
                  'pixelRatio': 2.75,
                  'platformOS': 'android',
                  'platformOSBuild': 'RSR1.201013.001',
                  'platformVersion':
                      '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on '
                          '"android_ia32"',
                  'textScaleFactor': 1,
                  'platformLocale': 'en_US',
                  'platformSupportedLocales': ['en_US', 'de_DE'],
                  'platformBrightness': 'dark',
                  'gestureInsets': [0, 0, 0, 0],
                  'physicalGeometry': [0.0, 0.0, 0.0, 0.0],
                  'viewInsets': [0, 0, 0, 685],
                },
              },
            ],
            'buildInfo': {
              'buildVersion': '1.2.3',
              'buildNumber': '543',
              'buildCommit': 'abcdef12',
              'compilationMode': 'profile',
            },
            'customMetaData': {
              'customText': '"text"',
              'nestedObject': '{"frodo":"ring","sam":"lembas"}',
            },
            'deviceInfo': {
              'padding': [0, 66, 0, 0],
              'physicalSize': [1080, 2088],
              'appIsDebug': true,
              'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
              'pixelRatio': 2.75,
              'platformOS': 'android',
              'platformOSBuild': 'RSR1.201013.001',
              'platformVersion':
                  '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on '
                      '"android_ia32"',
              'textScaleFactor': 1,
              'platformLocale': 'en_US',
              'platformSupportedLocales': ['en_US', 'de_DE'],
              'platformBrightness': 'dark',
              'gestureInsets': [0, 0, 0, 0],
              'physicalGeometry': [0.0, 0.0, 0.0, 0.0],
              'viewInsets': [0, 0, 0, 685],
            },
            'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
            'email': 'email@example.com',
            'message': 'Hello world!',
            'labels': ['bug', 'lbl-1234'],
            'userId': 'Testy McTestFace',
            'sdkVersion': 1
          },
        }),
        _full,
      );
    });

    test('Minimal fromJson()', () {
      expect(
        PendingFeedbackItemParserV2.fromJson({
          'id': 'abc123',
          'feedbackItem': {
            'deviceId': '1234',
            'message': 'Hello world!',
            'sdkVersion': 12,
            'appInfo': {
              'appLocale': 'en_US',
            },
            'buildInfo': {
              'compilationMode': 'profile',
            },
            'deviceInfo': {
              'deviceId': '1234',
              'appIsDebug': false,
              'pixelRatio': 1,
              'textScaleFactor': 1.0,
              'platformLocale': 'en_US',
              'platformSupportedLocales': ['en_US', 'de_DE'],
              'platformBrightness': 'dark',
              'physicalSize': [1280, 720],
              'physicalGeometry': [0.0, 0.0, 0.0, 0.0],
              'gestureInsets': [0.0, 0.0, 0.0, 0.0],
              'viewInsets': [0.0, 0.0, 0.0, 685.0],
              'padding': [0.0, 66, 0, 0.0],
            }
          },
        }),
        _minimal,
      );
    });

    test('Full toJson()', () {
      expect(
        _full.toJson(),
        {
          'id': 'abc123',
          'screenshotPath': 'path/to/file.png',
          'version': 1,
          'feedbackItem': {
            'appInfo': {
              'appLocale': 'de_DE',
            },
            'buildInfo': {
              'buildVersion': '1.2.3',
              'buildNumber': '543',
              'buildCommit': 'abcdef12',
              'compilationMode': 'profile',
            },
            'customMetaData': {
              'customText': '"text"',
              'nestedObject': '{"frodo":"ring","sam":"lembas"}',
            },
            'deviceInfo': {
              'padding': [0, 66, 0, 0],
              'physicalSize': [1080, 2088],
              'viewInsets': [0, 0, 0, 685],
              'platformLocale': 'en_US',
              'platformSupportedLocales': ['en_US', 'de_DE'],
              'platformBrightness': 'dark',
              'gestureInsets': [0, 0, 0, 0],
              'pixelRatio': 2.75,
              'platformOS': 'android',
              'platformOSBuild': 'RSR1.201013.001',
              'platformVersion':
                  '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on '
                      '"android_ia32"',
              'textScaleFactor': 1,
              'physicalGeometry': [0.0, 0.0, 0.0, 0.0],
            },
            'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
            'email': 'email@example.com',
            'message': 'Hello world!',
            'labels': ['bug', 'lbl-1234'],
            'userId': 'Testy McTestFace',
            'sdkVersion': 1,
          },
        },
      );
    });

    test('Minimal toJson()', () {
      expect(_minimal.toJson(), {
        'id': 'abc123',
        'version': 1,
        'feedbackItem': {
          'deviceId': '1234',
          'message': 'Hello world!',
          'sdkVersion': 12,
          'appInfo': {
            'appLocale': 'en_US',
          },
          'buildInfo': {
            'compilationMode': 'profile',
          },
          'deviceInfo': {
            'pixelRatio': 1,
            'textScaleFactor': 1.0,
            'platformLocale': 'en_US',
            'platformSupportedLocales': ['en_US', 'de_DE'],
            'platformBrightness': 'dark',
            'physicalGeometry': [0.0, 0.0, 0.0, 0.0],
            'gestureInsets': [0.0, 0.0, 0.0, 0.0],
            'viewInsets': [0.0, 0.0, 0.0, 685],
            'padding': [0.0, 66, 0, 0.0],
            'physicalSize': [1280.0, 720.0],
          }
        },
      });
    });
  });

  test('back and forth - minimal', () {
    final copy = PendingFeedbackItemParserV2.fromJson(_minimal.toJson());
    expect(copy, _minimal);
    expect(copy.hashCode, _minimal.hashCode);
  });

  test('back and forth - full', () {
    final copy = PendingFeedbackItemParserV2.fromJson(_full.toJson());
    expect(copy, _full);
    expect(copy.hashCode, _full.hashCode);
  });
}
