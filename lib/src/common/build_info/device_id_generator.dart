import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/common/utils/uuid.dart';

/// Generates a unique id per device and app install
class DeviceIdGenerator {
  static const _prefsDeviceID = '_wiredashDeviceID';

  /// Returns the unique deviceId for this device/app combination
  ///
  /// The Future is cached and returns very fast
  final Future<String> deviceId;

  DeviceIdGenerator() : deviceId = _loadDeviceID();

  static Future<String> _loadDeviceID() async {
    String? _deviceId;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_prefsDeviceID)) {
      final saved = prefs.getString(_prefsDeviceID);
      if (saved != null) {
        return saved;
      }
    }
    _deviceId = uuidV4.generate();
    await prefs.setString(_prefsDeviceID, _deviceId);
    return _deviceId;
  }
}
