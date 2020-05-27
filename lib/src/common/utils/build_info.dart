import 'dart:math' as math show Random;

import 'package:shared_preferences/shared_preferences.dart';

abstract class BuildInfo {
  String get buildNumber;
  String get buildVersion;
  String get buildCommit;
  String get deviceId;
}

/// Class retrieving basic build information about the app
///
/// The properties can be defined in Flutter >=1.17 by passing
/// `--dart-define` flag to the `flutter run` or `flutter build`.
///
/// For example:
/// ```
/// flutter build --dart-define=BUILD_NUMBER=$BUILD_NUMBER --dart-define=BUILD_VERSION=$BUILD_VERSION --dart-define=BUILD_COMMIT=$FCI_COMMIT
/// ```
class PlatformBuildInfo extends BuildInfo {
  static const _prefsDeviceID = '_wiredashDeviceID';

  PlatformBuildInfo() {
    _getDeviceID();
  }

  static const _buildNumber = bool.hasEnvironment('BUILD_NUMBER')
      ? String.fromEnvironment('BUILD_NUMBER')
      : null;
  static const _buildVersion = bool.hasEnvironment('BUILD_VERSION')
      ? String.fromEnvironment('BUILD_VERSION')
      : null;
  static const _buildCommit = bool.hasEnvironment("BUILD_COMMIT")
      ? String.fromEnvironment('BUILD_COMMIT')
      : null;

  String _deviceId;

  @override
  String get buildCommit => _buildCommit;

  @override
  String get buildNumber => _buildNumber;

  @override
  String get buildVersion => _buildVersion;

  @override
  String get deviceId => _deviceId;

  Future<String> _getDeviceID() async {
    final prefs = await SharedPreferences.getInstance();
    String deviceId;

    if (prefs.containsKey(_prefsDeviceID)) {
      _deviceId = prefs.getString(_prefsDeviceID);
    } else {
      _deviceId = _generateUUIDV4();
      await prefs.setString(_prefsDeviceID, deviceId);
    }

    return deviceId;
  }

  static String _generateUUIDV4() {
    final random = math.Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));

    bytes[6] = (bytes[6] & 0x0F) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final chars = bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join()
        .toUpperCase();

    return '${chars.substring(0, 8)}-${chars.substring(8, 12)}-'
        '${chars.substring(12, 16)}-${chars.substring(16, 20)}-'
        '${chars.substring(20, 32)}';
  }
}
