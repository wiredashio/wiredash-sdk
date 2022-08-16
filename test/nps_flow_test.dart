import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/nps/nps_model.dart';

import 'util/invocation_catcher.dart';
import 'util/robot.dart';

void main() {
  group('NPS', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Send NPS', (tester) async {
      final robot = await WiredashTestRobot.launchApp(tester);
      await robot.openNps();
      await robot.rateNps(7);
      await robot.submitNps();
      await robot.showsNpsThanksMessage();
      // Shows success message for a while
      await tester.pump(const Duration(milliseconds: 900));
      await robot.showsNpsThanksMessage();
      await robot.waitUntilWiredashIsClosed();
      final npsCalls =
          robot.mockServices.mockApi.sendNpsInvocations.invocations;
      expect(npsCalls, hasLength(3));
      final callOne = npsCalls[0][0] as NpsRequestBody?;
      expect(callOne!.score, isNull);
      expect(callOne.platformOS, isNotNull);
      expect(callOne.message, isNull);

      final callTwo = npsCalls[1][0] as NpsRequestBody?;
      expect(callTwo!.score?.intValue, 7);
      expect(callTwo.platformOS, isNotNull);
      expect(callTwo.message, isNull);

      final callThree = npsCalls[2][0] as NpsRequestBody?;
      expect(callThree!.score?.intValue, 7);
      expect(callThree.platformOS, isNotNull);
      expect(callThree.message, isNull);
    });

    testWidgets('Send NPS with message', (tester) async {
      final robot = await WiredashTestRobot.launchApp(tester);
      await robot.openNps();
      await robot.rateNps(3);
      await robot.enterNpsMessage('What a cool app!');
      await robot.submitNps();
      await robot.showsNpsThanksMessage();
      // Shows success message for a while
      await tester.pump(const Duration(milliseconds: 900));
      await robot.showsNpsThanksMessage();
      await robot.waitUntilWiredashIsClosed();
      final npsCalls =
          robot.mockServices.mockApi.sendNpsInvocations.invocations;
      expect(npsCalls, hasLength(3));
      final callOne = npsCalls[0][0] as NpsRequestBody?;
      expect(callOne!.score, isNull);
      expect(callOne.platformOS, isNotNull);
      expect(callOne.message, isNull);

      final callTwo = npsCalls[1][0] as NpsRequestBody?;
      expect(callTwo!.score?.intValue, 3);
      expect(callTwo.platformOS, isNotNull);
      expect(callTwo.message, isNull);

      final callThree = npsCalls[2][0] as NpsRequestBody?;
      expect(callThree!.score?.intValue, 3);
      expect(callThree.platformOS, isNotNull);
      expect(callThree.message, 'What a cool app!');
    });

    testWidgets('Send NPS shown to console', (tester) async {
      final robot = await WiredashTestRobot.launchApp(tester);
      await robot.openNps();
      final latestCall = robot.mockServices.mockApi.sendNpsInvocations.latest;
      final request = latestCall[0] as NpsRequestBody?;
      expect(request!.deviceId, isNotNull);
    });

    testWidgets('Shows detractors thanks message', (tester) async {
      final robot = await WiredashTestRobot.launchApp(tester);
      await robot.openNps();
      await robot.rateNps(2);
      await robot.enterNpsMessage('Hello World');
      await robot.submitNps();
      await robot.showsNpsThanksMessage(
        find.text('l10n.npsStep3ThanksMessageDetractors'),
      );
      await robot.waitUntilWiredashIsClosed();
    });

    testWidgets('Shows passives thanks message', (tester) async {
      final robot = await WiredashTestRobot.launchApp(tester);
      await robot.openNps();
      await robot.rateNps(8);
      await robot.enterNpsMessage('Hello World');
      await robot.submitNps();
      await robot.showsNpsThanksMessage(
        find.text('l10n.npsStep3ThanksMessagePassives'),
      );
      await robot.waitUntilWiredashIsClosed();
    });

    testWidgets('Shows promoters thanks message', (tester) async {
      final robot = await WiredashTestRobot.launchApp(tester);
      await robot.openNps();
      await robot.rateNps(9);
      await robot.enterNpsMessage('Hello World');
      await robot.submitNps();
      await robot.showsNpsThanksMessage(
        find.text('l10n.npsStep3ThanksMessagePromoters'),
      );
      await robot.waitUntilWiredashIsClosed();
    });

    testWidgets(
        'Do not show error when submit fails, complete with thanks message',
        (tester) async {
      final robot = await WiredashTestRobot.launchApp(tester);

      robot.mockServices.mockApi.sendNpsInvocations.interceptor =
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

      await robot.openNps();
      await robot.rateNps(7);
      await robot.submitNps();
      await robot.showsNpsThanksMessage();
      // Shows success message for a while
      await tester.pump(const Duration(milliseconds: 900));
      await robot.showsNpsThanksMessage();

      await robot.waitUntilWiredashIsClosed();
      expect(caught.exception.toString(), contains('No internet'));
    });
  });
}
