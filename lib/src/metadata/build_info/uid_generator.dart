// ignore_for_file: avoid_print

import 'package:nanoid2/nanoid2.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Generates a unique ids for client identification
class UidGenerator {
  static const _prefsDeviceID = '_wiredashDeviceID';
  static const _prefsAppUsageID = '_wiredashAppUsageID';

  /// A rather short timeout for shared preferences
  ///
  /// Usually shared preferences shouldn't fail. But if they do or don't react
  /// the deviceId fallback should generate in finite time
  static const _sharedPrefsTimeout = Duration(seconds: 2);

  UidGenerator();

  /// Feedbacks that are saved locally (offline) until they are sent to the server
  String localFeedbackId() {
    return nanoid(length: 8, alphabet: Alphabet.noDoppelgangerSafe);
  }

  /// screenshot attachment name (png)
  String screenshotFilename() {
    return nanoid(length: 8, alphabet: Alphabet.noDoppelgangerSafe);
  }

  /// Returns the unique id that is used for submitting feedback and promoter score
  ///
  /// The Future is lazy created an then cached, thus returns very fast when
  /// called multiple times
  Future<String> submitId() {
    final future = _deviceIdFuture;
    if (future != null) {
      return future;
    }

    // caching the Future instead of the actual deviceId to make sure concurrent
    // calls to deviceId(), before the future completes, returns the same value
    // and doesn't generate the deviceId multiple times
    _deviceIdFuture = _getInstallId(
      prefsKey: _prefsDeviceID,
      // 36 chars / length: 16 => 399B IDs needed, in order to have a 1% probability of at least one collision
      // https://zelark.github.io/nano-id-cc/
      generate: () => nanoid(length: 16, alphabet: Alphabet.noDoppelgangerSafe),
    );
    return _deviceIdFuture!;
  }

  Future<String>? _deviceIdFuture;

  /// Returns the unique id that is used for tracking app usage
  ///
  /// The Future is lazy created an then cached, thus returns very fast when
  /// called multiple times
  Future<String> appUsageId() {
    final future = _appAppUsageIdFuture;
    if (future != null) {
      return future;
    }

    _appAppUsageIdFuture = _getInstallId(
      prefsKey: _prefsAppUsageID,
      // 36 chars / length: 16 => 399B IDs needed, in order to have a 1% probability of at least one collision
      // https://zelark.github.io/nano-id-cc/
      generate: () => nanoid(length: 16, alphabet: Alphabet.noDoppelgangerSafe),
    );
    return _appAppUsageIdFuture!;
  }

  Future<String>? _appAppUsageIdFuture;

  /// Loads a install identifier from disk or generates a new one
  ///
  /// The identifier is stored in shared preferences and only deleted when the
  /// app is reinstalled
  static Future<String> _getInstallId({
    required String prefsKey,
    required String Function() generate,
  }) async {
    try {
      final prefs =
          await SharedPreferences.getInstance().timeout(_sharedPrefsTimeout);
      if (prefs.containsKey(prefsKey)) {
        final recovered = prefs.getString(prefsKey);
        if (recovered != null) {
          // recovered id from prefs
          return recovered;
        }
      }
    } catch (e, stack) {
      // might fail when users manipulate shared prefs. Creating a new id in
      // that case
      print(e);
      print(stack);
    }

    // first time generation or fallback in case of sharedPrefs error
    final deviceId = generate();
    try {
      final prefs =
          await SharedPreferences.getInstance().timeout(_sharedPrefsTimeout);
      await prefs.setString(prefsKey, deviceId).timeout(_sharedPrefsTimeout);
    } catch (e, stack) {
      print(e);
      print(stack);
    }
    return deviceId;
  }
}
