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

  group('Do not ask again within frequency', () {
    const frequencies = [
      Duration(days: 10),
      Duration(days: 90),
      Duration(days: 365),
    ];

    for (final frequency in frequencies) {
      test('frequency: ${frequency.inDays} days', () async {
        DateTime now = DateTime.utc(2020);
        await withClock(Clock(() => now), () async {
          final trigger = NpsTrigger(
            sharedPreferencesProvider: SharedPreferences.getInstance,
            deviceIdGenerator: StaticDeviceIdGenerator('qwer'),
            options: NpsOptions(frequency: frequency),
          );

          final showTimes = <DateTime>[];
          while (showTimes.length < 3) {
            final show = await trigger.shouldShowNps();
            if (show) {
              await trigger.openedNpsSurvey();
              showTimes.add(now);
            }
            now = now.add(const Duration(days: 1));
          }
          expect(showTimes, hasLength(3));

          // intervals should match frequency exactly (because we tick with 1 day)
          final difference1 = showTimes[1].difference(showTimes[0]);
          expect(difference1, frequency);
          final difference2 = showTimes[2].difference(showTimes[1]);
          expect(difference2, frequency);
        });
      });
    }
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
