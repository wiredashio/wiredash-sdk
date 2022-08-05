import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/nps/nps_model.dart';

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
      final latestCall = robot.mockServices.mockApi.sendNpsInvocations.latest;
      final request = latestCall[0] as NpsRequestBody?;
      expect(request!.score.intValue, 7);
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
