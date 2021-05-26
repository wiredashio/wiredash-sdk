import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/common/utils/uuid.dart';

abstract class BuildInfo {
  String? get buildNumber;
  String? get buildVersion;
  String? get buildCommit;
  String? get deviceId;
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
    _loadDeviceID();
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

  String? _deviceId;

  @override
  String? get buildCommit => _buildCommit;

  @override
  String? get buildNumber => _buildNumber;

  @override
  String? get buildVersion => _buildVersion;

  @override
  String? get deviceId => _deviceId;

  Future<void> _loadDeviceID() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_prefsDeviceID)) {
      _deviceId = prefs.getString(_prefsDeviceID);
    } else {
      _deviceId = uuidV4.generate();
      await prefs.setString(_prefsDeviceID, _deviceId!);
    }
  }
}
