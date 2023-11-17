// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';

import 'package:http/http.dart';
import 'package:wiredash/src/core/network/wiredash_api.dart';
import 'package:wiredash/src/core/version.dart';

Future<PingResponse> postPing(
  ApiClientContext context,
  String url,
  PingRequestBody body,
) async {
  final uri = Uri.parse(url);
  final Request request = Request('POST', uri)
    ..headers.addAll({
      'Content-Type': 'application/json',
      'project': context.projectId,
      'secret': context.secret,
      'version': wiredashSdkVersion.toString(),
    })
    ..body = jsonEncode(body.toRequestJson());

  final response = await context.send(request);
  if (response.statusCode == 200) {
    return PingResponse();
  }
  context.throwApiError(response);
}

class PingRequestBody {
  final String analyticsId;
  final String? buildCommit;
  final String? buildNumber;
  final String? buildVersion;
  final String? bundleId;
  final String? platformOS;
  final String? platformOSVersion;
  final String? platformLocale;
  final int sdkVersion;

  PingRequestBody({
    required this.analyticsId,
    this.buildCommit,
    this.buildNumber,
    this.buildVersion,
    this.bundleId,
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
}

class PingResponse {
  // Nothing in here just yet but that will change in the future
  PingResponse();
}
