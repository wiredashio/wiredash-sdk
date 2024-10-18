// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/network/wiredash_api.dart';
import 'package:wiredash/src/core/version.dart';

Future<void> postSendEvents(
  ApiClientContext context,
  String url,
  List<RequestEvent> body,
) async {
  final uri = Uri.parse(url);
  final Request request = Request('POST', uri)
    ..headers.addAll({
      'Content-Type': 'application/json',
      'project': context.projectId,
      'secret': context.secret,
      'version': wiredashSdkVersion.toString(),
    })
    ..body = jsonEncode(body.map((e) => e.toRequestJson()).toList());

  final response = await context.send(request);
  if (response.statusCode == 200) {
    final warnings = response.readWiredashWarnings();
    final warning2003 = warnings.firstWhereOrNull((w) => w.code == 2003);
    if (warning2003 != null) {
      final plan = warning2003.data['plan'] as String?;
      throw PaidFeatureException(
        warning: warning2003,
        currentPlan: plan ?? 'free',
      );
    }

    context.reportResponseWarnings(response, (WiredashApiWarning warning) {
      if (warning.code == 2200) {
        final index = warning.data['index'] as int;
        final event = body[index];
        return InvalidEventFormatException(
          'Event "${event.eventName}" was rejected by the server due to an invalid format',
          event,
          warning,
        );
      }
      return null;
    });

    return;
  }

  final errorResponse = WiredashApiErrorResponse.tryParse(response);
  if (errorResponse != null) {
    if (response.statusCode == 400 && errorResponse.code == 2201) {
      // Events not processed, please resend
      throw CouldNotHandleRequestException(
        response: response,
        message: 'no event was saved on the server, retry at a later time',
      );
    }
  }

  context.throwApiError(response);
}

class InvalidEventFormatException implements Exception {
  final String message;
  final RequestEvent event;
  final WiredashApiWarning warning;

  InvalidEventFormatException(this.message, this.event, this.warning);

  @override
  String toString() {
    return 'InvalidEventFormatException{message: $message, event: $event, warning: $warning}';
  }
}

/// Thrown when using the API of a paid feature while the project is on a free plan
class PaidFeatureException implements Exception {
  final WiredashApiWarning warning;
  final String? currentPlan;

  PaidFeatureException({required this.warning, required this.currentPlan});

  @override
  String toString() {
    return 'PaidFeatureException: Custom events are only available in paid plans. '
        'Current plan: $currentPlan.\nServer response: $warning';
  }
}

class CouldNotHandleRequestException extends WiredashApiException {
  CouldNotHandleRequestException({
    required Response response,
    super.message,
  })  : assert(response.statusCode == 400),
        super(response: response);
}

class RequestEvent {
  final String analyticsId;
  final String? buildCommit;
  final String? buildNumber;
  final String? buildVersion;
  final String? bundleId;
  final DateTime? createdAt;
  final String? environment;
  final Map<String, Object?>? eventData;
  final String eventName;
  final String? platformOS;
  final String? platformOSVersion;
  final String? platformLocale;
  final int sdkVersion;

  RequestEvent({
    required this.analyticsId,
    this.buildCommit,
    this.buildNumber,
    this.buildVersion,
    this.bundleId,
    this.createdAt,
    this.environment,
    this.eventData,
    required this.eventName,
    this.platformOS,
    this.platformOSVersion,
    this.platformLocale,
    required this.sdkVersion,
  }) : assert(analyticsId.length >= 16);

  Map<String, Object> toRequestJson() {
    final Map<String, Object> body = {};

    body['analyticsId'] = analyticsId;

    final _buildCommit = buildCommit;
    if (_buildCommit != null) {
      body['buildCommit'] = _buildCommit;
    }

    final _buildNumber = buildNumber;
    if (_buildNumber != null) {
      body['buildNumber'] = _buildNumber;
    }

    final _buildVersion = buildVersion;
    if (_buildVersion != null) {
      body['buildVersion'] = _buildVersion;
    }

    final _bundleId = bundleId;
    if (_bundleId != null) {
      body['bundleId'] = _bundleId;
    }

    final _createdAt = createdAt;
    if (_createdAt != null) {
      final unixTimestamp = _createdAt.millisecondsSinceEpoch;
      body['createdAt'] = unixTimestamp;
    }

    final _environment = environment;
    if (_environment != null) {
      body['environment'] = _environment;
    }

    final _eventData = eventData;
    if (_eventData != null) {
      body['eventData'] = _eventData;
    }

    body['eventName'] = eventName;

    final _platformOS = platformOS;
    if (_platformOS != null) {
      body['platformOS'] = _platformOS;
    }

    final _platformOSVersion = platformOSVersion;
    if (_platformOSVersion != null) {
      body['platformOSVersion'] = _platformOSVersion;
    }

    final _platformLocale = platformLocale;
    if (_platformLocale != null) {
      body['platformLocale'] = _platformLocale;
    }

    body['sdkVersion'] = sdkVersion;

    return body;
  }

  @override
  String toString() {
    return 'RequestEvent{'
        '${toRequestJson()}'
        '}';
  }
}
