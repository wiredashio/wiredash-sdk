import 'package:test/test.dart';
import 'package:wiredash/src/common/device_info/device_info.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item.dart';

void main() {
  group('DeviceInfo', () {
    test('fromJson() with all fields', () {
      expect(
        DeviceInfoParserV1.fromJson({
          'padding': [0, 66, 0, 0],
          'physicalSize': [1080, 2088],
          'viewInsets': [0, 0, 0, 685],
          'appIsDebug': true,
          'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
          'locale': 'en_US',
          'supportedLocales': ['en_US', 'de_DE'],
          'platformBrightness': 'dark',
          'gestureInsets': [0, 0, 0, 0],
          'pixelRatio': 2.75,
          'platformOS': 'android',
          'platformOSBuild': 'RSR1.201013.001',
          'platformVersion':
              '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
          'userAgent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.67 Safari/537.36',
          'textScaleFactor': 1,
          'appVersion': '1.2.0',
          'buildCommit': '763aff2',
          'buildNumber': '42',
        }),
        const DeviceInfo(
          padding: [0, 66, 0, 0],
          physicalSize: [1080, 2088],
          viewInsets: [0, 0, 0, 685],
          appIsDebug: true,
          deviceId: "8F821AB6-B3A7-41BA-882E-32D8367243C1",
          platformLocale: "en_US",
          platformSupportedLocales: ['en_US', 'de_DE'],
          pixelRatio: 2.75,
          platformOS: "android",
          platformOSVersion: "RSR1.201013.001",
          userAgent:
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.67 Safari/537.36',
          platformVersion:
              '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
          textScaleFactor: 1,
          platformBrightness: Brightness.dark,
          gestureInsets: [0, 0, 0, 0],
          appVersion: '1.2.0',
          buildCommit: '763aff2',
          buildNumber: '42',
        ),
      );
    });

    test('full: toJson -> fromJson - still equal', () {
      const fullInfo = DeviceInfo(
        padding: [0, 66, 0, 0],
        physicalSize: [1080, 2088],
        viewInsets: [0, 0, 0, 685],
        appIsDebug: true,
        deviceId: "8F821AB6-B3A7-41BA-882E-32D8367243C1",
        platformLocale: "en_US",
        platformSupportedLocales: ['en_US', 'de_DE'],
        pixelRatio: 2.75,
        platformOS: "android",
        platformOSVersion: "RSR1.201013.001",
        userAgent:
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.67 Safari/537.36',
        platformVersion:
            '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
        textScaleFactor: 1,
        platformBrightness: Brightness.dark,
        gestureInsets: [0, 0, 0, 0],
        appVersion: '1.2.0',
        buildCommit: '763aff2',
        buildNumber: '42',
      );
      final map = fullInfo.toJson();
      final copy = DeviceInfoParserV1.fromJson(map);
      expect(copy, fullInfo);
    });

    test('empty: toJson -> fromJson - still equal', () {
      const empty = DeviceInfo(
        deviceId: '1234',
        appIsDebug: false,
        pixelRatio: 1.0,
        platformLocale: "en_US",
        platformSupportedLocales: ['en_US', 'de_DE'],
        textScaleFactor: 1.0,
        platformBrightness: Brightness.dark,
        gestureInsets: [0, 0, 0, 0],
      );
      final map = empty.toJson();
      final copy = DeviceInfoParserV1.fromJson(map);
      expect(copy, empty);
    });

    test('fromJson() with some missing data', () {
      expect(
        DeviceInfoParserV1.fromJson({
          'padding': [0, 66, 0, 0],
          'physicalSize': [1080, 2088],
          'viewInsets': [0, 0, 0, 685],
          'appIsDebug': true,
          'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
          'locale': 'en_US',
          'supportedLocales': ['en_US', 'de_DE'],
          'platformBrightness': 'light',
          'gestureInsets': [0, 0, 0, 0],
          'pixelRatio': 2.75,
          'platformOS': null,
          'platformOSBuild': null,
          'userAgent': null,
          'textScaleFactor': 1
        }),
        const DeviceInfo(
          padding: [0, 66, 0, 0],
          physicalSize: [1080, 2088],
          viewInsets: [0, 0, 0, 685],
          platformLocale: "en_US",
          platformSupportedLocales: ['en_US', 'de_DE'],
          appIsDebug: true,
          deviceId: "8F821AB6-B3A7-41BA-882E-32D8367243C1",
          pixelRatio: 2.75,
          textScaleFactor: 1,
          platformBrightness: Brightness.light,
          gestureInsets: [0, 0, 0, 0],
        ),
      );
    });

    test('toJson() with all fields', () {
      expect(
        const DeviceInfo(
          appIsDebug: true,
          deviceId: "8F821AB6-B3A7-41BA-882E-32D8367243C1",
          platformLocale: "en_US",
          platformSupportedLocales: ['en_US', 'de_DE'],
          padding: [0, 66, 0, 0],
          physicalSize: [1080, 2088],
          pixelRatio: 2.75,
          platformOS: "android",
          platformOSVersion: "RSR1.201013.001",
          platformVersion:
              '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
          textScaleFactor: 1,
          viewInsets: [0, 0, 0, 685],
          platformBrightness: Brightness.dark,
          gestureInsets: [0, 0, 0, 0],
        ).toJson(),
        {
          'appIsDebug': true,
          'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
          'gestureInsets': [0.0, 0.0, 0.0, 0.0],
          'locale': 'en_US',
          'padding': [0.0, 66.0, 0.0, 0.0],
          'physicalSize': [1080.0, 2088.0],
          'pixelRatio': 2.75,
          'platformBrightness': 'dark',
          'platformOS': 'android',
          'platformOSBuild': 'RSR1.201013.001',
          'platformVersion':
              '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
          'supportedLocales': ['en_US', 'de_DE'],
          'textScaleFactor': 1.0,
          'viewInsets': [0.0, 0.0, 0.0, 685.0]
        },
      );
    });

    test('toJson() with some missing data strips null elements', () {
      expect(
        const DeviceInfo(
          appIsDebug: false,
          physicalSize: [1080, 2088],
          platformLocale: "en_US",
          platformSupportedLocales: ['en_US', 'de_DE'],
          viewInsets: [0, 0, 0, 685],
          deviceId: "8F821AB6-B3A7-41BA-882E-32D8367243C1",
          pixelRatio: 2.75,
          textScaleFactor: 1,
          platformBrightness: Brightness.light,
          gestureInsets: [0, 0, 0, 0],
        ).toJson(),
        {
          'appIsDebug': false,
          'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
          'gestureInsets': [0.0, 0.0, 0.0, 0.0],
          'locale': 'en_US',
          'physicalSize': [1080.0, 2088.0],
          'pixelRatio': 2.75,
          'platformBrightness': 'light',
          'supportedLocales': ['en_US', 'de_DE'],
          'textScaleFactor': 1.0,
          'viewInsets': [0.0, 0.0, 0.0, 685.0]
        },
      );
    });
  });
}
