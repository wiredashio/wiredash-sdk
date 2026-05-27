import 'dart:io';

import 'package:wiredash/src/metadata/device_info/device_info.dart';
import 'package:wiredash/src/metadata/device_info/device_info_generator.dart';

class _DartIoDeviceInfoGenerator implements FlutterInfoCollector {
  _DartIoDeviceInfoGenerator();

  @override
  FlutterInfo capture() {
    final base = captureBaseFlutterInfo();
    final info = base.copyWith(
      platformOS: Platform.operatingSystem,
      platformVersion: Platform.version,
    );
    return info;
  }
}

/// Called by [FlutterInfoCollector] factory constructor
FlutterInfoCollector createDeviceInfoGenerator() {
  return _DartIoDeviceInfoGenerator();
}
