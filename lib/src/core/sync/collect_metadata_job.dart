import 'package:wiredash/src/core/sync/sync_engine.dart';
import 'package:wiredash/src/metadata/meta_data_collector.dart';

// TODO sill needed?
class CollectMetaDataJob extends Job {
  CollectMetaDataJob({required this.metaDataCollector});

  final MetaDataCollector metaDataCollector;

  @override
  Future<void> execute() async {
    await metaDataCollector.collectFixedMetaData();
  }

  @override
  bool shouldExecute(SdkEvent event) {
    if (event == SdkEvent.appStart) {
      return true;
    }
    return false;
  }
}
