import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/wiredash.dart';

import '../util/invocation_catcher.dart';
import '../util/robot.dart';

void main() {
  group('issue 393', () {
    testWidgets(
        'metadata should be encapsulated per opened Wiredash Feedback and be merged with collectMetaData',
        (tester) async {
      final robot = WiredashTestRobot(tester);

      MapEntry<String, String> customMetaData = const MapEntry('foo', 'bar');

      await robot.launchApp(
        collectMetaData: (metaData) {
          return metaData
            ..userEmail = "user@mail.com"
            ..userId = "123"
            ..custom['foz'] = 'baz';
        },
        builder: (context) {
          return Scaffold(
            body: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    final wiredash = Wiredash.of(context);
                    wiredash.modifyMetaData((metaData) {
                      return metaData
                        ..custom[customMetaData.key] = customMetaData.value;
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

      await robot.submitMinimalFeedback();
      AssertableInvocation latestCall =
          robot.mockServices.mockApi.sendFeedbackInvocations.latest;
      final firstFeedback = latestCall[0] as FeedbackItem?;
      expect(firstFeedback!.metadata.userEmail, 'user@mail.com');
      expect(firstFeedback.metadata.userId, '123');
      expect(firstFeedback.metadata.custom!['foz'], 'baz');
      expect(firstFeedback.metadata.custom!['foo'], 'bar');

      customMetaData = const MapEntry('bar', 'foo');

      await robot.submitMinimalFeedback();
      latestCall = robot.mockServices.mockApi.sendFeedbackInvocations.latest;
      final secondFeedback = latestCall[0] as FeedbackItem?;
      expect(secondFeedback!.metadata.userEmail, 'user@mail.com');
      expect(secondFeedback.metadata.userId, '123');
      expect(secondFeedback.metadata.custom!['foz'], 'baz');
      expect(secondFeedback.metadata.custom!['bar'], 'foo');
    });

    testWidgets(
        'metadata should be encapsulated per opened Wiredash Feedback and be merged with feedbackOptions.collectMetaData',
        (tester) async {
      final robot = WiredashTestRobot(tester);

      MapEntry<String, String> customMetaData = const MapEntry('foo', 'bar');

      await robot.launchApp(
        feedbackOptions: WiredashFeedbackOptions(
          collectMetaData: (metaData) {
            return metaData
              ..userEmail = "user@mail.com"
              ..userId = "123"
              ..custom['foz'] = 'baz';
          },
        ),
        builder: (context) {
          return Scaffold(
            body: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    final wiredash = Wiredash.of(context);
                    wiredash.modifyMetaData((metaData) {
                      return metaData
                        ..custom[customMetaData.key] = customMetaData.value;
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

      await robot.submitMinimalFeedback();
      AssertableInvocation latestCall =
          robot.mockServices.mockApi.sendFeedbackInvocations.latest;
      final firstFeedback = latestCall[0] as FeedbackItem?;
      expect(firstFeedback!.metadata.userEmail, 'user@mail.com');
      expect(firstFeedback.metadata.userId, '123');
      expect(firstFeedback.metadata.custom!['foz'], 'baz');
      expect(firstFeedback.metadata.custom!['foo'], 'bar');

      customMetaData = const MapEntry('bar', 'foo');

      await robot.submitMinimalFeedback();
      latestCall = robot.mockServices.mockApi.sendFeedbackInvocations.latest;
      final secondFeedback = latestCall[0] as FeedbackItem?;
      expect(secondFeedback!.metadata.custom, hasLength(2));
      expect(secondFeedback.metadata.userEmail, 'user@mail.com');
      expect(secondFeedback.metadata.userId, '123');
      expect(secondFeedback.metadata.custom!['foz'], 'baz');
      expect(secondFeedback.metadata.custom!['bar'], 'foo');
    });

    testWidgets(
        'metadata should be encapsulated per opened Wiredash Feedback and be merged with feedbackOptions.collectMetaData',
        (tester) async {
      final robot = WiredashTestRobot(tester);

      MapEntry<String, String> customMetaData = const MapEntry('foo', 'bar');

      await robot.launchApp(
        feedbackOptions: WiredashFeedbackOptions(
          collectMetaData: (metaData) {
            return metaData
              ..userEmail = "user@mail.com"
              ..userId = "123"
              ..custom['foz'] = 'baz';
          },
        ),
        builder: (context) {
          return Scaffold(
            body: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    final wiredash = Wiredash.of(context);
                    wiredash.modifyMetaData((metaData) {
                      return metaData
                        ..custom[customMetaData.key] = customMetaData.value;
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

      await robot.submitMinimalFeedback();
      AssertableInvocation latestCall =
          robot.mockServices.mockApi.sendFeedbackInvocations.latest;
      final firstFeedback = latestCall[0] as FeedbackItem?;
      expect(firstFeedback!.metadata.userEmail, 'user@mail.com');
      expect(firstFeedback.metadata.userId, '123');
      expect(firstFeedback.metadata.custom!['foz'], 'baz');
      expect(firstFeedback.metadata.custom!['foo'], 'bar');

      customMetaData = const MapEntry('bar', 'foo');

      await robot.submitMinimalFeedback();
      latestCall = robot.mockServices.mockApi.sendFeedbackInvocations.latest;
      final secondFeedback = latestCall[0] as FeedbackItem?;
      expect(secondFeedback!.metadata.custom, hasLength(2));
      expect(secondFeedback.metadata.userEmail, 'user@mail.com');
      expect(secondFeedback.metadata.userId, '123');
      expect(secondFeedback.metadata.custom!['foz'], 'baz');
      expect(secondFeedback.metadata.custom!['bar'], 'foo');
    });

    testWidgets(
        'metadata should be encapsulated per opened Wiredash Feedback and be merged with setUserData',
        (tester) async {
      final robot = WiredashTestRobot(tester);

      MapEntry<String, String> customMetaData = const MapEntry('foo', 'bar');

      await robot.launchApp(
        builder: (context) {
          return Scaffold(
            body: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    final wiredash = Wiredash.of(context);
                    wiredash.modifyMetaData((metaData) {
                      return metaData
                        ..custom[customMetaData.key] = customMetaData.value;
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

      robot.wiredashController.setUserProperties(
        userEmail: "user@mail.com",
        userId: "123",
      );

      await robot.submitMinimalFeedback();
      AssertableInvocation latestCall =
          robot.mockServices.mockApi.sendFeedbackInvocations.latest;
      final firstFeedback = latestCall[0] as FeedbackItem?;
      expect(firstFeedback!.metadata.userEmail, 'user@mail.com');
      expect(firstFeedback.metadata.userId, '123');
      expect(firstFeedback.metadata.custom!['foo'], 'bar');

      customMetaData = const MapEntry('bar', 'foo');

      await robot.submitMinimalFeedback();
      latestCall = robot.mockServices.mockApi.sendFeedbackInvocations.latest;
      final secondFeedback = latestCall[0] as FeedbackItem?;
      expect(secondFeedback!.metadata.custom, hasLength(1));
      expect(secondFeedback.metadata.userEmail, 'user@mail.com');
      expect(secondFeedback.metadata.userId, '123');
      expect(secondFeedback.metadata.custom!['bar'], 'foo');
    });
  });
}
