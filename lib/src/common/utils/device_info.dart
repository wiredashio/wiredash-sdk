import 'dart:io';
import 'dart:ui' as ui show window;

import 'package:wiredash/src/common/build_info/build_info_manager.dart';

class DeviceInfo {
  static Map<String, dynamic> generate(BuildInfoManager buildInfo) {
    final Map<String, dynamic> uiValues = {};

    uiValues['appIsDebug'] = _isInDebugMode();

    if (buildInfo.buildVersion != null) {
      uiValues['appVersion'] = buildInfo.buildVersion;
    }
    if (buildInfo.buildNumber != null) {
      uiValues['buildNumber'] = buildInfo.buildNumber;
    }
    if (buildInfo.buildCommit != null) {
      uiValues['buildCommit'] = buildInfo.buildCommit;
    }
    if (buildInfo.deviceId != null) {
      uiValues['deviceId'] = buildInfo.deviceId;
    }

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
}
