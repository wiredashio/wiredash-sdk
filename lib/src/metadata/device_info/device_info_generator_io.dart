import 'dart:io';
import 'dart:ui' show FlutterView;

import 'package:wiredash/src/metadata/device_info/device_info.dart';
import 'package:wiredash/src/metadata/device_info/device_info_generator.dart';

class _DartIoDeviceInfoGenerator implements FlutterInfoCollector {
  _DartIoDeviceInfoGenerator(this.view);

  final FlutterView? view;

  @override
  FlutterInfo capture() {
    final base = FlutterInfoCollector.flutterInfo(view);
    final info = base.copyWith(
      platformOS: Platform.operatingSystem,
      platformVersion: Platform.version,
    );
    return info;
  }
}

/// Called by [FlutterInfoCollector] factory constructor
FlutterInfoCollector createDeviceInfoGenerator(FlutterView? view) {
  return _DartIoDeviceInfoGenerator(view);
}
