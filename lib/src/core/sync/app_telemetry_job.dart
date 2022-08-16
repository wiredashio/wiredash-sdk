import 'package:wiredash/src/core/sync/sync_engine.dart';
import 'package:wiredash/src/core/telemetry/app_telemetry.dart';

class AppTelemetryJob extends Job {
  AppTelemetryJob({
    required this.telemetry,
  });

  final AppTelemetry telemetry;

  @override
  bool shouldExecute(SdkEvent event) {
    return event == SdkEvent.appStart;
  }

  @override
  Future<void> execute() async {
    await telemetry.onAppStart();
  }
}
