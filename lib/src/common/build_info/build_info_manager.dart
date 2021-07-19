import 'package:wiredash/src/common/build_info/build_info.dart';

/// Allows overriding of statically defined values
class BuildInfoManager {
  BuildInfoManager();

  String? buildVersionOverride;

  String? buildNumberOverride;

  /// Returns the aggregated build info from compile-time env and overrides
  BuildInfo get buildInfo {
    return BuildInfo(
      buildVersion: buildVersionOverride ?? EnvBuildInfo.buildVersion,
      buildNumber: buildNumberOverride ?? EnvBuildInfo.buildNumber,
      buildCommit: EnvBuildInfo.buildCommit,
    );
  }
}
