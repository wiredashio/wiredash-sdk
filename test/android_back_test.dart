// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spot/spot.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/core/network/wiredash_api.dart';
import 'package:wiredash/src/core/widgets/backdrop/wiredash_backdrop.dart';
import 'package:wiredash/src/core/widgets/larry_page_view.dart';

import 'util/mock_api.dart';
import 'util/robot.dart';

void main() {
  group('Android Back', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('To submit and back until close - excluding screenshot',
        (tester) async {
      final robot = await WiredashTestRobot.launchApp(tester);
      final mockApi = MockWiredashApi();
      robot.services.inject<WiredashApi>((_) => mockApi);

      await robot.openWiredash();
      await robot.enterFeedbackMessage('test message');
      await robot.goToNextStep();
      await robot.skipScreenshot();
      await robot.skipEmail();
      spot<LarryPageView>().spot<Step6Submit>().existsOnce();

      await robot.pressAndroidBackButton();
      spot<WiredashBackdrop>()
          .spot<LarryPageView>()
          .spot<Step5Email>()
          .existsOnce();

      await robot.pressAndroidBackButton();
      spot<WiredashBackdrop>()
          .spot<LarryPageView>()
          .spot<Step3ScreenshotOverview>()
          .existsOnce();

      await robot.pressAndroidBackButton();
      spot<LarryPageView>().spot<Step1FeedbackMessage>().existsOnce();
      expect(robot.services.wiredashModel.isWiredashActive, isTrue);

      // closes wiredash
      await robot.pressAndroidBackButton();
      expect(robot.services.wiredashModel.isWiredashActive, isFalse);
    });
  });
}
