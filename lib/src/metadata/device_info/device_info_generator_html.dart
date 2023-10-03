// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;
// Replace with FlutterView when we drop support for Flutter v3.7.0-32.0.pre.
// ignore: deprecated_member_use
import 'dart:ui' show SingletonFlutterWindow;

import 'package:wiredash/src/metadata/device_info/device_info.dart';
import 'package:wiredash/src/metadata/device_info/device_info_generator.dart';

class _DartHtmlDeviceInfoGenerator implements DeviceInfoGenerator {
  _DartHtmlDeviceInfoGenerator(this.window);

  // Replace with FlutterView when we drop support for Flutter v3.7.0-32.0.pre.
  // ignore: deprecated_member_use
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
// Replace with FlutterView when we drop support for Flutter v3.7.0-32.0.pre.
// ignore: deprecated_member_use
DeviceInfoGenerator createDeviceInfoGenerator(SingletonFlutterWindow window) {
  return _DartHtmlDeviceInfoGenerator(window);
}
