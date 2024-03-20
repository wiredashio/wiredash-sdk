import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/version.dart';
import 'package:wiredash/src/core/wiredash_widget.dart';

// Prio #1
// TODO how to handle when two instances of the app, with two different wiredash configurations are open. Where would events be sent to?
// TODO send events every 30 seconds to the server (or 5min?)
// TODO send events to server on app close
// TODO wipe events older than 3 days (missing test)
// TODO validate event name and parameters
// TODO implement Wiredash.of(context).method()
// TODO validate event key
// TODO send first_launch event with # in beginning.
// TODO don't allow # in the beginning
// TODO drop event if server responds 400 (code 2200)
// TODO keep events if server responds 400 (code 2201)
// TODO keep events for any other server error
// TODO allow white space in eventName
// TODO drop event when API credentials are obviously wrong
// TODO allow resetting of the analyticsId
// TODO allow triggering of event submission
// TODO automatically add page_name as property

// Nice to have
// TODO write integration_test for isolates
// TODO send events directly on web

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
    print('Tracking event $eventName');

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
    await _notifyWiredashInstance(projectId);
  }

  Future<void> _notifyWiredashInstance(String? projectId) async {
    if (projectId != null) {
      // Inform correct Wiredash instance about event
      final state = WiredashRegistry.findByProjectId(projectId);
      if (state != null) {
        await state.newEventAdded();
      } else {
        // widget not found, it will upload the event when mounted the next time
      }
      return;
    }

    // Forward default events to the only Wiredash instance that is running
    final activeWiredashInstances = WiredashRegistry.referenceCount;
    if (activeWiredashInstances == 0) {
      // no Wiredash instance is running. Wait for next mount to send the event
      return;
    }
    if (activeWiredashInstances == 1) {
      // found a single Wiredash instance, notify about the new event
      await WiredashRegistry.forEach((wiredashState) async {
        await wiredashState.newEventAdded();
      });
      return;
    }

    assert(
    activeWiredashInstances > 1,
    "Expect multiple Wiredash instances to be running.",
    );
    assert(projectId == null, "No projectId defined");
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

// TODO write documentation with these examples
void main() async {
  final BuildContext context = RootElement(const RootWidget());

  // plain arguments
  await trackEvent('test_event', params: {'param1': 'value1'});

  // Event object
  // final event = Event(name: 'test_event', params: {'param1': 'value1'});
  // await trackEvent2(event);

  // WiredashAnalytics instance
  final analytics = WiredashAnalytics();
  await analytics.trackEvent('test_event', params: {'param1': 'value1'});

  // state instance method (will always work)
  await Wiredash.of(context)
      .trackEvent('test_event', params: {'param1': 'value1'});

  await trackEvent('test_event', params: {'param1': 'value1'});
}
