import 'dart:io';
// Replace with FlutterView when we drop support for Flutter v3.7.0-32.0.pre.
// ignore: deprecated_member_use
import 'dart:ui' show SingletonFlutterWindow;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/metadata/device_info/device_info.dart';
import 'package:wiredash/src/metadata/device_info/device_info_generator.dart';

class _DartIoDeviceInfoGenerator implements DeviceInfoCollector {
  _DartIoDeviceInfoGenerator(this.window);

  // Replace with FlutterView when we drop support for Flutter v3.7.0-32.0.pre.
  // ignore: deprecated_member_use
  final SingletonFlutterWindow window;

  @override
  Future<FlutterDeviceInfo> generate() async {
    final base = DeviceInfoCollector.flutterInfo(window);

    FlutterDeviceInfo info = base.copyWith(
      platformOS: Platform.operatingSystem,
      platformOSVersion: Platform.operatingSystemVersion,
      platformVersion: Platform.version,
    );

    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isMacOS) {
        final macosInfo = await deviceInfoPlugin.macOsInfo;
        info = info.copyWith(deviceModel: macosInfo.model);
        print(macosInfo.arch);
      }
      if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        info = info.copyWith(deviceModel: iosInfo.model);
      }
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        info = info.copyWith(deviceModel: androidInfo.model);
      }
      if (Platform.isWindows) {
        final windowsInfo = await deviceInfoPlugin.windowsInfo;
      }
      if (Platform.isLinux) {
        final linuxInfo = await deviceInfoPlugin.linuxInfo;
      }
    } catch (e, stack) {
      reportWiredashError(
        e,
        stack,
        'Failed to collect device info with device_info_plus',
      );
    }

    final packageInfo = await PackageInfo.fromPlatform();

    print("From packageInfo:");
    print(packageInfo);
    print("app name: ${packageInfo.appName}");
    print("package name: ${packageInfo.packageName}");
    print("version: ${packageInfo.version}");

    // TODO applicationID
    // TODO buildNumber
    // TODO app version
    // TODO device name

    return base;
  }
}

/// Called by [DeviceInfoCollector] factory constructor
// Replace with FlutterView when we drop support for Flutter v3.7.0-32.0.pre.
// ignore: deprecated_member_use
DeviceInfoCollector createDeviceInfoGenerator(SingletonFlutterWindow window) {
  return _DartIoDeviceInfoGenerator(window);
}
