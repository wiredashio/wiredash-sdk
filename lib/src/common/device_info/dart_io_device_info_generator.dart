import 'dart:io';
import 'dart:ui' as ui show Window;

import 'package:wiredash/src/common/build_info/build_info_manager.dart';
import 'package:wiredash/src/common/device_info/device_info.dart';
import 'package:wiredash/src/common/device_info/device_info_generator.dart';

class _DartIoDeviceInfoGenerator implements DeviceInfoGenerator {
  _DartIoDeviceInfoGenerator(
    this.buildInfo,
    this.window,
  );

  final BuildInfoManager buildInfo;
  final ui.Window window;

  @override
  DeviceInfo generate() {
    final base = DeviceInfoGenerator.baseDeviceInfo(buildInfo, window);
    return base.copyWith(
      platformOS: Platform.operatingSystem,
      platformOSVersion: Platform.operatingSystemVersion,
      dartVersion: Platform.version,
    );
  }
}

/// Called by [DeviceInfoGenerator] factory constructor
DeviceInfoGenerator createDeviceInfoGenerator(
    BuildInfoManager buildInfo, ui.Window window) {
  return _DartIoDeviceInfoGenerator(buildInfo, window);
}
