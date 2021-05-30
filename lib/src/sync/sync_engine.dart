import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/common/network/wiredash_api.dart';
import 'package:clock/clock.dart';

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

  static const minSyncGap = Duration(hours: 1);

  static const lastSuccessfulPingKey = 'io.wiredash.last_successful_ping';
  static const lastFeedbackSubmissionKey =
      'io.wiredash.last_feedback_submission';

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

    if (lastPing != null && lastPing.difference(now).abs() > minSyncGap) {
      _initTimer?.cancel();
      _initTimer = Timer(Duration(seconds: 2), _ping);
    }
  }

  /// Called when the user manually opened Wiredash
  ///
  /// This 100% calls the backend, forcing a sync
  Future<void> onUserOpenedWiredash() async {
    await _ping();
  }

  /// Pings the backend with a very cheep call checking if anything should be synced
  Future<void> _ping() async {
    try {
      final response = await _api.ping();
      final preferences = await _sharedPreferences();
      final now = clock.now();
      await preferences.setInt(lastSuccessfulPingKey, now.millisecond);
    } catch (e, stack) {
      // TODO
      print(e);
      print(stack);
    }
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
