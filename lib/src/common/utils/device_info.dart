import 'dart:io';
import 'dart:math' show Random;
import 'dart:ui' as ui show window;

import 'package:shared_preferences/shared_preferences.dart';

class DeviceInfo {
  static const _prefsDeviceID = 'deviceID';

  static Map<String, dynamic> generate(String appVersion, String deviceId) {
    final Map<String, dynamic> uiValues = {};

    uiValues['appIsDebug'] = _isInDebugMode();
    if (appVersion != null) uiValues['appVersion'] = appVersion;
    if (deviceId != null) uiValues['deviceId'] = deviceId;
    uiValues['locale'] = ui.window.locale.toString();
    uiValues['padding'] = [
      ui.window.padding.left,
      ui.window.padding.top,
      ui.window.padding.right,
      ui.window.padding.bottom
    ];
    uiValues['physicalSize'] = [
      ui.window.physicalSize.width,
      ui.window.physicalSize.height
    ];
    uiValues['pixelRatio'] = ui.window.devicePixelRatio;
    uiValues['platformOS'] = Platform.operatingSystem;
    uiValues['platformOSBuild'] = Platform.operatingSystemVersion;
    uiValues['platformVersion'] = Platform.version;
    uiValues['textScaleFactor'] = ui.window.textScaleFactor;
    uiValues['viewInsets'] = [
      ui.window.viewInsets.left,
      ui.window.viewInsets.top,
      ui.window.viewInsets.right,
      ui.window.viewInsets.bottom
    ];

    return uiValues;
  }

  static bool _isInDebugMode() {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  static Future<String> getDeviceID() async {
    final prefs = await SharedPreferences.getInstance();
    String deviceId;

    if (prefs.containsKey(_prefsDeviceID)) {
      deviceId = prefs.getString(_prefsDeviceID);
    } else {
      deviceId = _generateUUIDV4();
      await prefs.setString(_prefsDeviceID, deviceId);
    }

    return deviceId;
  }

  static String _generateUUIDV4() {
    final random = Random.secure();
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
