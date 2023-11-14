import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/_ps.dart';
import 'package:wiredash/src/core/telemetry/app_telemetry.dart';
import 'package:wiredash/src/core/telemetry/wiredash_telemetry.dart';
import 'package:wiredash/src/core/wuid_generator.dart';

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
        final trigger = PsTrigger(
          appTelemetry: appTelemetry,
          wiredashTelemetry: wiredashTelemetry,
          wuidGenerator: FakeWuidGenerator('qwer'),
        );
        final options = PsOptions(
          frequency: frequency,
          initialDelay: initialDelay,
          minimumAppStarts: 0,
        );

        final showTimes = <DateTime>[];
        while (showTimes.length < 3) {
          final show = await trigger.shouldShowPromoterSurvey(options: options);
          if (show) {
            await wiredashTelemetry.onOpenedPromoterScoreSurvey();
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
          reason: 'The first promoter score survey is shown after $firstGap '
              'which is smaller than initialDelay $initialDelay',
        );

        // intervals should match frequency exactly (because we tick with 1 day)
        final secondGap = showTimes[1].difference(showTimes[0]);
        expect(
          secondGap,
          frequency,
          reason: 'time between first and second survey is $secondGap '
              'but should be $frequency',
        );
        final thirdGap = showTimes[2].difference(showTimes[1]);
        expect(
          thirdGap,
          frequency,
          reason: 'time between second and third survey is $secondGap '
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
      final deviceIdGenerator = FakeWuidGenerator('');
      const frequency = Duration(days: 10);
      final wiredashTelemetry =
          PersistentWiredashTelemetry(SharedPreferences.getInstance);
      final appTelemetry =
          PersistentAppTelemetry(SharedPreferences.getInstance);
      await appTelemetry.onAppStart();
      final trigger = PsTrigger(
        appTelemetry: appTelemetry,
        wiredashTelemetry: wiredashTelemetry,
        wuidGenerator: deviceIdGenerator,
      );
      const options = PsOptions(frequency: frequency);

      deviceIdGenerator.mockedSubmitId = 'one';
      final date1 = await trigger.earliestNextPromoterScoreSurveyDate(options);
      expect(date1, DateTime.utc(2020, 1, 6, 21, 43, 8));

      deviceIdGenerator.mockedSubmitId = 'two';
      final date2 = await trigger.earliestNextPromoterScoreSurveyDate(options);
      expect(date2, DateTime.utc(2020, 1, 4, 5, 45, 30));

      deviceIdGenerator.mockedSubmitId = 'three';
      final date3 = await trigger.earliestNextPromoterScoreSurveyDate(options);
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
      const options = PsOptions(
        frequency: Duration.zero,
        initialDelay: Duration.zero,
        minimumAppStarts: 3,
      );
      final trigger = PsTrigger(
        appTelemetry: appTelemetry,
        wiredashTelemetry: wiredashTelemetry,
        wuidGenerator: FakeWuidGenerator('qwer'),
      );

      now = now.add(const Duration(days: 100));
      expect(await trigger.shouldShowPromoterSurvey(options: options), isFalse);
      await appTelemetry.onAppStart();
      expect(await trigger.shouldShowPromoterSurvey(options: options), isFalse);

      await appTelemetry.onAppStart();
      expect(await trigger.shouldShowPromoterSurvey(options: options), isFalse);

      await appTelemetry.onAppStart();
      expect(await trigger.shouldShowPromoterSurvey(options: options), isTrue);
    });
  });

  test('Show immediately when all settings are "cleared"', () async {
    final DateTime now = DateTime.utc(2020);
    await withClock(Clock(() => now), () async {
      final appTelemetry =
          PersistentAppTelemetry(SharedPreferences.getInstance);
      await appTelemetry.onAppStart();
      const options = PsOptions(
        frequency: Duration.zero,
        initialDelay: Duration.zero,
        minimumAppStarts: 0,
      );
      final trigger = PsTrigger(
        appTelemetry: appTelemetry,
        wiredashTelemetry:
            PersistentWiredashTelemetry(SharedPreferences.getInstance),
        wuidGenerator: FakeWuidGenerator('qwer'),
      );

      expect(await trigger.shouldShowPromoterSurvey(options: options), isTrue);
    });
  });
}

class FakeWuidGenerator implements WuidGenerator {
  String mockedSubmitId;

  FakeWuidGenerator(this.mockedSubmitId);

  @override
  String generateId(int length) {
    return mockedSubmitId;
  }

  @override
  Future<String> generatePersistedId(String key, int length) async {
    return mockedSubmitId;
  }
}
