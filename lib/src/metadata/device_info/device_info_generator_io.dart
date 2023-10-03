import 'dart:io';
// Replace with FlutterView when we drop support for Flutter v3.7.0-32.0.pre.
// ignore: deprecated_member_use
import 'dart:ui' show SingletonFlutterWindow;

import 'package:wiredash/src/metadata/device_info/device_info.dart';
import 'package:wiredash/src/metadata/device_info/device_info_generator.dart';

class _DartIoDeviceInfoGenerator implements DeviceInfoGenerator {
  _DartIoDeviceInfoGenerator(this.window);

  // Replace with FlutterView when we drop support for Flutter v3.7.0-32.0.pre.
  // ignore: deprecated_member_use
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
// Replace with FlutterView when we drop support for Flutter v3.7.0-32.0.pre.
// ignore: deprecated_member_use
DeviceInfoGenerator createDeviceInfoGenerator(SingletonFlutterWindow window) {
  return _DartIoDeviceInfoGenerator(window);
}
