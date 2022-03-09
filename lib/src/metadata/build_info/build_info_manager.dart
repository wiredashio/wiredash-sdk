import 'package:flutter/foundation.dart';
import 'package:wiredash/src/metadata/build_info/build_info.dart';

class BuildInfoManager {
  BuildInfoManager();

  /// Returns the aggregated build info from compile-time env
  BuildInfo get buildInfo {
    return BuildInfo(
      compilationMode: () {
        if (kDebugMode) return CompilationMode.debug;
        if (kProfileMode) return CompilationMode.profile;
        return CompilationMode.release;
      }(),
      buildVersion: EnvBuildInfo.buildVersion,
      buildNumber: EnvBuildInfo.buildNumber,
      buildCommit: EnvBuildInfo.buildCommit,
    );
  }
}
