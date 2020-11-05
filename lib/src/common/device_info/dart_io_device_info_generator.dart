import 'dart:io';
import 'dart:ui' as ui show Window;

import 'package:wiredash/src/common/build_info/build_info_manager.dart';
import 'package:wiredash/src/common/device_info/base_device_info_generator.dart';
import 'package:wiredash/src/common/device_info/device_info_generator.dart';

class DartIoDeviceInfoGenerator extends BaseDeviceInfoGenerator {
  DartIoDeviceInfoGenerator(
    BuildInfoManager buildInfo,
    ui.Window window,
  ) : super(buildInfo, window);

  @override
  String get platformOS => Platform.operatingSystem;

  @override
  String get platformOSBuild => Platform.operatingSystemVersion;

  @override
  String get platformVersion => Platform.version;
}

DeviceInfoGenerator createDeviceInfoGenerator(
  BuildInfoManager buildInfo,
  ui.Window window,
) {
  return DartIoDeviceInfoGenerator(buildInfo, window);
}
