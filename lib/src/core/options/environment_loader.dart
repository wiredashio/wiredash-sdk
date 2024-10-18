import 'package:flutter/foundation.dart';
import 'package:wiredash/src/core/wiredash_widget.dart';
import 'package:wiredash/src/metadata/meta_data_collector.dart';

/// Load the environment from the Wiredash widget and either uses it or falls
/// back to 'dev' or 'prod'
class EnvironmentLoader {
  EnvironmentLoader({
    required Wiredash Function() wiredashWidget,
    required MetaDataCollector Function() metaDataCollector,
  })  : _wiredashWidget = wiredashWidget,
        _metaDataCollector = metaDataCollector;

  final Wiredash Function() _wiredashWidget;
  final MetaDataCollector Function() _metaDataCollector;

  /// Returns [Wiredash.environment] if set, otherwise 'dev' or 'prod' depending on [kReleaseMode]
  Future<String> getEnvironment() async {
    final widgetEnv = _wiredashWidget().environment;

    if (widgetEnv != null) {
      assert(() {
        validateEnvironment(widgetEnv);
        return true;
      }());
      return widgetEnv;
    }

    if (await isDevEnvironment()) {
      return 'dev';
    }

    return 'prod';
  }

  /// Returns true when a non-production environment is detected
  Future<bool> isDevEnvironment() async {
    if (!kReleaseMode) {
      // debug and profile builds are always considered dev
      return true;
    }

    final fixedMetaData = await _metaDataCollector().collectFixedMetaData();
    if (fixedMetaData.deviceInfo.isPhysicalDevice == false) {
      // running on an emulator or simulator is considered dev
      return true;
    }

    return false;
  }
}
