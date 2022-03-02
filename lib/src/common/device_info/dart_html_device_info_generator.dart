// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;
import 'dart:ui' show SingletonFlutterWindow;

import 'package:wiredash/src/common/device_info/device_info.dart';
import 'package:wiredash/src/common/device_info/device_info_generator.dart';

class _DartHtmlDeviceInfoGenerator implements DeviceInfoGenerator {
  _DartHtmlDeviceInfoGenerator(this.window);

  final SingletonFlutterWindow window;

  @override
  FlutterDeviceInfo generate() {
    final base = DeviceInfoGenerator.baseDeviceInfo(window);
    return base.copyWith(
      userAgent: html.window.navigator.userAgent,
    );
  }
}

/// Called by [DeviceInfoGenerator] factory constructor in browsers
DeviceInfoGenerator createDeviceInfoGenerator(SingletonFlutterWindow window) {
  return _DartHtmlDeviceInfoGenerator(window);
}
