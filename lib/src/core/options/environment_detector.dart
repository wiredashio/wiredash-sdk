import 'package:wiredash/src/core/wiredash_widget.dart';
import 'package:wiredash/src/metadata/build_info/build_info.dart';
import 'package:wiredash/src/metadata/meta_data_collector.dart';

/// Evaluates the environment from the [Wiredash] widget or falls back to 'dev' or 'prod'
class EnvironmentDetector {
  EnvironmentDetector({
    required Wiredash? Function() wiredashWidget,
    required MetaDataCollector Function() metaDataCollector,
    required BuildInfo Function() buildInfoProvider,
  })  : _wiredashWidget = wiredashWidget,
        _metaDataCollector = metaDataCollector,
        _buildInfoProvider = buildInfoProvider;

  final Wiredash? Function() _wiredashWidget;
  final MetaDataCollector Function() _metaDataCollector;
  final BuildInfo Function() _buildInfoProvider;

  /// Returns the environment from the Wiredash widget or falls back to 'dev' or 'prod'
  Future<String> getEnvironment() async {
    final widgetEnv = _wiredashWidget()?.environment;
    if (widgetEnv != null) {
      return widgetEnv;
    }

    final buildInfo = _buildInfoProvider();
    if (buildInfo.compilationMode != CompilationMode.release) {
      // dev and profile modes are non-production environments
      return 'dev';
    }

    final fixedMetaData = await _metaDataCollector().collectFixedMetaData();
    if (fixedMetaData.deviceInfo.isPhysicalDevice == false) {
      // running on an emulator or simulator is considered a non-production environment
      return 'dev';
    }

    return 'prod';
  }
}
