import 'dart:convert';

import 'package:http/http.dart';
import 'package:wiredash/src/_ps.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/version.dart';

Future<void> postSendPromoterScore(
  ApiClientContext context,
  String url,
  PromoterScoreRequestBody body,
) async {
  final Request request = Request('POST', Uri.parse(url));

  request.headers.addAll({
    'Content-Type': 'application/json',
    'project': context.projectId,
    'secret': context.secret,
    'version': wiredashSdkVersion.toString(),
  });

  final args = body.toRequestJson();
  request.body = jsonEncode(args);

  final response = await context.send(request);
  if (response.statusCode == 200) {
    // success 🎉
    return;
  }
  context.throwApiError(response);
}

class PromoterScoreRequestBody {
  const PromoterScoreRequestBody({
    this.appLocale,
    required this.appInfo,
    required this.deviceId,
    this.message,
    required this.question,
    this.platformLocale,
    this.platformOS,
    this.platformOSVersion,
    this.platformUserAgent,
    this.score,
    required this.sdkVersion,
    this.userEmail,
    this.userId,
    required this.buildInfo,
  });

  final String? appLocale;
  final AppInfo appInfo;
  final BuildInfo buildInfo;
  final String deviceId;
  final String? message;
  final String question;
  final String? platformLocale;
  final String? platformOS;
  final String? platformOSVersion;
  final String? platformUserAgent;
  final PromoterScoreRating? score;
  final int sdkVersion;
  final String? userEmail;
  final String? userId;

  Map<String, Object> toRequestJson() {
    final Map<String, Object> body = {};

    if (appLocale != null) {
      body['appLocale'] = appLocale!;
    }

    final buildCommit = buildInfo.buildCommit;
    if (buildCommit != null) {
      body.addAll({'buildCommit': buildCommit});
    }

    final buildNumber = buildInfo.buildNumber;
    if (buildNumber != null) {
      body.addAll({'buildNumber': buildNumber});
    }

    final buildVersion = buildInfo.buildVersion;
    if (buildVersion != null) {
      body.addAll({'buildVersion': buildVersion});
    }

    body['deviceId'] = deviceId;

    if (message != null && message!.isNotEmpty) {
      body['message'] = message!;
    }

    if (platformLocale != null) {
      body['platformLocale'] = platformLocale!;
    }

    if (platformOS != null) {
      body['platformOS'] = platformOS!;
    }
    if (platformOSVersion != null) {
      body['platformOSVersion'] = platformOSVersion!;
    }

    if (platformUserAgent != null) {
      body['platformUserAgent'] = platformUserAgent!;
    }

    body['question'] = question;

    if (score != null) {
      body['score'] = score!.intValue;
    }

    body['sdkVersion'] = sdkVersion;

    if (userEmail != null) {
      body['userEmail'] = userEmail!;
    }

    if (userId != null) {
      body['userId'] = userId!;
    }

    return body;
  }
}
