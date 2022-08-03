import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/nps/nps_model.dart';
import 'util/robot.dart';

void main() {
  autoUpdateGoldenFiles = true;
  group('NPS', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Send NPS', (tester) async {
      final robot = await WiredashTestRobot.launchApp(tester);
      await robot.openNps();
      await robot.rateNps(7);
      await robot.submitNps();
      await robot.waitUntilWiredashIsClosed();
      final latestCall = robot.mockServices.mockApi.sendNpsInvocations.latest;
      final request = latestCall[0] as NpsRequestBody?;
      expect(request!.score.intValue, 7);
    });

    testWidgets('Send NPS with message', (tester) async {
      final robot = await WiredashTestRobot.launchApp(tester);
      await robot.openNps();
      await robot.rateNps(7);
      await robot.enterNpsMessage('Hello World');
      await robot.submitNps();
      await robot.waitUntilWiredashIsClosed();
      final latestCall = robot.mockServices.mockApi.sendNpsInvocations.latest;
      final request = latestCall[0] as NpsRequestBody?;
      expect(request!.score.intValue, 7);
      expect(request.message, 'Hello World');
    });
  });
}
