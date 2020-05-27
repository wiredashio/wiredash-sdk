// Import the test package and Counter class
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wiredash/src/common/build_info/build_info_manager.dart';
import 'package:wiredash/src/common/utils/build_info.dart';
import 'package:wiredash/src/common/utils/device_info.dart';

class MockBuildInfo extends Mock implements BuildInfo {}

void main() {
  group("DeviceInfo ", () {
    final mockBuildInfo = MockBuildInfo();
    test("doesn't return build information if build properties not set", () {
      final info = DeviceInfo.generate(BuildInfoManager(mockBuildInfo));
      assert(info != null);
      expect(info.containsKey('buildNumber'), false);
      expect(info.containsKey('appVersion'), false);
      expect(info.containsKey('buildCommit'), false);
      expect(info.containsKey('deviceId'), false);
    });

    test("returns build information if build properties are set", () {
      when(mockBuildInfo.buildCommit).thenReturn('commit');
      when(mockBuildInfo.buildNumber).thenReturn('42');
      when(mockBuildInfo.buildVersion).thenReturn('1.42');
      when(mockBuildInfo.deviceId).thenReturn('deviceId');
      final info = DeviceInfo.generate(BuildInfoManager(mockBuildInfo));
      assert(info != null);
      expect(info.containsKey('buildNumber'), true);
      expect(info['buildNumber'], '42');
      expect(info.containsKey('appVersion'), true);
      expect(info['appVersion'], '1.42');
      expect(info.containsKey('buildCommit'), true);
      expect(info['buildCommit'], 'commit');
      expect(info.containsKey('deviceId'), true);
      expect(info['deviceId'], 'deviceId');
    });
  });
}
