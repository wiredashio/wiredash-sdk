import 'package:clock/clock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:wiredash/src/_nps.dart';
import 'package:wiredash/src/metadata/build_info/device_id_generator.dart';
import 'package:wiredash/src/nps/nps_trigger.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Do not ask again within frequency', () async {
    DateTime now = DateTime(2020);
    await withClock(Clock(() => now), () async {
      final trigger = NpsTrigger(
        sharedPreferencesProvider: SharedPreferences.getInstance,
        deviceIdGenerator: StaticDeviceIdGenerator('qwer'),
        options: NpsOptions(frequency: const Duration(days: 10)),
      );

      // trigger is scheduled for a later time based on the deviceId§ and frequency
      final zeroTime = await trigger.shouldShowNps();
      expect(zeroTime, isFalse);

      // Based on the deviceId, user should
      now = now.add(const Duration(days: 10));
      final firstTime = await trigger.shouldShowNps();
      expect(firstTime, isTrue);

      trigger.openedNpsSurvey();

      final secondTime = await trigger.shouldShowNps();
      expect(secondTime, isFalse);

      now = now.add(const Duration(days: 10));
      final thirdTime = await trigger.shouldShowNps();
      expect(thirdTime, isTrue);
    });
  });
}

class StaticDeviceIdGenerator implements DeviceIdGenerator {
  final String mockedDeviceId;

  StaticDeviceIdGenerator(this.mockedDeviceId);

  @override
  Future<String> deviceId() async {
    return mockedDeviceId;
  }
}
