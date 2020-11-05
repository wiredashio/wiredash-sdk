import 'dart:ui' as ui show Window;

import 'package:flutter/foundation.dart';
import 'package:wiredash/src/common/build_info/build_info_manager.dart';
import 'package:wiredash/src/common/device_info/device_info.dart';
import 'package:wiredash/src/common/device_info/device_info_generator.dart';

abstract class BaseDeviceInfoGenerator implements DeviceInfoGenerator {
  final BuildInfoManager buildInfo;
  final ui.Window window;

  BaseDeviceInfoGenerator(
    this.buildInfo,
    this.window,
  );

  @override
  DeviceInfo generate() {
    return DeviceInfo(
      appIsDebug: kDebugMode,
      appVersion: buildInfo.buildVersion,
      buildNumber: buildInfo.buildNumber,
      buildCommit: buildInfo.buildCommit,
      deviceId: buildInfo.deviceId,
      locale: window.locale.toString(),
      padding: [
        window.padding.left,
        window.padding.top,
        window.padding.right,
        window.padding.bottom
      ],
      physicalSize: [window.physicalSize.width, window.physicalSize.height],
      pixelRatio: window.devicePixelRatio,
      platformOS: platformOS,
      platformOSBuild: platformOSBuild,
      platformVersion: platformVersion,
      textScaleFactor: window.textScaleFactor,
      viewInsets: [
        window.viewInsets.left,
        window.viewInsets.top,
        window.viewInsets.right,
        window.viewInsets.bottom
      ],
    );
  }

  String get platformOS;
  String get platformOSBuild;
  String get platformVersion;
}
