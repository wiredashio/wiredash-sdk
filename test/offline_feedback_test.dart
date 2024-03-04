import 'dart:convert';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:async/async.dart' show ResultFuture;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/core/sync/sync_engine.dart';

import 'util/robot.dart';
import 'util/wiredash_tester.dart';

void main() {
  testWidgets('Send text only feedback (offline)', (tester) async {
    final robot = await WiredashTestRobot(tester)
        .launchApp(useDirectFeedbackSubmitter: false);
    robot.mockServices.mockApi.sendFeedbackInvocations.interceptor =
        (_) async => throw 'offline';

    await robot.openWiredash();
    await robot.enterFeedbackMessage('test message');
    await robot.goToNextStep();
    await robot.skipScreenshot();
    await robot.skipEmail();
    await robot.submitFeedback();
    await robot.waitUntilWiredashIsClosed();
    // attempt request which fails
    robot.mockServices.mockApi.sendFeedbackInvocations.verifyInvocationCount(1);

    // but the feedback is stored securely offline
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('io.wiredash.pending_feedback_items');
    expect(saved, hasLength(1));
  });

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
      await tester.pumpSmart(const Duration(seconds: 5));

      final future = ResultFuture(
        robot.mockServices.services.syncEngine
            .onEvent(SdkEvent.appStartDelayed),
      );
      await tester.waitUntil(() => future.isComplete, isTrue);

      final latestFeedbackCall =
          robot.mockServices.mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestFeedbackCall[0] as FeedbackItem?;
      expect(submittedFeedback!.message, 'Pending Feedback Item v2');
      expect(uploadedAttachment, isNotNull);
      expect(
        submittedFeedback.attachments![0].file.attachmentId,
        uploadedAttachment,
      );
    });

    testWidgets('v3 feedback upload', (tester) async {
      final robot = WiredashTestRobot(tester);
      robot.setupMocks();

      // insert feedback in v3 format with attachment
      final tempDir = Directory.systemTemp.createTempSync();
      File('${tempDir.path}/image.png').writeAsStringSync('test img content');
      final json = fullJsonV3;
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
      await tester.pumpSmart(const Duration(seconds: 5));

      final future = ResultFuture(
        robot.mockServices.services.syncEngine
            .onEvent(SdkEvent.appStartDelayed),
      );
      await tester.waitUntil(() => future.isComplete, isTrue);

      final latestFeedbackCall =
          robot.mockServices.mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestFeedbackCall[0] as FeedbackItem?;
      expect(submittedFeedback!.message, 'Pending Feedback Item v3');
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
        'message': 'Pending Feedback Item v2',
        'labels': ['bug', 'lbl-1234'],
        'userId': 'Testy McTestFace',
        'sdkVersion': 174,
      },
    };

Map get fullJsonV3 => {
      "feedbackItem": {
        "attachments": [
          {"path": "ATTACHMENT_PATH"},
        ],
        "feedbackId": "0123456789abcdef",
        "labels": ["bug", "lbl-1234"],
        "message": "Pending Feedback Item v3",
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
