import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/common/network/wiredash_api.dart';
import 'package:clock/clock.dart';

const _debugPrint = false;

class SyncEngine {
  final WiredashApi _api;
  final Future<SharedPreferences> Function() _sharedPreferences;

  SyncEngine(
      WiredashApi api, Future<SharedPreferences> Function() sharedPreferences)
      : _api = api,
        _sharedPreferences = sharedPreferences;

  void dispose() {
    _initTimer?.cancel();
  }

  Timer? _initTimer;

  static const minSyncGap = Duration(hours: 3);

  static const lastSuccessfulPingKey = 'io.wiredash.last_successful_ping';
  static const lastFeedbackSubmissionKey =
      'io.wiredash.last_feedback_submission';
  static const silenceUntilKey = 'io.wiredash.silence_until';

  /// Called when the SDK is initialized (by wrapping the app)
  ///
  /// This eventually syncs with the backend
  Future<void> onWiredashInitialized() async {
    assert(() {
      if (_initTimer != null) {
        debugPrint("called onWiredashInitialized multiple times");
      }
      return true;
    }());

    final now = clock.now();
    final preferences = await _sharedPreferences();
    final lastPingInt = preferences.getInt(lastSuccessfulPingKey);
    final lastPing = lastPingInt != null
        ? DateTime.fromMillisecondsSinceEpoch(lastPingInt)
        : null;

    if (lastPing == null) {
      // never opened wiredash, don't ping automatically on appstart
      if (_debugPrint) debugPrint('Never opened wiredash, preventing ping');
      return;
    }

    if (now.difference(lastPing) <= minSyncGap) {
      if (_debugPrint) {
        debugPrint('Not syncing because within minSyncGapWindow\n'
            'now: $now lastPing:$lastPing\n'
            'diff (${now.difference(lastPing)}) <= minSyncGap ($minSyncGap)');
      }
      // don't ping too often on appstart, only once every minSyncGap
      return;
    }

    if (await _isSilenced()) {
      if (_debugPrint) debugPrint('Sdk silenced, preventing ping');
      // Received kill switch message, don't automatically ping
      return;
    }

    _initTimer?.cancel();
    _initTimer = Timer(const Duration(seconds: 2), _ping);
  }

  /// Called when the user manually opened Wiredash
  ///
  /// This 100% calls the backend, forcing a sync
  Future<void> onUserOpenedWiredash() async {
    // always ping on manual open, ignore silencing
    await _ping();
  }

  /// Pings the backend with a very cheep call checking if anything should be synced
  Future<void> _ping() async {
    try {
      final response = await _api.ping();
      final preferences = await _sharedPreferences();
      final latestMessageId = response.latestMessageId;
      if (latestMessageId != null) {
        await preferences.setString(latestMessageIdKey, latestMessageId);
      }

      final now = clock.now();
      await preferences.setInt(
          lastSuccessfulPingKey, now.millisecondsSinceEpoch);
    } on KillSwitchException catch (e) {
      // sdk receives too much load, prevents further automatic pings
      await _silenceUntil(e.silentUntil);
    } catch (e, _) {
      // TODO track number of conseccutive errors to prevent pings at all
      // debugPrint(e.toString());
      // debugPrint(stack.toString());
    }
  }

  /// Silences the sdk, prevents automatic pings on app startup until the time is over
  Future<void> _silenceUntil(DateTime dateTime) async {
    final preferences = await _sharedPreferences();
    preferences.setInt(silenceUntilKey, dateTime.millisecondsSinceEpoch);
    debugPrint('Silenced Wiredash until $dateTime');
  }

  /// `true` when automatic pings should be prevented
  Future<bool> _isSilenced() async {
    final now = clock.now();
    final preferences = await _sharedPreferences();

    final int? millis = preferences.getInt(silenceUntilKey);
    if (millis == null) {
      return false;
    }
    final silencedUntil = DateTime.fromMillisecondsSinceEpoch(millis);
    final silenced = silencedUntil.isAfter(now);
    if (_debugPrint && silenced) {
      debugPrint("Sdk is silenced until $silencedUntil (now $now)");
    }
    return silenced;
  }

  /// Remembers the time (now) when the last feedback was submitted
  ///
  /// This information is used to trigger [_ping] on app start within [minSyncGap] periode
  Future<void> rememberFeedbackSubmission() async {
    final now = clock.now();
    final preferences = await _sharedPreferences();
    await preferences.setInt(lastFeedbackSubmissionKey, now.millisecond);
  }
}
