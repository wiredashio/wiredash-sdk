import 'package:wiredash/src/common/utils/build_info.dart';

class BuildInfoManager {
  final BuildInfo buildInfo;
  BuildInfoManager(this.buildInfo);

  String? get deviceId => buildInfo.deviceId;

  String? _buildVersion;
  String? get buildVersion => _buildVersion ?? buildInfo.buildVersion;
  set buildVersion(String? version) => _buildVersion = version;

  String? _buildNumber;
  String? get buildNumber => _buildNumber ?? buildInfo.buildNumber;
  set buildNumber(String? number) => _buildNumber = number;

  String? get buildCommit => buildInfo.buildCommit;
}
