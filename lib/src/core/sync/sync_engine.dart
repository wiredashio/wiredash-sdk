import 'dart:async';

import 'package:flutter/cupertino.dart';

const _kSyncDebugPrint = true;

void syncDebugPrint(Object? message) {
  if (_kSyncDebugPrint) {
    debugPrint(message?.toString());
  }
}

enum SdkEvent {
  appStart,
  openedWiredash,
  submittedFeedback,
  submittedNps,
}

/// Executes sync jobs with the network at certain times
class SyncEngine {
  SyncEngine();

  Timer? _initTimer;

  static const minSyncGap = Duration(hours: 3);

  static const lastSuccessfulPingKey = 'io.wiredash.last_successful_ping';
  static const lastFeedbackSubmissionKey =
      'io.wiredash.last_feedback_submission';
  static const silenceUntilKey = 'io.wiredash.silence_until';
  static const latestMessageIdKey = 'io.wiredash.latest_message_id';

  final Map<String, Job> _jobs = {};

  bool get _mounted => _initTimer != null;

  /// Adds a job to be executed at the right time
  void addJob(
    String name,
    Job job,
  ) {
    if (job._name != null) {
      throw 'Job already has a name (${job._name}), cannot add it ($name) twice';
    }
    job._name = name;
    _jobs[name] = job;
    syncDebugPrint('Added job $name (${job.runtimeType})');
  }

  /// Called when the SDK is initialized (by wrapping the app)
  ///
  /// Triggers [SdkEvent.appStart] after the app settled down.
  Future<void> onWiredashInit() async {
    assert(() {
      if (_initTimer != null) {
        debugPrint("Warning: called onWiredashInitialized multiple times");
      }
      return true;
    }());

    // Delay app start a bit, so that Wiredash doesn't slow down the app start
    _initTimer?.cancel();
    _initTimer = Timer(const Duration(seconds: 5), () {
      _triggerEvent(SdkEvent.appStart);
    });
  }

  /// Shuts down the sync engine because wiredash is not part of the widget tree
  /// anymore
  void onWiredashDispose() {
    _initTimer?.cancel();
    _initTimer = null;
  }

  /// Called when the user manually opened Wiredash
  ///
  /// This 100% calls the backend, forcing a sync
  Future<void> onUserOpenedWiredash() async {
    await _triggerEvent(SdkEvent.appStart);
  }

  Future<void> onSubmitFeedback() async {
    await _triggerEvent(SdkEvent.submittedFeedback);
  }

  Future<void> onSubmitNPS() async {
    await _triggerEvent(SdkEvent.submittedNps);
  }

  /// Executes all jobs that are listening to the given event
  Future<void> _triggerEvent(SdkEvent event) async {
    for (final job in _jobs.values) {
      if (!_mounted) {
        // stop sync operation, Wiredash was removed from the widget tree
        syncDebugPrint('cancelling job execution for event $event');
        break;
      }
      try {
        if (job.shouldExecute(event)) {
          syncDebugPrint('Executing job ${job._name}');
          await job.execute();
        }
      } catch (e, stack) {
        debugPrint('Error executing job ${job._name}:\n$e\n$stack');
      }
    }
  }
}

abstract class Job {
  String get name => _name ?? 'unnamed';
  String? _name;

  bool shouldExecute(SdkEvent event);

  Future<void> execute();
}
