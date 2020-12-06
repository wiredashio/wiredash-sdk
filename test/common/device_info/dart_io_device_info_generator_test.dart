// Import the test package and Counter class
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wiredash/src/common/build_info/build_info_manager.dart';
import 'package:wiredash/src/common/device_info/device_info_generator.dart';
import 'package:wiredash/src/common/utils/build_info.dart';

class MockBuildInfo extends Mock implements BuildInfo {}

void main() {
  group("DartIoDeviceInfoGenerator", () {
    final mockBuildInfo = MockBuildInfo();

    test("doesn't return build information if build properties not set", () {
      final generator =
          DeviceInfoGenerator(BuildInfoManager(mockBuildInfo), ui.window);
      final info = generator.generate();
      expect(info.buildNumber, null);
      expect(info.appVersion, null);
      expect(info.buildCommit, null);
      expect(info.deviceId, null);
    });

    test("returns build information if build properties are set", () {
      when(mockBuildInfo.buildCommit).thenReturn('commit');
      when(mockBuildInfo.buildNumber).thenReturn('42');
      when(mockBuildInfo.buildVersion).thenReturn('1.42');
      when(mockBuildInfo.deviceId).thenReturn('deviceId');
      final generator = DeviceInfoGenerator(
        BuildInfoManager(mockBuildInfo),
        ui.window,
      );
      final info = generator.generate();
      assert(info != null);
      expect(info.buildNumber, '42');
      expect(info.appVersion, '1.42');
      expect(info.buildCommit, 'commit');
      expect(info.deviceId, 'deviceId');
    });
  });
}
