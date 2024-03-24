import 'dart:isolate';

import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/version.dart';
import 'package:wiredash/src/core/wiredash_widget.dart';

// Required
// TODO validate event name and parameters
// TODO validate event key
// TODO don't allow # in the beginning
// TODO send first_launch event with # in beginning.
// TODO Use a fixed list of internal events that start with #
// TODO drop event if server responds 400 (code 2200) MISSING TEST
// TODO keep events if server responds 400 (code 2201) MISSING TEST
// TODO keep events for any other server error MISSING TEST
// TODO ignore corrupt events on disk (users might edit it on web)
// TODO allow white space in eventName
// TODO Write documentation

// Important
// TODO send events to server on app close
// TODO send events every 30 seconds to the server (or 5min?)
// TODO drop event when API credentials are obviously wrong
// TODO allow resetting of the analyticsId
// TODO send events directly on web
// TODO test InvalidEventFormatException with real server response

// Nice to have
// TODO allow triggering of event submission
// TODO write integration_test for isolates
// TODO automatically add page_name as property
// TODO check if WiredashRegistry instance could be saved in the zone

class WiredashAnalytics {
  /// Optional [projectId] in case multiple [Wiredash] widgets with different
  /// projectIds are used at the same time
  final String? projectId;

  WiredashAnalytics({
    this.projectId,
  });

  final WiredashServices _services = WiredashServices();

  Future<void> trackEvent(
    String eventName, {
    Map<String, Object?>? params,
  }) async {
    final fixedMetadata =
        await _services.metaDataCollector.collectFixedMetaData();
    final flutterInfo = _services.metaDataCollector.collectFlutterInfo();

    final event = AnalyticsEvent(
      analyticsId: await _services.wuidGenerator.appUsageId(),
      buildCommit: fixedMetadata.resolvedBuildCommit,
      buildNumber: fixedMetadata.resolvedBuildNumber,
      buildVersion: fixedMetadata.resolvedBuildVersion,
      bundleId: fixedMetadata.appInfo.bundleId,
      createdAt: clock.now(),
      eventData: params,
      eventName: eventName,
      platformOS: flutterInfo.platformOS,
      platformOSVersion: fixedMetadata.deviceInfo.osVersion,
      platformLocale: flutterInfo.platformLocale,
      sdkVersion: wiredashSdkVersion,
    );

    await _services.eventStore.saveEvent(event, projectId);
    await _notifyWiredashInstance(projectId, eventName);
  }

  Future<void> _notifyWiredashInstance(
    String? projectId,
    String eventName,
  ) async {
    final allWidget = WiredashRegistry.instance.allWidgets;
    if (allWidget.isEmpty) {
      // no Wiredash instance is running. Wait for next mount to send the event

      final bool isMainIsolate = Isolate.current.debugName == 'main';
      if (!isMainIsolate) {
        // The event will be picked up automatically by the main isolate,
        // when the next event is sent from the main isolate.
        return;
      }
      reportWiredashInfo(
        NoWiredashInstanceFoundException(),
        StackTrace.current,
        "No Wiredash widget is mounted. "
        "The event '$eventName' was captured but not yet submitted to the server. "
        "Please make sure to wrap your app with Wiredash. "
        "See https://docs.wiredash.com/guide/start",
      );

      return;
    }

    if (allWidget.length == 1) {
      final state = allWidget.first;
      if (projectId == null) {
        // notify the only registered Wiredash instance
        await state.newEventAdded();
        return;
      }

      final widget = state.widget;
      if (widget.projectId == projectId) {
        // projectId matches, notify the only and correct Wiredash instance
        await state.newEventAdded();
        return;
      }
      // The only registered Wiredash instance has a different projectId
      reportWiredashInfo(
        NoWiredashInstanceFoundException(),
        StackTrace.current,
        "Wiredash is registered with ${widget.projectId}. "
        "The event event '$eventName' was explicit sent to projectId $projectId. "
        "No Wiredash instance was found with projectId $projectId. "
        "Please double check the projectId.",
      );
      return;
    }
    assert(allWidget.length > 1, "Multiple Wiredash instances are mounted.");

    if (projectId == null) {
      final firstWidgetState = allWidget.first;

      final ids = allWidget.map((e) => e.widget.projectId).join(", ");
      reportWiredashInfo(
        NoProjectIdSpecifiedException(),
        StackTrace.current,
        "Multiple Wiredash instances with different projectIds are mounted ($ids). "
        "Please specify a projectId when using multiple Wiredash instances like this:\n"
        "    Wiredash.trackEvent('$eventName', projectId: 'your_project_id');\n"
        "    WiredashAnalytics(projectId: 'your_project_id').trackEvent('$eventName');\n"
        "    Wiredash.of(context).trackEvent('$eventName');\n"
        "The event '$eventName' was sent to project '${firstWidgetState.widget.projectId}', because that Wiredash widget was registered first.",
      );
      await firstWidgetState.newEventAdded();
      return;
    }

    final projectInstances = allWidget
        .where((element) => element.widget.projectId == projectId)
        .toList();
    if (projectInstances.isEmpty) {
      reportWiredashInfo(
        NoWiredashInstanceFoundException(),
        StackTrace.current,
        "No Wiredash instance was found with projectId $projectId. "
        "Please double check the projectId.",
      );
      return;
    } else {
      // multiple with the same projectId, take the first one
      await projectInstances.first.newEventAdded();
    }

    debugPrint(
      "Multiple Wiredash instances are mounted! "
      "Please specify a projectId to avoid sending events to all instances, "
      "or use Wiredash.of(context).trackEvent() to send events to a specific instance.",
    );
  }
}

Future<void> trackEvent(
  String eventName, {
  Map<String, Object?>? params,
  String? projectId,
}) async {
  final analytics = WiredashAnalytics(projectId: projectId);
  await analytics.trackEvent(eventName, params: params);
}

class AnalyticsEvent {
  final String analyticsId;
  final String? buildCommit;
  final String? buildNumber;
  final String? buildVersion;
  final String? bundleId;
  final DateTime? createdAt;
  final Map<String, Object?>? eventData;
  final String eventName;
  final String? platformOS;
  final String? platformOSVersion;
  final String? platformLocale;
  final int sdkVersion;

  const AnalyticsEvent({
    required this.analyticsId,
    this.buildCommit,
    this.buildNumber,
    this.buildVersion,
    this.bundleId,
    this.createdAt,
    this.eventData,
    required this.eventName,
    this.platformOS,
    this.platformOSVersion,
    this.platformLocale,
    required this.sdkVersion,
  });
}

class NoWiredashInstanceFoundException implements Exception {
  NoWiredashInstanceFoundException();
}

class NoProjectIdSpecifiedException implements Exception {
  NoProjectIdSpecifiedException();
}
