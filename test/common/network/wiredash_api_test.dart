import 'package:test/test.dart';
import 'package:wiredash/src/common/device_info/device_info.dart';
import 'package:wiredash/src/common/network/wiredash_api.dart';
import 'package:wiredash/src/feedback/data/persisted_feedback_item.dart';

void main() {
  group('Serialize feedback item', () {
    test('toFeedbackBody()', () {
      final body = const PersistedFeedbackItem(
        appInfo: AppInfo(
          appIsDebug: true,
          appLocale: 'de_DE',
        ),
        buildInfo: BuildInfo(),
        deviceId: "8F821AB6-B3A7-41BA-882E-32D8367243C1",
        deviceInfo: DeviceInfo(
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
        ),
        email: 'email@example.com',
        message: 'Hello world!',
        type: 'bug',
        user: 'Testy McTestFace',
        sdkVersion: 1,
      ).toFeedbackBody();

      expect(
        body,
        {
          'appLocale': 'de_DE',
          'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
          'isDebugBuild': true,
          'labels': [],
          'message': 'Hello world!',
          'sdkVersion': 1,
          'windowPixelRatio': 2.75,
          'windowSize': [1080.0, 2088.0],
          'windowTextScaleFactor': 1.0,
          'platformLocale': 'en_US',
          'platformSupportedLocales': ['en_US', 'de_DE'],
          'platformBrightness': 'dark',
          'platformDartVersion':
              '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
          'platformGestureInsets': [0.0, 0.0, 0.0, 0.0],
          'windowInsets': [0.0, 0.0, 0.0, 685.0],
          'windowPadding': [0.0, 66.0, 0.0, 0.0],
          'platformOS': 'android',
          'platformOSVersion': 'RSR1.201013.001',
          'userEmail': 'email@example.com'
        },
      );
    });
  });
}
