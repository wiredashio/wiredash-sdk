import 'package:wiredash/src/common/utils/build_info.dart';

class BuildInfoManager {
  final BuildInfo buildInfo;
  BuildInfoManager(this.buildInfo);

  String get deviceId => buildInfo.deviceId;

  String _buildVersion;
  String get buildVersion => _buildVersion ?? buildInfo.buildVersion;
  set buildVersion(String s) => _buildVersion = s;

  String _buildNumber;
  String get buildNumber => _buildNumber ?? buildInfo.buildNumber;
  set buildNumber(String s) => _buildNumber = s;

  String get buildCommit => buildInfo.buildCommit;
}
