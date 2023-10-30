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
      // TODO double check if version or sdkVersion
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
  final String installId;
  final String? appVersion;
  final String? buildNumber;
  final String? buildCommit;
  final String? bundleId;
  final String? platformOS;
  final String? platformVersion;
  final String? platformLocale;

  PingRequestBody({
    required this.installId,
    this.appVersion,
    this.buildNumber,
    this.buildCommit,
    this.bundleId,
    this.platformOS,
    this.platformVersion,
    this.platformLocale,
  });

  Map<String, Object> toRequestJson() {
    final Map<String, Object> body = {};

    final _appVersion = appVersion;
    if (_appVersion != null) {
      body['appVersion'] = _appVersion;
    }

    final _buildNumber = buildNumber;
    if (_buildNumber != null) {
      body['buildNumber'] = _buildNumber;
    }

    final _buildCommit = buildCommit;
    if (_buildCommit != null) {
      body['buildCommit'] = _buildCommit;
    }

    final _bundleId = bundleId;
    if (_bundleId != null) {
      body['bundleId'] = _bundleId;
    }

    body['installId'] = installId;

    final _platformOS = platformOS;
    if (_platformOS != null) {
      body['platformOS'] = _platformOS;
    }

    final _platformVersion = platformVersion;
    if (_platformVersion != null) {
      body['platformVersion'] = _platformVersion;
    }

    final _platformLocale = platformLocale;
    if (_platformLocale != null) {
      body['platformLocale'] = _platformLocale;
    }

    return body;
  }
}

class PingResponse {
  // Nothing in here just yet but that will change in the future
  PingResponse();
}
