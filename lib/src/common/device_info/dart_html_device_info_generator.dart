// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;
import 'dart:ui' show SingletonFlutterWindow;

import 'package:wiredash/src/common/build_info/build_info_manager.dart';
import 'package:wiredash/src/common/device_info/device_info.dart';
import 'package:wiredash/src/common/device_info/device_info_generator.dart';

class _DartHtmlDeviceInfoGenerator implements DeviceInfoGenerator {
  _DartHtmlDeviceInfoGenerator(
    this.buildInfo,
    this.window,
  );

  final BuildInfoManager buildInfo;
  final SingletonFlutterWindow window;

  @override
  DeviceInfo generate() {
    final base = DeviceInfoGenerator.baseDeviceInfo(buildInfo, window);
    return base.copyWith(
      userAgent: html.window.navigator.userAgent,
    );
  }
}

/// Called by [DeviceInfoGenerator] factory constructor in browsers
DeviceInfoGenerator createDeviceInfoGenerator(
    BuildInfoManager buildInfo, SingletonFlutterWindow window) {
  return _DartHtmlDeviceInfoGenerator(buildInfo, window);
}
