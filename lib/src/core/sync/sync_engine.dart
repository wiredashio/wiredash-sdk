import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:wiredash/src/_wiredash_internal.dart';

const _kSyncDebugPrint = kDevMode;

void syncDebugPrint(Object? message) {
  if (_kSyncDebugPrint) {
    debugPrint(message?.toString());
  }
}

/// Events that are triggered by the user that can be used to trigger registered
/// [Job]s.
enum SdkEvent {
  /// User launched the app that is wrapped in Wiredash
  appStart,

  /// Slightly delayed compared to [appStart] but it is better for the users
  /// app startup performance.
  appStartDelayed,

  /// User opened the Wiredash UI
  openedWiredash,

  /// User submitted feedback. It might not yet be delivered to the backend but the task is completed by the user
  submittedFeedback,

  /// User submitted the NPS
  submittedNps,
}

/// Executes sync jobs with the network at certain times
///
/// Add a new job with [addJob] and it will execute when your
/// [Job.shouldExecute] returns `true`.
class SyncEngine {
  SyncEngine();

  Timer? _initTimer;

  final Map<String, Job> _jobs = {};

  bool get _mounted => _initTimer != null;

  /// Adds a job to be executed for certain [SdkEvent] events.
  ///
  /// See [removeJob] to remove the job.
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

  /// Removes a jobs that was previously registered with [addJob].
  Job? removeJob(String name) {
    final job = _jobs.remove(name);
    if (job == null) {
      return null;
    }
    job._name = null;
    return job;
  }

  /// Called when the SDK is initialized (by wrapping the app)
  ///
  /// Triggers [SdkEvent.appStart] after the app settled down.
  Future<void> onWiredashInit() async {
    assert(
      () {
        if (_initTimer != null) {
          debugPrint("Warning: called onWiredashInitialized multiple times");
        }
        return true;
      }(),
    );

    final bool? hasBeenStarted = Zone.current['wiredash:appStart'] as bool?;
    if (hasBeenStarted == true) {
      return;
    }
    // Delay app start a bit, so that Wiredash doesn't slow down the app start
    _initTimer?.cancel();
    _initTimer = Timer(const Duration(seconds: 5), () {
      _triggerEvent(SdkEvent.appStartDelayed);
    });

    _triggerEvent(SdkEvent.appStart);
  }

  /// Shuts down the sync engine because wiredash is not part of the widget tree
  /// anymore
  void onWiredashDispose() {
    _initTimer?.cancel();
    _initTimer = null;
  }

  Future<void> onUserOpenedWiredash() async {
    await _triggerEvent(SdkEvent.openedWiredash);
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

/// A job that will be executed by [SyncEngine] when [shouldExecute] matches a
/// triggered [SdkEvent]
abstract class Job {
  String get name => _name ?? 'unnamed';
  String? _name;

  bool shouldExecute(SdkEvent event);

  Future<void> execute();
}
