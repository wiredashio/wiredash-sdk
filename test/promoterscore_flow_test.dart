import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spot/spot.dart';
import 'package:wiredash/src/_ps.dart';
import 'package:wiredash/src/_wiredash_internal.dart';

import 'util/robot.dart';

void main() {
  group('promoter score', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Send promoter score', (tester) async {
      final robot = await WiredashTestRobot(tester).launchApp();
      await robot.openPromoterScore();
      await robot.ratePromoterScore(7);
      await robot.submitPromoterScore();
      await robot.showsPromoterScoreThanksMessage();
      // Shows success message for a while
      await tester.pump(const Duration(milliseconds: 900));
      await robot.showsPromoterScoreThanksMessage();
      await robot.waitUntilWiredashIsClosed();
      final psCalls = robot.mockServices.mockApi.sendPsInvocations.invocations;
      expect(psCalls, hasLength(3));
      final callOne = psCalls[0][0] as PromoterScoreRequestBody?;
      expect(callOne!.score, isNull);
      expect(callOne.metadata.platformOS, isNotNull);
      expect(callOne.message, isNull);

      final callTwo = psCalls[1][0] as PromoterScoreRequestBody?;
      expect(callTwo!.score?.intValue, 7);
      expect(callTwo.metadata.platformOS, isNotNull);
      expect(callTwo.message, isNull);

      final callThree = psCalls[2][0] as PromoterScoreRequestBody?;
      expect(callThree!.score?.intValue, 7);
      expect(callThree.metadata.platformOS, isNotNull);
      expect(callThree.message, isNull);
    });

    testWidgets('Send promoter score with message', (tester) async {
      final robot = await WiredashTestRobot(tester).launchApp();
      await robot.openPromoterScore();
      await robot.ratePromoterScore(3);
      await robot.enterPromotionScoreMessage('What a cool app!');
      await robot.submitPromoterScore();
      await robot.showsPromoterScoreThanksMessage();
      // Shows success message for a while
      await tester.pump(const Duration(milliseconds: 900));
      await robot.showsPromoterScoreThanksMessage();
      await robot.waitUntilWiredashIsClosed();
      final psCalls = robot.mockServices.mockApi.sendPsInvocations.invocations;
      expect(psCalls, hasLength(3));
      final callOne = psCalls[0][0] as PromoterScoreRequestBody?;
      expect(callOne!.score, isNull);
      expect(callOne.metadata.platformOS, isNotNull);
      expect(callOne.message, isNull);

      final callTwo = psCalls[1][0] as PromoterScoreRequestBody?;
      expect(callTwo!.score?.intValue, 3);
      expect(callTwo.metadata.platformOS, isNotNull);
      expect(callTwo.message, isNull);

      final callThree = psCalls[2][0] as PromoterScoreRequestBody?;
      expect(callThree!.score?.intValue, 3);
      expect(callThree.metadata.platformOS, isNotNull);
      expect(callThree.message, 'What a cool app!');
    });

    testWidgets('Send promoter score shown event to console', (tester) async {
      final robot = await WiredashTestRobot(tester).launchApp();
      await robot.openPromoterScore();
      final latestCall = robot.mockServices.mockApi.sendPsInvocations.latest;
      final request = latestCall[0] as PromoterScoreRequestBody?;
      expect(request!.metadata.installId, isNotNull);
    });

    testWidgets('Shows detractors thanks message', (tester) async {
      final robot = await WiredashTestRobot(tester).launchApp();
      await robot.openPromoterScore();
      await robot.ratePromoterScore(2);
      await robot.enterPromotionScoreMessage('Hello World');
      await robot.submitPromoterScore();
      await robot.showsPromoterScoreThanksMessage(
        find.text('l10n.promoterScoreStep3ThanksMessageDetractors'),
      );
      await robot.waitUntilWiredashIsClosed();
    });

    testWidgets('Shows passives thanks message', (tester) async {
      final robot = await WiredashTestRobot(tester).launchApp();
      await robot.openPromoterScore();
      await robot.ratePromoterScore(8);
      await robot.enterPromotionScoreMessage('Hello World');
      await robot.submitPromoterScore();
      await robot.showsPromoterScoreThanksMessage(
        find.text('l10n.promoterScoreStep3ThanksMessagePassives'),
      );
      await robot.waitUntilWiredashIsClosed();
    });

    testWidgets('Shows promoters thanks message', (tester) async {
      final robot = await WiredashTestRobot(tester).launchApp();
      await robot.openPromoterScore();
      await robot.ratePromoterScore(9);
      await robot.enterPromotionScoreMessage('Hello World');
      await robot.submitPromoterScore();
      await robot.showsPromoterScoreThanksMessage(
        find.text('l10n.promoterScoreStep3ThanksMessagePromoters'),
      );
      await robot.waitUntilWiredashIsClosed();
    });

    testWidgets('promoter score is discarded when closing Wiredash',
        (tester) async {
      final robot = await WiredashTestRobot(tester).launchApp();
      await robot.openPromoterScore();
      await robot.ratePromoterScore(9);
      expect(robot.services.psModel.score, PromoterScoreRating.rating9);
      await robot.closeWiredash();
      await robot.openPromoterScore();
      expect(robot.services.psModel.score, isNull);
    });

    testWidgets('Track lastPromoterScoreSurvey in telemetry', (tester) async {
      final robot = await WiredashTestRobot(tester).launchApp();
      final lastPsSurvey =
          await robot.services.wiredashTelemetry.lastPromoterScoreSurvey();
      expect(lastPsSurvey, isNull);
      await robot.openPromoterScore();
      final latestPsSurvey =
          await robot.services.wiredashTelemetry.lastPromoterScoreSurvey();
      expect(latestPsSurvey, isNotNull);
      final appStartCount = await robot.services.appTelemetry.appStartCount();
      expect(appStartCount, 1);
      final firstAppStart = await robot.services.appTelemetry.firstAppStart();
      expect(firstAppStart, isNotNull);
    });

    testWidgets(
        'Do not show error when submit fails, complete with thanks message',
        (tester) async {
      final robot = await WiredashTestRobot(tester).launchApp();

      robot.mockServices.mockApi.sendPsInvocations.interceptor =
          (invocation) async {
        throw Exception('No internet');
      };
      final oldOnErrorHandler = FlutterError.onError;
      late FlutterErrorDetails caught;
      FlutterError.onError = (FlutterErrorDetails details) {
        caught = details;
      };
      addTearDown(() {
        FlutterError.onError = oldOnErrorHandler;
      });

      await robot.openPromoterScore();
      await robot.ratePromoterScore(7);
      await robot.submitPromoterScore();
      await robot.showsPromoterScoreThanksMessage();
      // Shows success message for a while
      await tester.pump(const Duration(milliseconds: 900));
      await robot.showsPromoterScoreThanksMessage();

      await robot.waitUntilWiredashIsClosed();
      expect(caught.exception.toString(), contains('No internet'));
    });

    testWidgets('Hold app while submitting ps resets form', (tester) async {
      // verifies issue https://github.com/wiredashio/wiredash-sdk/issues/310
      final robot = await WiredashTestRobot(tester).launchApp();

      await robot.openPromoterScore();
      await robot.ratePromoterScore(7);

      // touch and move the app a bit but don't lift the finger
      final topRight = tester.getTopRight(find.byType(MaterialApp));
      final gesture =
          await tester.startGesture(Offset(topRight.dx / 2, topRight.dy + 20));
      await tester.pump(const Duration(milliseconds: 10));
      await gesture.moveBy(
        const Offset(0, 10),
        timeStamp: const Duration(milliseconds: 10),
      );
      await tester.pump(const Duration(milliseconds: 10));
      await gesture.moveBy(
        const Offset(0, 10),
        timeStamp: const Duration(milliseconds: 20),
      );
      await tester.pump(const Duration(milliseconds: 10));

      await robot.submitPromoterScore();
      await robot.showsPromoterScoreThanksMessage();

      spotSingle<PsStep1Rating>().doesNotExist();

      // wait for wiredash hide() after 2s delay
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // back on first step, the form got reset
      spotSingle<PsStep1Rating>().existsOnce();

      await gesture.up(); // let go of the app
    });
  });
}
