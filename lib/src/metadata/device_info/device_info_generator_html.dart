import 'dart:ui' show FlutterView;

import 'package:web/web.dart' as web;
import 'package:wiredash/src/metadata/device_info/device_info.dart';
import 'package:wiredash/src/metadata/device_info/device_info_generator.dart';

class _DartHtmlDeviceInfoGenerator implements FlutterInfoCollector {
  _DartHtmlDeviceInfoGenerator(this.view);

  final FlutterView? view;

  @override
  FlutterInfo capture() {
    final base = FlutterInfoCollector.flutterInfo(view);
    return base.copyWith(
      userAgent: web.window.navigator.userAgent,
    );
  }
}

/// Called by [FlutterInfoCollector] factory constructor in browsers
FlutterInfoCollector createDeviceInfoGenerator(FlutterView? view) {
  return _DartHtmlDeviceInfoGenerator(view);
}
