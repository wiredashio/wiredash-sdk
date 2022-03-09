import 'dart:ui' show SingletonFlutterWindow;

import 'package:wiredash/src/metadata/device_info/device_info_generator.dart';

DeviceInfoGenerator createDeviceInfoGenerator(SingletonFlutterWindow window) {
  throw UnsupportedError(
    'Cannot create a Device Info Generator without dart:html or dart:io',
  );
}
