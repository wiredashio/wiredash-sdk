import 'package:clock/clock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/options/environment_loader.dart';
import 'package:wiredash/src/core/sync/sync_engine.dart';
import 'package:wiredash/src/core/version.dart';
import 'package:wiredash/src/metadata/meta_data_collector.dart';

class PingJob extends Job {
  final WiredashApi Function() apiProvider;
  final Future<SharedPreferences> Function() sharedPreferencesProvider;
  final WuidGenerator Function() wuidGenerator;
  final MetaDataCollector Function() metaDataCollector;
  final EnvironmentLoader Function() environmentLoader;

  PingJob({
    required this.apiProvider,
    required this.sharedPreferencesProvider,
    required this.wuidGenerator,
    required this.metaDataCollector,
    required this.environmentLoader,
  });

  static const lastSuccessfulPingKey = 'io.wiredash.last_successful_ping';
  static const silenceUntilKey = 'io.wiredash.silence_ping_until';

  static const minPingGap = Duration(minutes: 30);
  static const killSwitchSilenceDuration = Duration(days: 7);

  @override
  bool shouldExecute(SdkEvent event) {
    return event == SdkEvent.appStartDelayed;
  }

  @override
  Future<void> execute(SdkEvent event) async {
    final now = clock.now();

    if (await _isSilenced(now)) {
      // Received kill switch message, don't ping at all
      syncDebugPrint('Sdk silenced, preventing ping');
      return;
    }

    final lastPing = await _getLastSuccessfulPing();
    if (lastPing != null && now.difference(lastPing) <= minPingGap) {
      syncDebugPrint(
        'Not syncing because within minSyncGapWindow\n'
        'now: $now lastPing:$lastPing\n'
        'diff (${now.difference(lastPing)}) <= minSyncGap ($minPingGap)',
      );
      // don't ping too often on app start, only once every minPingGap
      return;
    }

    final fixedMetadata = await metaDataCollector().collectFixedMetaData();
    final flutterInfo = metaDataCollector().collectFlutterInfo();
    final environment = await environmentLoader().getEnvironment();

    final body = PingRequestBody(
      analyticsId: await wuidGenerator().appUsageId(),
      buildCommit: fixedMetadata.resolvedBuildCommit,
      buildNumber: fixedMetadata.resolvedBuildNumber,
      buildVersion: fixedMetadata.resolvedBuildVersion,
      bundleId: fixedMetadata.appInfo.bundleId,
      environment: environment,
      platformLocale: flutterInfo.platformLocale,
      platformOS: flutterInfo.platformOS,
      platformOSVersion: fixedMetadata.deviceInfo.osVersion,
      sdkVersion: wiredashSdkVersion,
    );
    try {
      await apiProvider().ping(body);
      await _saveLastSuccessfulPing(now);
      syncDebugPrint('ping');
    } on KillSwitchException catch (_) {
      // Server explicitly asks the SDK to be silent
      final earliestNextPing = now.add(killSwitchSilenceDuration);
      await _silenceUntil(earliestNextPing);
      syncDebugPrint('Silenced Wiredash until $earliestNextPing');
    } catch (e, stack) {
      // Any other error, like network errors or server errors, silence the ping
      // for a while, too
      syncDebugPrint('Received an unknown error for ping');
      syncDebugPrint(e);
      syncDebugPrint(stack);
    }
  }

  /// Silences the sdk, prevents automatic pings on app startup until the time is over
  Future<void> _silenceUntil(DateTime dateTime) async {
    final preferences = await sharedPreferencesProvider();
    preferences.setInt(silenceUntilKey, dateTime.millisecondsSinceEpoch);
    syncDebugPrint('Silenced Wiredash until $dateTime');
  }

  /// `true` when automatic pings should be prevented
  Future<bool> _isSilenced(DateTime now) async {
    final preferences = await sharedPreferencesProvider();

    final int? millis = preferences.getInt(silenceUntilKey);
    if (millis == null) {
      return false;
    }
    final silencedUntil = DateTime.fromMillisecondsSinceEpoch(millis);
    final silenced = silencedUntil.isAfter(now);
    if (silenced) {
      syncDebugPrint("Sdk is silenced until $silencedUntil (now $now)");
    }
    return silenced;
  }

  Future<DateTime?> _getLastSuccessfulPing() async {
    final preferences = await sharedPreferencesProvider();
    final lastPingInt = preferences.getInt(lastSuccessfulPingKey);
    if (lastPingInt == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(lastPingInt);
  }

  Future<void> _saveLastSuccessfulPing(DateTime now) async {
    final preferences = await sharedPreferencesProvider();
    await preferences.setInt(lastSuccessfulPingKey, now.millisecondsSinceEpoch);
  }
}
