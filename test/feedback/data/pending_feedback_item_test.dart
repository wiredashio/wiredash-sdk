import 'package:test/test.dart';
import 'package:wiredash/src/common/device_info/device_info.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item.dart';
import 'package:wiredash/src/feedback/data/persisted_feedback_item.dart';

void main() {
  const _full = const PendingFeedbackItem(
    id: 'abc123',
    screenshotPath: 'path/to/file.png',
    feedbackItem: PersistedFeedbackItem(
      appInfo: AppInfo(
        appIsDebug: true,
        appLocale: 'de_DE',
      ),
      buildInfo: BuildInfo(
          buildVersion: '1.2.3', buildNumber: '543', buildCommit: 'abcdef12'),
      deviceId: '8F821AB6-B3A7-41BA-882E-32D8367243C1',
      deviceInfo: DeviceInfo(
        padding: [0, 66, 0, 0],
        physicalSize: [1080, 2088],
        viewInsets: [0, 0, 0, 685],
        pixelRatio: 2.75,
        platformOS: "android",
        platformOSVersion: "RSR1.201013.001",
        platformVersion:
            '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
        textScaleFactor: 1,
        platformLocale: "en_US",
        platformSupportedLocales: ['en_US', 'de_DE'],
        platformBrightness: Brightness.dark,
        gestureInsets: [0, 0, 0, 0],
      ),
      email: 'email@example.com',
      message: 'Hello world!',
      type: 'bug',
      user: 'Testy McTestFace',
      sdkVersion: 1,
    ),
  );

  const _minimal = const PendingFeedbackItem(
    id: 'abc123',
    feedbackItem: PersistedFeedbackItem(
      appInfo: AppInfo(
        appIsDebug: false,
        appLocale: 'en_US',
      ),
      buildInfo: BuildInfo(),
      deviceId: '1234',
      deviceInfo: DeviceInfo(
        pixelRatio: 1.0,
        textScaleFactor: 1.0,
        platformLocale: "en_US",
        platformSupportedLocales: ['en_US', 'de_DE'],
        platformBrightness: Brightness.dark,
        physicalSize: [1280, 720],
      ),
      message: 'Hello world!',
      type: 'bug',
      sdkVersion: 12,
    ),
  );

  group('PendingFeedbackItem', () {
    test('Full fromJson()', () {
      expect(
        PendingFeedbackItemParserV1.fromJson({
          'id': 'abc123',
          'screenshotPath': 'path/to/file.png',
          'feedbackItem': {
            'appInfo': {
              'appIsDebug': true,
              'appLocale': 'de_DE',
            },
            'buildInfo': {
              'buildVersion': '1.2.3',
              'buildNumber': '543',
              'buildCommit': 'abcdef12',
            },
            'deviceInfo': {
              'padding': [0, 66, 0, 0],
              'physicalSize': [1080, 2088],
              'viewInsets': [0, 0, 0, 685],
              'appIsDebug': true,
              'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
              'pixelRatio': 2.75,
              'platformOS': 'android',
              'platformOSBuild': 'RSR1.201013.001',
              'platformVersion':
                  '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
              'textScaleFactor': 1,
              'platformLocale': 'en_US',
              'platformSupportedLocales': ['en_US', 'de_DE'],
              'platformBrightness': 'dark',
              'gestureInsets': [0, 0, 0, 0],
            },
            'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
            'email': 'email@example.com',
            'message': 'Hello world!',
            'type': 'bug',
            'user': 'Testy McTestFace',
            'sdkVersion': 1
          },
        }),
        _full,
      );
    });

    test('Minimal fromJson()', () {
      expect(
        PendingFeedbackItemParserV1.fromJson({
          'id': 'abc123',
          'feedbackItem': {
            'deviceId': '1234',
            'message': 'Hello world!',
            'type': 'bug',
            'sdkVersion': 12,
            'appInfo': {
              'appIsDebug': false,
              'appLocale': 'en_US',
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
              'appIsDebug': true,
              'appLocale': 'de_DE',
            },
            'buildInfo': {
              'buildVersion': '1.2.3',
              'buildNumber': '543',
              'buildCommit': 'abcdef12',
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
                  '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
              'textScaleFactor': 1,
            },
            'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
            'email': 'email@example.com',
            'message': 'Hello world!',
            'type': 'bug',
            'user': 'Testy McTestFace',
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
          'type': 'bug',
          'sdkVersion': 12,
          'appInfo': {
            'appIsDebug': false,
            'appLocale': 'en_US',
          },
          'buildInfo': {},
          'deviceInfo': {
            'pixelRatio': 1,
            'textScaleFactor': 1.0,
            'platformLocale': 'en_US',
            'platformSupportedLocales': ['en_US', 'de_DE'],
            'platformBrightness': 'dark',
            'physicalSize': [1280, 720],
          }
        },
      });
    });
  });

  test('back and forth - minimal', () {
    final copy = PendingFeedbackItemParserV1.fromJson(_minimal.toJson());
    expect(copy, _minimal);
    expect(copy.hashCode, _minimal.hashCode);
  });

  test('back and forth - full', () {
    final copy = PendingFeedbackItemParserV1.fromJson(_full.toJson());
    expect(copy, _full);
    expect(copy.hashCode, _full.hashCode);
  });
}
