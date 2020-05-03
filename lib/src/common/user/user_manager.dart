import 'package:wiredash/src/common/utils/device_info.dart';

class UserManager {
  UserManager() {
    DeviceInfo.getDeviceID().then((id) => deviceId = id);
  }

  String appVersion;
  String deviceId;
  String userId;
  String userEmail;

  Map<String, dynamic> get deviceInfo =>
      DeviceInfo.generate(appVersion, deviceId);
}
