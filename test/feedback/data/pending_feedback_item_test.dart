// ignore_for_file: prefer_const_constructors, avoid_redundant_argument_values

import 'dart:convert';
import 'dart:ui';

import 'package:test/test.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/metadata/build_info/build_info.dart';

void main() {
  final minimalFeedbackV2 = PendingFeedbackItem(
    id: 'abc123',
    feedbackItem: FeedbackItem(
      attachments: [],
      message: 'Hello world!',
      metadata: AllMetaData(
        appLocale: 'en_US',
        windowPixelRatio: 1.0,
        installId: '1234',
        sdkVersion: 174,
        compilationMode: CompilationMode.profile,
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
        windowSize: Size(1280, 720),
      ),
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
      attachments: [
        PersistedAttachment.screenshot(
          file: FileDataEventuallyOnDisk.file('path/to/file.png'),
        ),
      ],
      message: 'Hello world!',
      labels: ['bug', 'lbl-1234'],
      metadata: AllMetaData(
        buildVersion: '1.2.3',
        buildNumber: '543',
        buildCommit: 'abcdef12',
        appLocale: 'de_DE',
        windowPixelRatio: 2.75,
        installId: '8F821AB6-B3A7-41BA-882E-32D8367243C1',
        sdkVersion: 174,
        compilationMode: CompilationMode.profile,
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
        custom: {
          'customText': 'text',
          'nestedObject': {'frodo': 'ring', 'sam': 'lembas'},
        },
        platformOS: 'android',
        platformOSVersion: 'RSR1.201013.001',
        platformDartVersion:
            '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on '
            '"android_ia32"',
        userId: 'Testy McTestFace',
      ),
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
      attachments: [
        PersistedAttachment.screenshot(
          file: FileDataEventuallyOnDisk.file('path/to/file.png'),
        ),
      ],
      message: 'Hello world!',
      labels: ['bug', 'lbl-1234'],
      metadata: AllMetaData(
        buildVersion: '1.2.3',
        buildNumber: '543',
        buildCommit: 'abcdef12',
        appLocale: 'en_US',
        windowPixelRatio: 2.75,
        installId: '8F821AB6-B3A7-41BA-882E-32D8367243C1',
        sdkVersion: 174,
        compilationMode: CompilationMode.profile,
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
        appName: 'MyApp',
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
    ),
  );

  final fullJsonV3 = {
    "feedbackItem": {
      "attachments": [
        {"path": "path/to/file.png"},
      ],
      "labels": ["bug", "lbl-1234"],
      "message": "Hello world!",
      "metadata": {
        "appLocale": "en_US",
        "appName": "MyApp",
        "buildCommit": "abcdef12",
        "buildNumber": "543",
        "buildVersion": "1.2.3",
        "bundleId": "com.example.app",
        "compilationMode": "profile",
        "custom": {
          "customText": "text",
          "nestedObject": {"frodo": "ring", "sam": "lembas"},
        },
        "deviceModel": "Google Pixel 8",
        "installId": "8F821AB6-B3A7-41BA-882E-32D8367243C1",
        "physicalGeometry": [0.0, 0.0, 0.0, 0.0],
        "platformBrightness": "dark",
        "platformDartVersion":
            '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
        "platformGestureInsets": [0.0, 0.0, 0.0, 0.0],
        "platformLocale": "en_US",
        "platformOS": "android",
        "platformOSVersion": "RSR1.201013.001",
        "platformSupportedLocales": ["en_US", "de_DE"],
        "sdkVersion": 174,
        "userEmail": "email@example.com",
        "userId": "Testy McTestFace",
        "windowInsets": [0.0, 0.0, 0.0, 685.0],
        "windowPadding": [0.0, 66.0, 0.0, 0.0],
        "windowPixelRatio": 2.75,
        "windowSize": [1280.0, 720.0],
        "windowTextScaleFactor": 1.0,
      },
    },
    "id": "abc123",
    "version": 3,
  };

  final minimalFeedbackV3 = PendingFeedbackItem(
    id: 'abc123',
    feedbackItem: FeedbackItem(
      message: 'Hello world!',
      metadata: AllMetaData(
        windowPixelRatio: 2.75,
        installId: '8F821AB6-B3A7-41BA-882E-32D8367243C1',
        sdkVersion: 174,
        compilationMode: CompilationMode.profile,
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
        windowSize: Size(1280, 720),
      ),
    ),
  );
  final minimalJsonV3 = {
    "feedbackItem": {
      "message": "Hello world!",
      "metadata": {
        "compilationMode": "profile",
        "installId": "8F821AB6-B3A7-41BA-882E-32D8367243C1",
        "physicalGeometry": [0.0, 0.0, 0.0, 0.0],
        "platformBrightness": "dark",
        "platformGestureInsets": [0.0, 0.0, 0.0, 0.0],
        "platformLocale": "en_US",
        "platformSupportedLocales": ["en_US", "de_DE"],
        "sdkVersion": 174,
        "windowInsets": [0.0, 0.0, 0.0, 685.0],
        "windowPadding": [0.0, 66.0, 0.0, 0.0],
        "windowPixelRatio": 2.75,
        "windowSize": [1280.0, 720.0],
        "windowTextScaleFactor": 1.0,
      },
    },
    "id": "abc123",
    "version": 3,
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
    final json = jsonEncode(minimalFeedbackV3.toJson());
    final parsed = deserializePendingFeedbackItem(json);
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
