// ignore_for_file: avoid_print

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/common/utils/uuid.dart';

/// Generates a unique id per device and app install
class DeviceIdGenerator {
  static const _prefsDeviceID = '_wiredashDeviceID';

  /// A rather short timeout for shared preferences
  ///
  /// Usually shared preferences shouldn't fail. But if they do or don't react the
  /// deviceId fallback should generate in finite time
  static const _sharedPrefsTimeout = Duration(seconds: 2);

  DeviceIdGenerator();

  /// Returns the unique deviceId for this device/app combination
  ///
  /// The Future is lazy created an then cached, thus returns very fast when called multiple times
  Future<String> deviceId() {
    final future = _deviceIdFuture;
    if (future != null) {
      return future;
    }
    _deviceIdFuture = _loadDeviceID();
    return _deviceIdFuture!;
  }

  Future<String>? _deviceIdFuture;

  static Future<String> _loadDeviceID() async {
    try {
      final prefs =
          await SharedPreferences.getInstance().timeout(_sharedPrefsTimeout);
      if (prefs.containsKey(_prefsDeviceID)) {
        final recovered = prefs.getString(_prefsDeviceID);
        if (recovered != null) {
          // recovered deviceId from prefs
          return recovered;
        }
      }
    } catch (e, stack) {
      print(e);
      print(stack);
    }

    // first time generation or fallback in case of sharedPrefs error
    final _deviceId = uuidV4.generate();
    try {
      final prefs =
          await SharedPreferences.getInstance().timeout(_sharedPrefsTimeout);
      await prefs
          .setString(_prefsDeviceID, _deviceId)
          .timeout(_sharedPrefsTimeout);
    } catch (e, stack) {
      print(e);
      print(stack);
    }
    return _deviceId;
  }
}
