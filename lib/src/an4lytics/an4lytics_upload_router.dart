import 'package:flutter/widgets.dart';
import 'package:wiredash/src/an4lytics/an4lytics_isolate_message.dart';
import 'package:wiredash/src/core/services/error_report.dart';
import 'package:wiredash/src/core/wiredash_registry.dart';
import 'package:wiredash/src/core/wiredash_widget.dart';

/// Triggers the upload of pending events on the single mounted [Wiredash]
/// instance that matches [message], reporting a misconfiguration warning when
/// the target is ambiguous (multiple instances, or none with that project id).
///
/// Routing is by [AnalyticsIsolateMessage.projectId] only; the event keeps its
/// own [AnalyticsIsolateMessage.environment], so the chosen instance's
/// environment does not have to match. The environment and event name are only
/// used in the warning messages.
///
/// Picking one instance keeps batching efficient and avoids sending the same
/// event to multiple backends. Used both when an event is tracked on the main
/// isolate and when a background isolate wakes the main isolate, so both paths
/// route identically.
Future<void> notifyMatchingWiredashInstance(
  AnalyticsIsolateMessage message,
) async {
  final projectId = message.projectId;
  final environment = message.environment;
  final eventName = message.eventName;
  final submitImmediately = message.submitImmediately;
  final allWidget = WiredashRegistry.instance.allWidgets;
  if (allWidget.isEmpty) {
    reportWiredashInfo(
      NoWiredashInstanceFoundException(),
      StackTrace.current,
      "No Wiredash widget is mounted. "
      "The event '$eventName' (environment: $environment) was captured but not "
      "yet submitted to the server. "
      "Please make sure to wrap your app with Wiredash. "
      "See https://docs.wiredash.com/guide/start",
    );
    return;
  }

  if (allWidget.length == 1) {
    final WiredashState state = allWidget.first;
    final widget = state.widget;
    if (projectId == null || widget.projectId == projectId) {
      // projectId matches when set, notify the only and correct Wiredash
      // instance. The event keeps its own environment, so the instance's
      // environment does not have to match.
      await submitAnalyticsEvents(
        state,
        submitImmediately: submitImmediately,
      );
      return;
    }
    // The only registered Wiredash instance has a different projectId
    reportWiredashInfo(
      NoWiredashInstanceFoundException(),
      StackTrace.current,
      "Wiredash is registered with projectId:${widget.projectId}. "
      "The event '$eventName' was explicitly sent to projectId:$projectId. "
      "No Wiredash instance was found with projectId:$projectId. "
      "Please double check the projectId.",
    );
    return;
  }
  assert(allWidget.length > 1, "Multiple Wiredash instances are mounted.");

  if (projectId == null) {
    final firstWidgetState = allWidget.first;

    final ids = allWidget.map((e) {
      return "projectId:${e.widget.projectId}/environment:${e.widget.environment}";
    }).join(", ");
    reportWiredashInfo(
      NoProjectIdSpecifiedException(),
      StackTrace.current,
      "Multiple Wiredash instances with different projectIds are mounted ($ids). "
      "Please specify a projectId when using multiple Wiredash instances like this:\n"
      "    Wiredash.trackEvent('$eventName', projectId: 'your_project_id');\n"
      "    WiredashAnalytics(projectId: 'your_project_id').trackEvent('$eventName');\n"
      "    Wiredash.of(context).trackEvent('$eventName');\n"
      "The event '$eventName' was sent to project '${firstWidgetState.widget.projectId} "
      "because that Wiredash widget was registered first.",
    );
    await submitAnalyticsEvents(
      firstWidgetState,
      submitImmediately: submitImmediately,
    );
    return;
  }

  // Use the first matching Wiredash instance by projectId.
  final projectInstances = WiredashRegistry.instance.findByProjectId(projectId);
  if (projectInstances.isEmpty) {
    reportWiredashInfo(
      NoWiredashInstanceFoundException(),
      StackTrace.current,
      "No Wiredash instance was found with projectId:$projectId. "
      "Please double check the projectId.",
    );
    return;
  }
  // multiple with the same projectId, take the first one
  await submitAnalyticsEvents(
    projectInstances.first,
    submitImmediately: submitImmediately,
  );
  debugPrint(
    "Multiple Wiredash instances are mounted! "
    "Please specify a projectId to avoid sending events to all instances, "
    "or use Wiredash.of(context).trackEvent() to send events to a specific instance.",
  );
}

/// Reported when `WiredashAnalytics.trackEvent` runs but no [Wiredash] widget
/// is mounted.
///
/// This warning is only thrown on the main isolate, where the [Wiredash] widget
/// is expected to be always mounted.
class NoWiredashInstanceFoundException implements Exception {
  NoWiredashInstanceFoundException();
}

/// Reported when multiple [Wiredash] widgets with different projectIds are
/// mounted but [Wiredash.trackEvent] is called without a [projectId].
class NoProjectIdSpecifiedException implements Exception {
  NoProjectIdSpecifiedException();
}
