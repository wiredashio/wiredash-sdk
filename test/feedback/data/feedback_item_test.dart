import 'package:test/test.dart';
import 'package:wiredash/src/common/device_info/device_info.dart';
import 'package:wiredash/src/feedback/data/feedback_item.dart';

void main() {
  group('FeedbackItem', () {
    test('fromJson()', () {
      expect(
        FeedbackItem.fromJson({
          'deviceInfo': {
            'padding': [0, 66, 0, 0],
            'physicalSize': [1080, 2088],
            'viewInsets': [0, 0, 0, 685],
            'appIsDebug': true,
            'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
            'locale': 'en_US',
            'pixelRatio': 2.75,
            'platformOS': 'android',
            'platformOSVersion': 'RSR1.201013.001',
            'dartVersion':
                '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
            'textScaleFactor': 1
          },
          'email': 'email@example.com',
          'message': 'Hello world!',
          'type': 'bug',
          'user': 'Testy McTestFace',
        }),
        const FeedbackItem(
          deviceInfo: DeviceInfo(
            padding: [0, 66, 0, 0],
            physicalSize: [1080, 2088],
            viewInsets: [0, 0, 0, 685],
            appIsDebug: true,
            deviceId: "8F821AB6-B3A7-41BA-882E-32D8367243C1",
            locale: "en_US",
            pixelRatio: 2.75,
            platformOS: "android",
            platformOSVersion: "RSR1.201013.001",
            dartVersion:
                '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
            textScaleFactor: 1,
          ),
          email: 'email@example.com',
          message: 'Hello world!',
          type: 'bug',
          user: 'Testy McTestFace',
        ),
      );
    });

    test('toJson()', () {
      expect(
        const FeedbackItem(
          deviceInfo: DeviceInfo(
            padding: [0, 66, 0, 0],
            physicalSize: [1080, 2088],
            viewInsets: [0, 0, 0, 685],
            appIsDebug: true,
            deviceId: "8F821AB6-B3A7-41BA-882E-32D8367243C1",
            locale: "en_US",
            pixelRatio: 2.75,
            platformOS: "android",
            platformOSVersion: "RSR1.201013.001",
            dartVersion:
                '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
            textScaleFactor: 1,
          ),
          email: 'email@example.com',
          message: 'Hello world!',
          type: 'bug',
          user: 'Testy McTestFace',
        ).toJson(),
        {
          'deviceInfo': {
            'padding': [0.0, 66.0, 0.0, 0.0],
            'physicalSize': [1080.0, 2088.0],
            'viewInsets': [0.0, 0.0, 0.0, 685.0],
            'appIsDebug': true,
            'deviceId': '8F821AB6-B3A7-41BA-882E-32D8367243C1',
            'locale': 'en_US',
            'pixelRatio': 2.75,
            'platformOS': 'android',
            'platformOSVersion': 'RSR1.201013.001',
            'dartVersion':
                '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
            'textScaleFactor': 1.0
          },
          'email': 'email@example.com',
          'message': 'Hello world!',
          'type': 'bug',
          'user': 'Testy McTestFace',
        },
      );
    });

    test('toMultipartFormFields()', () {
      expect(
        const FeedbackItem(
          deviceInfo: DeviceInfo(
            appIsDebug: true,
            deviceId: "8F821AB6-B3A7-41BA-882E-32D8367243C1",
            locale: "en_US",
            padding: [0, 66, 0, 0],
            physicalSize: [1080, 2088],
            pixelRatio: 2.75,
            platformOS: "android",
            platformOSVersion: "RSR1.201013.001",
            dartVersion:
                '2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on "android_ia32"',
            textScaleFactor: 1,
            viewInsets: [0, 0, 0, 685],
          ),
          email: 'email@example.com',
          message: 'Hello world!',
          type: 'bug',
          user: 'Testy McTestFace',
        ).toMultipartFormFields(),
        {
          'deviceInfo':
              '{"appIsDebug":true,"deviceId":"8F821AB6-B3A7-41BA-882E-32D8367243C1","locale":"en_US","padding":[0.0,66.0,0.0,0.0],"physicalSize":[1080.0,2088.0],"pixelRatio":2.75,"platformOS":"android","platformOSVersion":"RSR1.201013.001","dartVersion":"2.10.2 (stable) (Tue Oct 13 15:50:27 2020 +0200) on \\"android_ia32\\"","textScaleFactor":1.0,"viewInsets":[0.0,0.0,0.0,685.0]}',
          'email': 'email@example.com',
          'message': 'Hello world!',
          'type': 'bug',
          'user': 'Testy McTestFace',
        },
      );
    });
  });
}
