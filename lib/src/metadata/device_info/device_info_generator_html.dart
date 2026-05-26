import 'package:web/web.dart' as web;
import 'package:wiredash/src/metadata/device_info/device_info.dart';
import 'package:wiredash/src/metadata/device_info/device_info_generator.dart';

class _DartHtmlDeviceInfoGenerator implements FlutterInfoCollector {
  _DartHtmlDeviceInfoGenerator();

  @override
  FlutterInfo capture() {
    final base = captureBaseFlutterInfo();
    return base.copyWith(
      userAgent: web.window.navigator.userAgent,
    );
  }
}

/// Called by [FlutterInfoCollector] factory constructor in browsers
FlutterInfoCollector createDeviceInfoGenerator() {
  return _DartHtmlDeviceInfoGenerator();
}
