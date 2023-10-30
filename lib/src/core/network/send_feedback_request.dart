// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'dart:ui';

import 'package:http/http.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/version.dart';
import 'package:wiredash/src/feedback/data/feedback_item.dart';

Future<void> postSendFeedback(
  ApiClientContext context,
  String url,
  FeedbackItem feedback,
) async {
  final uri = Uri.parse(url);
  final Request request = Request('POST', uri);

  request.headers.addAll({
    'Content-Type': 'application/json',
    'project': context.projectId,
    'secret': context.projectId,
    'version': wiredashSdkVersion.toString(),
  });

  final body = feedback.toRequestJson();
  request.body = jsonEncode(body);

  final response = await context.send(request);
  if (response.statusCode == 200) {
    // success 🎉
    return;
  }
  context.parseResponseForErrors(response);
}

extension FeedbackBody on FeedbackItem {
  Map<String, dynamic> toRequestJson() {
    final Map<String, Object> values = {};

    // Values are sorted alphabetically for easy comparison with the backend
    final appLocale = sessionMetadata.appLocale;
    if (appLocale != null) {
      values.addAll({'appLocale': appLocale});
    }

    final appName = appInfo.appName;
    if (appName != null) {
      values.addAll({'appName': appName});
    }

    if (attachments.isNotEmpty) {
      final items = attachments.map((it) {
        if (it is Screenshot) {
          return it.toJson();
        } else {
          throw "Unsupported attachment type ${it.runtimeType}";
        }
      }).toList();
      values.addAll({'attachments': items});
    }

    final buildCommit = this.buildInfo.buildCommit;
    if (buildCommit != null) {
      values.addAll({'buildCommit': buildCommit});
    }

    final buildNumber = this.buildInfo.buildNumber;
    if (buildNumber != null) {
      values.addAll({'buildNumber': buildNumber});
    }

    final buildVersion = this.buildInfo.buildVersion;
    if (buildVersion != null) {
      values.addAll({'buildVersion': buildVersion});
    }

    final bundleId = appInfo.bundleId;
    if (bundleId != null) {
      values.addAll({'bundleId': bundleId});
    }

    values.addAll({
      'compilationMode': nonNull(this.buildInfo.compilationMode).jsonEncode(),
    });

    final customMetaData = sessionMetadata.custom.map((key, value) {
      if (value == null) {
        return MapEntry(key, null);
      }
      try {
        // try encoding. We don't care about the actual encoded content because
        // it will be later by the http library encoded
        jsonEncode(value);
        // encoding worked, it's valid data
        return MapEntry(key, value);
      } catch (e, stack) {
        reportWiredashError(
          e,
          stack,
          'Could not serialize customMetaData property '
          '$key=$value',
        );
        return MapEntry(key, null);
      }
    });
    customMetaData.removeWhere((key, value) => value == null);
    if (customMetaData.isNotEmpty) {
      values.addAll({'customMetaData': customMetaData});
    }

    values.addAll({'deviceId': nonNull(deviceId)});

    final deviceModel = deviceInfo.deviceModel;
    if (deviceModel != null) {
      values.addAll({'deviceModel': deviceModel});
    }

    final _labels = labels;
    if (_labels != null) {
      values.addAll({'labels': _labels});
    }

    values.addAll({'message': nonNull(message)});

    values.addAll({
      'physicalGeometry': nonNull(flutterInfo.physicalGeometry).toJson(),
    });

    values.addAll({
      'platformBrightness':
          nonNull(flutterInfo.platformBrightness).jsonEncode(),
    });

    final platformDartVersion = flutterInfo.platformVersion;
    if (platformDartVersion != null) {
      values.addAll({'platformDartVersion': platformDartVersion});
    }

    values.addAll({
      'platformGestureInsets': nonNull(flutterInfo.gestureInsets).toJson(),
    });

    values.addAll({'platformLocale': nonNull(flutterInfo.platformLocale)});

    final platformOS = flutterInfo.platformOS;
    if (platformOS != null) {
      values.addAll({'platformOS': platformOS});
    }

    final platformOSVersion = flutterInfo.platformOSVersion;
    if (platformOSVersion != null) {
      values.addAll({'platformOSVersion': platformOSVersion});
    }

    values.addAll({
      'platformSupportedLocales': nonNull(flutterInfo.platformSupportedLocales),
    });

    // Web only
    final platformUserAgent = flutterInfo.userAgent;
    if (platformUserAgent != null) {
      values.addAll({'platformUserAgent': platformUserAgent});
    }

    values.addAll({'sdkVersion': nonNull(sdkVersion)});

    final userEmail = email;
    if (userEmail != null && userEmail.isNotEmpty) {
      values.addAll({'userEmail': userEmail});
    }

    final String? userId = sessionMetadata.userId;
    if (userId != null) {
      values.addAll({'userId': userId});
    }

    values.addAll({
      'windowInsets': nonNull(flutterInfo.viewInsets).toJson(),
    });

    values.addAll({
      'windowPadding': nonNull(flutterInfo.padding).toJson(),
    });

    values.addAll({
      'windowPixelRatio': nonNull(flutterInfo.pixelRatio),
    });

    values.addAll({
      'windowSize': nonNull(flutterInfo.physicalSize).toJson(),
    });

    values.addAll({
      'windowTextScaleFactor': nonNull(flutterInfo.textScaleFactor),
    });

    return values.map((k, v) => MapEntry(k, v));
  }
}

extension on Screenshot {
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> values = {
      'id': file.attachmentId!.value,
    };

    return values;
  }
}

// Remove when we drop support for Flutter v3.8.0-14.0.pre.
// ignore: deprecated_member_use
extension on WindowPadding {
  List<double> toJson() {
    return [left, top, right, bottom];
  }
}

extension on Rect {
  List<double> toJson() {
    return [left, top, right, bottom];
  }
}

extension on Size {
  List<double> toJson() {
    return [width, height];
  }
}

extension on Brightness {
  String jsonEncode() {
    if (this == Brightness.dark) return 'dark';
    if (this == Brightness.light) return 'light';
    throw 'Unknown brightness value $this';
  }
}

extension on CompilationMode {
  String jsonEncode() {
    switch (this) {
      case CompilationMode.release:
        return 'release';
      case CompilationMode.profile:
        return 'profile';
      case CompilationMode.debug:
        return 'debug';
    }
  }
}

/// Explicitly defines a values a non null, making it a compile time error
/// when [value] becomes nullable
///
/// This prevents accidental null values here that may happen due to refactoring
T nonNull<T extends Object>(T value) {
  return value;
}
