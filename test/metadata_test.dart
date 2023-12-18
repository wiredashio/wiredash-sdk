// ignore_for_file: avoid_print, deprecated_member_use_from_same_package

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/feedback/data/feedback_item.dart';
import 'package:wiredash/wiredash.dart';

import 'util/robot.dart';

void main() {
  test('userEmail can be set', () async {
    final WiredashModel model = WiredashModel(createMockServices());
    final controller = WiredashController(model);
    expect(controller.metaData.userEmail, isNull);
    controller.setUserProperties(userEmail: 'dash@flutter.io');
    expect(controller.metaData.userEmail, 'dash@flutter.io');
  });

  test('userEmail can be resetted', () async {
    final WiredashModel model = WiredashModel(createMockServices());
    final controller = WiredashController(model);
    expect(controller.metaData.userEmail, isNull);
    controller.setUserProperties(userEmail: 'dash@flutter.io');
    expect(controller.metaData.userEmail, 'dash@flutter.io');
    controller.setUserProperties(userEmail: null);
    expect(controller.metaData.userEmail, isNull);
  });

  test('deprecated setBuildProperties() is noop', () async {
    final WiredashModel model = WiredashModel(createMockServices());
    final controller = WiredashController(model);
    expect(controller.metaData.buildNumber, isNull);
    controller.setBuildProperties(
      buildNumber: '123',
      buildCommit: 'abc',
      buildVersion: '1.0.0',
    );
    expect(controller.metaData.buildNumber, isNull);
    expect(controller.metaData.buildCommit, isNull);
    expect(controller.metaData.buildVersion, isNull);
  });

  test('custom metadata can not be mutable via metaData getter', () async {
    final WiredashModel model = WiredashModel(createMockServices());
    final controller = WiredashController(model);
    final map = controller.metaData.custom;
    expect(() => map['foo'] = 'bar', throwsA(isA<UnsupportedError>()));
  });

  test('custom metadata can be mutated in modifyMetaData', () async {
    final WiredashModel model = WiredashModel(createMockServices());
    final controller = WiredashController(model);
    final map = controller.metaData.custom;
    controller.modifyMetaData((metaData) => metaData..custom['foo'] = 'bar');
    expect(controller.metaData.custom['foo'], 'bar');
    // getter copy did not change
    expect(map['foo'], isNull);
  });

  testWidgets('set metadata before opening wiredash', (tester) async {
    final robot = WiredashTestRobot(tester);

    CustomizableWiredashMetaData? metadata;
    await robot.launchApp(
      builder: (context) {
        return Scaffold(
          body: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final wiredash = Wiredash.of(context);
                  wiredash.modifyMetaData((metaData) {
                    metadata = metaData.copyWith();
                    return metaData;
                  });
                  wiredash.show();
                },
                child: const Text('Feedback'),
              ),
            ],
          ),
        );
      },
    );
    await robot.openWiredash();

    // can only be set by developers
    expect(metadata!.userId, isNull);
    expect(metadata!.userEmail, isNull);
    expect(metadata!.buildCommit, isNull);
    expect(metadata!.custom.isEmpty, isTrue);

    // deprecated
    expect(metadata!.buildNumber, isNull);
    expect(metadata!.buildVersion, isNull);
    expect(metadata!.buildCommit, isNull);
  });

  testWidgets('reading metadata as first wiredash interaction', (tester) async {
    final robot = WiredashTestRobot(tester);

    CustomizableWiredashMetaData? metadata;
    await robot.launchApp(
      builder: (context) {
        return Scaffold(
          body: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final wiredash = Wiredash.of(context);
                  metadata = wiredash.metaData;
                  wiredash.show();
                },
                child: const Text('Feedback'),
              ),
            ],
          ),
        );
      },
    );
    await robot.openWiredash();

    // all empty
    expect(metadata!.userId, isNull);
    expect(metadata!.userEmail, isNull);
    expect(metadata!.buildCommit, isNull);
    expect(metadata!.buildNumber, isNull);
    expect(metadata!.buildVersion, isNull);
    expect(metadata!.custom.isEmpty, isTrue);
  });

  group('collectMetaData', () {
    testWidgets(
        'Wiredash.collectMetaData has precedence over WiredashFeedbackOptions',
        (tester) async {
      final robot = WiredashTestRobot(tester);
      await robot.launchApp(
        collectMetaData: (metaData) {
          return metaData..userEmail = "primary@mail.com";
        },
        feedbackOptions: WiredashFeedbackOptions(
          collectMetaData: (metaData) {
            return metaData..userEmail = "secondary@mail.com";
          },
        ),
      );
      await robot.submitMinimalFeedback();
      final latestCall =
          robot.mockServices.mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestCall[0] as FeedbackItem?;
      expect(submittedFeedback!.metadata.userEmail, 'primary@mail.com');
    });

    testWidgets('Use WiredashFeedbackOptions.collectMetaData as fallback',
        (tester) async {
      final robot = WiredashTestRobot(tester);
      await robot.launchApp(
        feedbackOptions: WiredashFeedbackOptions(
          collectMetaData: (metaData) {
            return metaData..userEmail = "secondary@mail.com";
          },
        ),
      );
      await robot.submitMinimalFeedback();
      final latestCall =
          robot.mockServices.mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestCall[0] as FeedbackItem?;
      expect(submittedFeedback!.metadata.userEmail, 'secondary@mail.com');
    });

    testWidgets('Wiredash.collectMetaData has precedence over PsOptions',
        (tester) async {
      final robot = WiredashTestRobot(tester);
      await robot.launchApp(
        collectMetaData: (metaData) {
          return metaData..userEmail = "primary@mail.com";
        },
        psOptions: PsOptions(
          collectMetaData: (metaData) {
            return metaData..userEmail = "secondary@mail.com";
          },
        ),
      );
      await robot.openPromoterScore();
      await tester.pump(const Duration(seconds: 1));
      final latestCall = robot.mockServices.mockApi.sendPsInvocations.latest;
      final ps = latestCall[0] as PromoterScoreRequestBody?;
      expect(ps!.metadata.userEmail, 'primary@mail.com');
    });

    testWidgets('Use PsOptions.collectMetaData as fallback', (tester) async {
      final robot = WiredashTestRobot(tester);
      await robot.launchApp(
        psOptions: PsOptions(
          collectMetaData: (metaData) {
            return metaData..userEmail = "secondary@mail.com";
          },
        ),
      );
      await robot.openPromoterScore();
      await tester.pump(const Duration(seconds: 1));
      final latestCall = robot.mockServices.mockApi.sendPsInvocations.latest;
      final ps = latestCall[0] as PromoterScoreRequestBody?;
      expect(ps!.metadata.userEmail, 'secondary@mail.com');
    });

    testWidgets('All user collected metaData is submitted to the server',
        (tester) async {
      final robot = WiredashTestRobot(tester);
      await robot.launchApp(
        collectMetaData: (metaData) {
          return metaData
            ..userEmail = "user@mail.com"
            ..userId = "123"
            ..custom['foo'] = 'bar';
        },
      );
      await robot.submitMinimalFeedback();
      final latestCall =
          robot.mockServices.mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestCall[0] as FeedbackItem?;
      expect(submittedFeedback!.metadata.userEmail, 'user@mail.com');
      expect(submittedFeedback.metadata.userId, '123');
      expect(submittedFeedback.metadata.custom!['foo'], 'bar');
    });
  });
  group('sessionMetaData', () {
    testWidgets('sent along feedback', (tester) async {
      final robot = WiredashTestRobot(tester);
      await robot.launchApp();
      await robot.submitMinimalFeedback();
      final latestCall =
          robot.mockServices.mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestCall[0] as FeedbackItem?;
      expect(submittedFeedback!.metadata.appBrightness, Brightness.light);
      expect(submittedFeedback.metadata.appLocale, 'en-US');
    });

    testWidgets('send along promoter score', (tester) async {
      final robot = WiredashTestRobot(tester);
      await robot.launchApp();
      await robot.openPromoterScore();
      await tester.pump(const Duration(seconds: 1));
      final latestCall = robot.mockServices.mockApi.sendPsInvocations.latest;
      final ps = latestCall[0] as PromoterScoreRequestBody?;
      expect(ps!.metadata.appBrightness, Brightness.light);
      expect(ps.metadata.appLocale, 'en-US');
    });
  });
}
