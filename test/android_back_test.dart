// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/core/widgets/larry_page_view.dart';
import 'package:wiredash/src/feedback/_feedback.dart';

import 'util/assert_widget.dart';
import 'util/mock_api.dart';
import 'util/robot.dart';

void main() {
  group('Wiredash', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Send text only feedback', (tester) async {
      final robot = await WiredashTestRobot.launchApp(tester);
      final mockApi = MockWiredashApi();
      robot.mockWiredashApi(mockApi);

      await robot.openWiredash();
      await robot.enterFeedbackMessage('test message');
      await robot.goToNextStep();
      await robot.skipScreenshot();
      assertWidget(LarryPageView).child(Step6Submit).existsOnce();

      await robot.pressAndroidBackButton();
      assertWidget(LarryPageView).child(Step3ScreenshotOverview).existsOnce();

      await robot.pressAndroidBackButton();
      assertWidget(LarryPageView).child(Step1FeedbackMessage).existsOnce();
      expect(robot.services.wiredashModel.isWiredashActive, isTrue);

      // closes wiredash
      await robot.pressAndroidBackButton();
      expect(robot.services.wiredashModel.isWiredashActive, isFalse);
    });
  });
}
