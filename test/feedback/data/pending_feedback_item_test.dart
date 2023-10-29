// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:ui';

import 'package:test/test.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/metadata/build_info/app_info.dart';
import 'package:wiredash/src/metadata/build_info/build_info.dart';
import 'package:wiredash/src/metadata/device_info/device_info.dart';
import 'package:wiredash/src/metadata/meta_data_collector.dart';
import 'package:wiredash/src/metadata/user_meta_data.dart';

void main() {
  final minimalFeedbackV2 = PendingFeedbackItem(
    id: 'abc123',
    feedbackItem: FeedbackItem(
      appInfo: AppInfo(),
      attachments: [],
      buildInfo: BuildInfo(compilationMode: CompilationMode.profile),
      deviceId: '1234',
      flutterInfo: FlutterInfo(
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
      sdkVersion: 174,
      deviceInfo: DeviceInfo(),
      sessionMetadata: CustomizableWiredashMetaData()..appLocale = 'en_US',
    ),
  );
  final minimalJsonV2 = {
    'id': 'abc123',
    'feedbackItem': {
      'deviceId': '1234',
      'message': 'Hello world!',
      'sdkVersion': 174,
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
      },
    },
    'version': 2,
  };

  final fullFeedbackV2 = PendingFeedbackItem(
    id: 'abc123',
    feedbackItem: FeedbackItem(
      appInfo: AppInfo(),
      sessionMetadata: CustomizableWiredashMetaData()
        ..appLocale = 'de_DE'
        ..userId = 'Testy McTestFace'
        ..custom = {
          'customText': 'text',
          'nestedObject': {'frodo': 'ring', 'sam': 'lembas'},
        },
      attachments: [
        PersistedAttachment.screenshot(
          file: FileDataEventuallyOnDisk.file('path/to/file.png'),
        ),
      ],
      buildInfo: BuildInfo(
        buildVersion: '1.2.3',
        buildNumber: '543',
        buildCommit: 'abcdef12',
        compilationMode: CompilationMode.profile,
      ),
      deviceId: '8F821AB6-B3A7-41BA-882E-32D8367243C1',
      flutterInfo: FlutterInfo(
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
      sdkVersion: 174,
      deviceInfo: DeviceInfo(),
    ),
  );
  final fullJsonV2 = {
    'id': 'abc123',
    'version': 2,
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
      'sdkVersion': 174,
    },
  };

  final fullFeedbackV3 = PendingFeedbackItem(
    id: 'abc123',
    feedbackItem: FeedbackItem(
      appInfo: AppInfo(
        bundleId: 'com.example.app',
        appName: 'Example App',
        version: '1.9.0',
        buildNumber: '190',
      ),
      sessionMetadata: CustomizableWiredashMetaData()
        ..appLocale = 'de_DE'
        ..userId = 'Testy McTestFace'
        ..userEmail = 'hey@my.app'
        ..buildNumber = '543'
        ..buildCommit = 'abcdef12'
        ..buildVersion = '1.2.3'
        ..custom = {
          'customText': 'text',
          'nestedObject': {'frodo': 'ring', 'sam': 'lembas'},
        },
      attachments: [
        PersistedAttachment.screenshot(
          file: FileDataEventuallyOnDisk.file('path/to/file.png'),
        ),
      ],
      buildInfo: BuildInfo(
        buildVersion: '1.2.3',
        buildNumber: '543',
        buildCommit: 'abcdef12',
        compilationMode: CompilationMode.profile,
      ),
      deviceId: '8F821AB6-B3A7-41BA-882E-32D8367243C1',
      flutterInfo: FlutterInfo(
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
      sdkVersion: 200,
      deviceInfo: DeviceInfo(
        deviceModel: 'Google Pixel 8',
      ),
    ),
  );
  final fullJsonV3 = {
    'id': 'abc123',
    'version': 3,
    'feedbackItem': {
      'appInfo': {
        'bundleId': 'com.example.app',
        'appName': 'Example App',
        'version': '1.9.0',
        'buildNumber': '190',
      },
      'attachments': [
        {
          'path': 'path/to/file.png',
        },
      ],
      'buildInfo': {
        'buildVersion': '1.2.3',
        'buildNumber': '543',
        'buildCommit': 'abcdef12',
        'compilationMode': 'profile',
      },
      'deviceInfo': {
        'deviceModel': 'Google Pixel 8',
      },
      'sessionMetadata': {
        'appLocale': 'de_DE',
        'userId': 'Testy McTestFace',
        'userEmail': 'hey@my.app',
        'buildNumber': '543',
        'buildCommit': 'abcdef12',
        'buildVersion': '1.2.3',
        'custom': {
          'customText': '"text"',
          'nestedObject': '{"frodo":"ring","sam":"lembas"}',
        },
      },
      'flutterInfo': {
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
      'sdkVersion': 200,
    },
  };

  final minimalFeedbackV3 = PendingFeedbackItem(
    id: 'abc123',
    feedbackItem: FeedbackItem(
      appInfo: AppInfo(),
      attachments: [],
      buildInfo: BuildInfo(compilationMode: CompilationMode.profile),
      deviceId: '1234',
      flutterInfo: FlutterInfo(
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
      sdkVersion: 174,
      deviceInfo: DeviceInfo(),
      sessionMetadata: CustomizableWiredashMetaData(),
    ),
  );
  final minimalJsonV3 = {
    'id': 'abc123',
    'feedbackItem': {
      'deviceId': '1234',
      'message': 'Hello world!',
      'sdkVersion': 174,
      'buildInfo': {
        'compilationMode': 'profile',
      },
      'flutterInfo': {
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
      },
    },
    'version': 3,
  };

  group('PendingFeedbackItem', () {
    test('legacy - parse minimal v2', () {
      expect(
        deserializePendingFeedbackItem(jsonEncode(minimalJsonV2)),
        minimalFeedbackV2,
      );
    });

    test('legacy - parse full v2', () {
      expect(
        deserializePendingFeedbackItem(jsonEncode(fullJsonV2)),
        fullFeedbackV2,
      );
    });

    test('parse minimal v3', () {
      expect(
        deserializePendingFeedbackItem(jsonEncode(minimalJsonV3)),
        minimalFeedbackV3,
      );
    });

    test('parse full v3', () {
      expect(
        deserializePendingFeedbackItem(jsonEncode(fullJsonV3)),
        fullFeedbackV3,
      );
    });
  });

  test('back and forth - minimal', () {
    final json = minimalFeedbackV3.toJson();
    final parsed = deserializePendingFeedbackItem(jsonEncode(json));
    expect(parsed, minimalFeedbackV3);
    expect(parsed.hashCode, minimalFeedbackV3.hashCode);
  });

  test('back and forth - full', () {
    final json = jsonEncode(fullFeedbackV3.toJson());
    final parsed = deserializePendingFeedbackItem(json);
    expect(parsed, fullFeedbackV3);
    expect(parsed.hashCode, fullFeedbackV3.hashCode);
  });
}
