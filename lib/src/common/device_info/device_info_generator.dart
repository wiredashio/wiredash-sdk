import 'dart:ui' as ui show Window;

import 'package:wiredash/src/common/build_info/build_info_manager.dart';
import 'package:wiredash/src/common/device_info/device_info.dart';

import 'device_info_generator_stub.dart'
    if (dart.library.html) 'dart_html_device_info_generator.dart'
    if (dart.library.io) 'dart_io_device_info_generator.dart';

abstract class DeviceInfoGenerator {
  factory DeviceInfoGenerator(
    BuildInfoManager buildInfo,
    ui.Window window,
  ) {
    return createDeviceInfoGenerator(buildInfo, window);
  }

  DeviceInfo generate();
}
