import 'dart:ui' show SingletonFlutterWindow;

import 'package:flutter/foundation.dart';
import 'package:wiredash/src/common/build_info/build_info_manager.dart';
import 'package:wiredash/src/common/device_info/device_info.dart';

// import a dart:html or dart:io version of `createDeviceInfoGenerator`
// if non are available the stub is used
import 'device_info_generator_stub.dart'
    if (dart.library.html) 'dart_html_device_info_generator.dart'
    if (dart.library.io) 'dart_io_device_info_generator.dart';

abstract class DeviceInfoGenerator {
  /// Loads a [DeviceInfoGenerator] based on the environment by calling the
  /// optional imported createDeviceInfoGenerator function
  factory DeviceInfoGenerator(
      BuildInfoManager buildInfo, SingletonFlutterWindow window) {
    return createDeviceInfoGenerator(buildInfo, window);
  }

  /// Collection of all [DeviceInfo] shared between all platforms
  static DeviceInfo baseDeviceInfo(
    BuildInfoManager buildInfo,
    SingletonFlutterWindow window,
  ) {
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
      textScaleFactor: window.textScaleFactor,
      viewInsets: [
        window.viewInsets.left,
        window.viewInsets.top,
        window.viewInsets.right,
        window.viewInsets.bottom
      ],
    );
  }

  DeviceInfo generate();
}
