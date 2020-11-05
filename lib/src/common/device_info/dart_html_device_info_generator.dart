// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;
import 'dart:ui' as ui show Window;

import 'package:wiredash/src/common/build_info/build_info_manager.dart';
import 'package:wiredash/src/common/device_info/base_device_info_generator.dart';
import 'package:wiredash/src/common/device_info/device_info_generator.dart';
import 'package:wiredash/src/common/device_info/user_agent_parser.dart';

class DartHtmlDeviceInfoGenerator extends BaseDeviceInfoGenerator {
  DartHtmlDeviceInfoGenerator(
    BuildInfoManager buildInfo,
    ui.Window window,
  ) : super(buildInfo, window);

  @override
  String get platformOS => _parser.browserName;

  @override
  String get platformOSBuild => _parser.browserVersion;

  @override
  String get platformVersion => html.window.navigator.userAgent;

  UserAgentParser get _parser =>
      UserAgentParser(html.window.navigator.userAgent);
}

DeviceInfoGenerator createDeviceInfoGenerator(
  BuildInfoManager buildInfo,
  ui.Window window,
) {
  return DartHtmlDeviceInfoGenerator(buildInfo, window);
}
