import 'dart:ui' show FlutterView;

import 'package:wiredash/src/metadata/device_info/device_info_generator.dart';

FlutterInfoCollector createDeviceInfoGenerator(FlutterView? view) {
  throw UnsupportedError(
    'Cannot create a DeviceInfoCollector without dart:html or dart:io',
  );
}
