import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/analytics/analytics.dart';
import 'package:wiredash/src/core/sync/sync_engine.dart';

class EventUploadJob extends Job {
  final Future<SharedPreferences> Function() sharedPreferencesProvider;
  final EventSubmitter Function() eventSubmitter;

  EventUploadJob({
    required this.sharedPreferencesProvider,
    required this.eventSubmitter,
  });

  @override
  bool shouldExecute(SdkEvent event) {
    return event == SdkEvent.appStartDelayed;
  }

  @override
  Future<void> execute() async {
    final submitter = eventSubmitter();
    await submitter.submitEvents();
  }
}
