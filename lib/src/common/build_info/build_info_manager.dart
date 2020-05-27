import 'package:wiredash/src/common/utils/build_info.dart';
import 'package:wiredash/src/common/utils/device_info.dart';

class BuildInfoManager {
  BuildInfoManager() {
    DeviceInfo.getDeviceID().then((id) => deviceId = id);
  }

  String deviceId;
  String buildVersion = BuildInfo.buildVersion;
  String buildNumber = BuildInfo.buildNumber;
  String buildCommit = BuildInfo.buildCommit;
}
