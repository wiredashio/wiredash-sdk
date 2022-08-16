import 'package:clock/clock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:wiredash/src/_nps.dart';
import 'package:wiredash/src/core/telemetry/app_telemetry.dart';
import 'package:wiredash/src/core/telemetry/wiredash_telemetry.dart';
import 'package:wiredash/src/metadata/build_info/device_id_generator.dart';
import 'package:wiredash/src/nps/nps_trigger.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Do not ask again within frequency & initialDelay', () {
    Future<void> parametrizedTest(
      Duration frequency,
      Duration initialDelay,
    ) async {
      final appInstallTime = DateTime.utc(2020);
      DateTime now = appInstallTime;
      await withClock(Clock(() => now), () async {
        final wiredashTelemetry =
            PersistentWiredashTelemetry(SharedPreferences.getInstance);
        final appTelemetry =
            PersistentAppTelemetry(SharedPreferences.getInstance);
        await appTelemetry.onAppStart();
        final trigger = NpsTrigger(
          appTelemetry: appTelemetry,
          wiredashTelemetry: wiredashTelemetry,
          deviceIdGenerator: FakeDeviceIdGenerator('qwer'),
          options: NpsOptions(
            frequency: frequency,
            initialDelay: initialDelay,
            minimumAppStarts: 0,
          ),
        );

        final showTimes = <DateTime>[];
        while (showTimes.length < 3) {
          final show = await trigger.shouldShowNps();
          if (show) {
            await wiredashTelemetry.onOpenedNpsSurvey();
            showTimes.add(now);
          }
          if (now.isAfter(DateTime.utc(2030))) {
            throw Exception(
              'Not enough show times after $now. '
              'showTimes: $showTimes',
            );
          }
          now = now.add(const Duration(days: 1));
        }
        expect(showTimes, hasLength(3));

        final firstGap = showTimes[0].difference(appInstallTime);
        expect(
          firstGap >= initialDelay,
          isTrue,
          reason: 'The first nps is shown after $firstGap '
              'which is smaller than initialDelay $initialDelay',
        );

        // intervals should match frequency exactly (because we tick with 1 day)
        final secondGap = showTimes[1].difference(showTimes[0]);
        expect(
          secondGap,
          frequency,
          reason: 'time between first and second nps is $secondGap '
              'but should be $frequency',
        );
        final thirdGap = showTimes[2].difference(showTimes[1]);
        expect(
          thirdGap,
          frequency,
          reason: 'time between second and third nps is $secondGap '
              'but should be $frequency',
        );
      });
    }

    const frequencies = [
      Duration(days: 10),
      Duration(days: 90),
      Duration(days: 365),
    ];

    const initialDelays = [
      Duration.zero,
      Duration(days: 1),
      Duration(days: 7),
      Duration(days: 30),
    ];

    for (final frequency in frequencies) {
      for (final initialDelay in initialDelays) {
        test(
          'frequency: ${frequency.inDays}d, initialDelay: ${initialDelay.inDays}d',
          // split test body to make the test less indented and easier to read
          () async => parametrizedTest(frequency, initialDelay),
        );
      }
    }
  });

  test('first interval is randomly distributed, based on deviceId', () async {
    final DateTime now = DateTime.utc(2020);
    await withClock(Clock(() => now), () async {
      final deviceIdGenerator = FakeDeviceIdGenerator('');
      const frequency = Duration(days: 10);
      final wiredashTelemetry =
          PersistentWiredashTelemetry(SharedPreferences.getInstance);
      final appTelemetry =
          PersistentAppTelemetry(SharedPreferences.getInstance);
      await appTelemetry.onAppStart();
      final trigger = NpsTrigger(
        appTelemetry: appTelemetry,
        wiredashTelemetry: wiredashTelemetry,
        deviceIdGenerator: deviceIdGenerator,
        options: const NpsOptions(frequency: frequency),
      );

      deviceIdGenerator.mockedDeviceId = 'one';
      final date1 = await trigger.earliestNextNpsSurveyDate();
      expect(date1, DateTime.utc(2020, 1, 6, 21, 43, 8));

      deviceIdGenerator.mockedDeviceId = 'two';
      final date2 = await trigger.earliestNextNpsSurveyDate();
      expect(date2, DateTime.utc(2020, 1, 4, 5, 45, 30));

      deviceIdGenerator.mockedDeviceId = 'three';
      final date3 = await trigger.earliestNextNpsSurveyDate();
      expect(date3, DateTime.utc(2020, 1, 10, 6, 50, 44));

      expect(date1.isAfter(now), isTrue);
      expect(date2.isAfter(now), isTrue);
      expect(date3.isAfter(now), isTrue);

      final nextIntervalStart = now.add(frequency);
      expect(date1.isBefore(nextIntervalStart), isTrue);
      expect(date2.isBefore(nextIntervalStart), isTrue);
      expect(date3.isBefore(nextIntervalStart), isTrue);
    });
  });

  test('Check for minimumAppStarts', () async {
    DateTime now = DateTime.utc(2020);
    await withClock(Clock(() => now), () async {
      final wiredashTelemetry =
          PersistentWiredashTelemetry(SharedPreferences.getInstance);
      final appTelemetry =
          PersistentAppTelemetry(SharedPreferences.getInstance);
      final trigger = NpsTrigger(
        appTelemetry: appTelemetry,
        wiredashTelemetry: wiredashTelemetry,
        deviceIdGenerator: FakeDeviceIdGenerator('qwer'),
        options: const NpsOptions(
          frequency: Duration.zero,
          initialDelay: Duration.zero,
          minimumAppStarts: 3,
        ),
      );

      now = now.add(const Duration(days: 100));
      expect(await trigger.shouldShowNps(), isFalse);
      await appTelemetry.onAppStart();
      expect(await trigger.shouldShowNps(), isFalse);

      await appTelemetry.onAppStart();
      expect(await trigger.shouldShowNps(), isFalse);

      await appTelemetry.onAppStart();
      expect(await trigger.shouldShowNps(), isTrue);
    });
  });

  test('Show immediately when all settings are "cleared"', () async {
    final DateTime now = DateTime.utc(2020);
    await withClock(Clock(() => now), () async {
      final appTelemetry =
          PersistentAppTelemetry(SharedPreferences.getInstance);
      await appTelemetry.onAppStart();
      final trigger = NpsTrigger(
        appTelemetry: appTelemetry,
        wiredashTelemetry:
            PersistentWiredashTelemetry(SharedPreferences.getInstance),
        deviceIdGenerator: FakeDeviceIdGenerator('qwer'),
        options: const NpsOptions(
          frequency: Duration.zero,
          initialDelay: Duration.zero,
          minimumAppStarts: 0,
        ),
      );

      expect(await trigger.shouldShowNps(), isTrue);
    });
  });
}

class FakeDeviceIdGenerator implements DeviceIdGenerator {
  String mockedDeviceId;

  FakeDeviceIdGenerator(this.mockedDeviceId);

  @override
  Future<String> deviceId() async {
    return mockedDeviceId;
  }
}
