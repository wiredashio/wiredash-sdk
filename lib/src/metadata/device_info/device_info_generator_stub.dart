import 'package:wiredash/src/metadata/device_info/device_info_generator.dart';

FlutterInfoCollector createDeviceInfoGenerator() {
  throw UnsupportedError(
    'Cannot create a DeviceInfoCollector without dart:html or dart:io',
  );
}
