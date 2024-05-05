import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/core/network/send_events_request.dart';

import '../util/robot.dart';
import '../util/wiredash_tester.dart';

void main() {
  testWidgets('#firstLaunch event is submitted', (tester) async {
    final robot = WiredashTestRobot(tester);
    await robot.launchApp(firstLaunch: true);
    await tester.pumpSmart(const Duration(seconds: 5));
    final eventSubmissions =
        robot.mockServices.mockApi.sendEventsInvocations.invocations;
    expect(eventSubmissions, hasLength(1)); // one call
    final events = eventSubmissions[0][0]! as List<RequestEvent>;
    expect(events, hasLength(1)); // one event
    final event = events[0];
    expect(event.eventName, '#firstLaunch');
  });

  testWidgets('No #firstLaunch at second launch', (tester) async {
    final robot = WiredashTestRobot(tester);
    robot.setupMocks();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('_wiredashAppUsageID', 'someId');
    await robot.launchApp();
    await tester.pumpSmart(const Duration(seconds: 5));
    final eventSubmissions =
        robot.mockServices.mockApi.sendEventsInvocations.invocations;
    expect(eventSubmissions, hasLength(0)); // no call
  });
}
