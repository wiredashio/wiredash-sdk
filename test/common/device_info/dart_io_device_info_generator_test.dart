// Import the test package and Counter class
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:wiredash/src/common/build_info/build_info_manager.dart';
import 'package:wiredash/src/common/device_info/device_info_generator.dart';
import 'package:wiredash/src/common/utils/build_info.dart';

class _BuildInfoDataClass implements BuildInfo {
  @override
  final String? buildCommit;

  @override
  final String? buildNumber;

  @override
  final String? buildVersion;

  @override
  final String? deviceId;

  _BuildInfoDataClass(
      {this.buildCommit, this.buildNumber, this.buildVersion, this.deviceId});
}

void main() {
  group("DartIoDeviceInfoGenerator", () {
    test("doesn't return build information if build properties not set", () {
      final nullInfo = _BuildInfoDataClass();
      final generator =
          DeviceInfoGenerator(BuildInfoManager(nullInfo), ui.window);
      final info = generator.generate();
      expect(info.buildNumber, null);
      expect(info.appVersion, null);
      expect(info.buildCommit, null);
      expect(info.deviceId, null);
    });

    test("returns build information if build properties are set", () {
      final info = _BuildInfoDataClass(
        buildCommit: 'commit',
        buildNumber: '42',
        buildVersion: '1.42',
        deviceId: 'deviceId',
      );
      final generator = DeviceInfoGenerator(
        BuildInfoManager(info),
        ui.window,
      );
      final parsed = generator.generate();
      expect(parsed.buildNumber, '42');
      expect(parsed.appVersion, '1.42');
      expect(parsed.buildCommit, 'commit');
      expect(parsed.deviceId, 'deviceId');
    });
  });
}
