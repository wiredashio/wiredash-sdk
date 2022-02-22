import 'dart:io';
import 'dart:ui' show SingletonFlutterWindow;

import 'package:wiredash/src/common/device_info/device_info.dart';
import 'package:wiredash/src/common/device_info/device_info_generator.dart';

class _DartIoDeviceInfoGenerator implements DeviceInfoGenerator {
  _DartIoDeviceInfoGenerator(this.window);

  final SingletonFlutterWindow window;

  @override
  FlutterDeviceInfo generate() {
    final base = DeviceInfoGenerator.baseDeviceInfo(window);
    return base.copyWith(
      platformOS: Platform.operatingSystem,
      platformOSVersion: Platform.operatingSystemVersion,
      platformVersion: Platform.version,
    );
  }
}

/// Called by [DeviceInfoGenerator] factory constructor
DeviceInfoGenerator createDeviceInfoGenerator(SingletonFlutterWindow window) {
  return _DartIoDeviceInfoGenerator(window);
}
