import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/_feedback.dart';

import 'util/robot.dart';
import 'util/wiredash_tester.dart';

void main() {
  group('Offline Feedback', () {
    testWidgets('v2 feedback upload', (tester) async {
      final robot = WiredashTestRobot(tester);
      robot.setupMocks();

      // insert feedback in v2 format with attachment
      final tempDir = Directory.systemTemp.createTempSync();
      File('${tempDir.path}/image.png').writeAsStringSync('test img content');
      final json = fullJsonV2;
      // ignore: avoid_dynamic_calls
      json['feedbackItem']['attachments'][0]['path'] =
          '${tempDir.path}/image.png';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'io.wiredash.pending_feedback_items',
        [jsonEncode(json)],
      );

      await robot.launchApp(useDirectFeedbackSubmitter: false);

      AttachmentId? uploadedAttachment;
      robot.mockServices.mockApi.uploadAttachmentInvocations.interceptor =
          (call) async {
        final name = call.namedArguments[#filename] as String;
        return uploadedAttachment = AttachmentId(name);
      };

      // wait for the UploadPendingFeedbackJob to start
      await tester.pumpAndSettle(const Duration(seconds: 5));
      // every disk io call needs to be pumped
      for (var i = 0; i < 10; i++) {
        await tester.pumpHardAndSettle();
      }

      final latestFeedbackCall =
          robot.mockServices.mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestFeedbackCall[0] as FeedbackItem?;
      expect(submittedFeedback!.message, 'Pending Feedback Item');
      expect(uploadedAttachment, isNotNull);
      expect(
        submittedFeedback.attachments![0].file.attachmentId,
        uploadedAttachment,
      );
    });
  });
}

Map get fullJsonV2 => {
      'id': 'abc123',
      'version': 2,
      'feedbackItem': {
        'appInfo': {
          'appLocale': 'de_DE',
        },
        'attachments': [
          {
            'path': 'ATTACHMENT_PATH',
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
        'message': 'Pending Feedback Item',
        'labels': ['bug', 'lbl-1234'],
        'userId': 'Testy McTestFace',
        'sdkVersion': 174,
      },
    };
