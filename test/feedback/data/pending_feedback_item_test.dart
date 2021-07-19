import 'package:test/test.dart';
import 'package:wiredash/src/common/device_info/device_info.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item.dart';
import 'package:wiredash/src/feedback/data/persisted_feedback_item.dart';

void main() {
  group('PendingFeedbackItem', () {
    test('Full fromJson()', () {
      expect(
        PendingFeedbackItemParserV1.fromJson({
          'id': 'abc123',
          'screenshotPath': 'path/to/file.png',
          'feedbackItem': {
            'deviceInfo': {
              'padding': [0, 66, 0, 0],
              'physicalSize': [1080, 2088],
              'viewInsets': [0, 0, 0, 685],
              'appIsDebug': true,
              'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
              'locale': 'en_US',
              'pixelRatio': 2.75,
              'platformOS': 'android',
              'platformOSBuild': 'RSR1.201013.001',
              'platformVersion':
                  '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
              'textScaleFactor': 1
            },
            'email': 'email@example.com',
            'message': 'Hello world!',
            'type': 'bug',
            'user': 'Testy McTestFace',
            'sdkVersion': 1
          },
        }),
        const PendingFeedbackItem(
          id: 'abc123',
          screenshotPath: 'path/to/file.png',
          feedbackItem: PersistedFeedbackItem(
            deviceInfo: DeviceInfo(
              padding: [0, 66, 0, 0],
              physicalSize: [1080, 2088],
              viewInsets: [0, 0, 0, 685],
              appIsDebug: true,
              deviceId: "8F821AB6-B3A7-41BA-882E-32D8367243C1",
              locale: "en_US",
              pixelRatio: 2.75,
              platformOS: "android",
              platformOSBuild: "RSR1.201013.001",
              platformVersion:
                  '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
              textScaleFactor: 1,
            ),
            email: 'email@example.com',
            message: 'Hello world!',
            type: 'bug',
            user: 'Testy McTestFace',
            sdkVersion: 1,
          ),
        ),
      );
    });

    test('Minimal fromJson()', () {
      expect(
        PendingFeedbackItemParserV1.fromJson({
          'id': 'abc123',
          'feedbackItem': {
            'deviceInfo': <String, dynamic>{},
            'message': 'Hello world!',
            'type': 'bug',
            'sdkVersion': 1
          },
        }),
        const PendingFeedbackItem(
          id: 'abc123',
          feedbackItem: PersistedFeedbackItem(
            deviceInfo: DeviceInfo(),
            message: 'Hello world!',
            type: 'bug',
            sdkVersion: 1,
          ),
        ),
      );
    });

    test('toJson()', () {
      expect(
        const PendingFeedbackItem(
          id: 'abc123',
          screenshotPath: 'path/to/file.png',
          feedbackItem: PersistedFeedbackItem(
            deviceInfo: DeviceInfo(
              padding: [0, 66, 0, 0],
              physicalSize: [1080, 2088],
              viewInsets: [0, 0, 0, 685],
              appIsDebug: true,
              deviceId: "8F821AB6-B3A7-41BA-882E-32D8367243C1",
              locale: "en_US",
              pixelRatio: 2.75,
              platformOS: "android",
              platformOSBuild: "RSR1.201013.001",
              platformVersion:
                  '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
              textScaleFactor: 1,
            ),
            email: 'email@example.com',
            message: 'Hello world!',
            type: 'bug',
            user: 'Testy McTestFace',
            sdkVersion: 1,
          ),
        ).toJson(),
        {
          'id': 'abc123',
          'screenshotPath': 'path/to/file.png',
          'version': 1,
          'feedbackItem': {
            'deviceInfo': {
              'padding': [0, 66, 0, 0],
              'physicalSize': [1080, 2088],
              'viewInsets': [0, 0, 0, 685],
              'appIsDebug': true,
              'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
              'locale': 'en_US',
              'pixelRatio': 2.75,
              'platformOS': 'android',
              'platformOSBuild': 'RSR1.201013.001',
              'platformVersion':
                  '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
              'textScaleFactor': 1
            },
            'email': 'email@example.com',
            'message': 'Hello world!',
            'type': 'bug',
            'user': 'Testy McTestFace',
            'sdkVersion': 1,
          },
        },
      );
    });
  });
}
