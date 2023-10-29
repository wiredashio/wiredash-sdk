import 'dart:io';
// Replace with FlutterView when we drop support for Flutter v3.7.0-32.0.pre.
// ignore: deprecated_member_use
import 'dart:ui' show SingletonFlutterWindow;

import 'package:wiredash/src/metadata/device_info/device_info.dart';
import 'package:wiredash/src/metadata/device_info/device_info_generator.dart';

class _DartIoDeviceInfoGenerator implements FlutterInfoCollector {
  _DartIoDeviceInfoGenerator(this.window);

  // Replace with FlutterView when we drop support for Flutter v3.7.0-32.0.pre.
  // ignore: deprecated_member_use
  final SingletonFlutterWindow window;

  @override
  Future<FlutterInfo> generate() async {
    final base = FlutterInfoCollector.flutterInfo(window);
    final info = base.copyWith(
      platformOS: Platform.operatingSystem,
      platformOSVersion: Platform.operatingSystemVersion,
      platformVersion: Platform.version,
    );
    return info;
  }
}

/// Called by [FlutterInfoCollector] factory constructor
// Replace with FlutterView when we drop support for Flutter v3.7.0-32.0.pre.
// ignore: deprecated_member_use
FlutterInfoCollector createDeviceInfoGenerator(SingletonFlutterWindow window) {
  return _DartIoDeviceInfoGenerator(window);
}
