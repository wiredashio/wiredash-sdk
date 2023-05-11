// Replace with FlutterView when we drop support for Flutter v3.7.0-32.0.pre.
// ignore: deprecated_member_use
import 'dart:ui' show SingletonFlutterWindow;

import 'package:wiredash/src/metadata/device_info/device_info_generator.dart';

// Replace with FlutterView when we drop support for Flutter v3.7.0-32.0.pre.
// ignore: deprecated_member_use
DeviceInfoGenerator createDeviceInfoGenerator(SingletonFlutterWindow window) {
  throw UnsupportedError(
    'Cannot create a Device Info Generator without dart:html or dart:io',
  );
}
