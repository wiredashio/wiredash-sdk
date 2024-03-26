import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/analytics/event_submitter.dart';
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
    return [
      SdkEvent.appStartDelayed,
      SdkEvent.appMovedToBackground,
    ].contains(event);
  }

  @override
  Future<void> execute(SdkEvent event) async {
    if (event == SdkEvent.appMovedToBackground) {
      // in case the app gets killed (which happens fast after this event),
      // do not run the job half-way
      await Future.delayed(const Duration(seconds: 1));
    }
    final submitter = eventSubmitter();
    await submitter.submitEvents();
  }
}
