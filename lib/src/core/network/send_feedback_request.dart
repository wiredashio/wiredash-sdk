// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:collection';
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
  context.throwApiError(response);
}

extension FeedbackBody on FeedbackItem {
  Map<String, dynamic> toRequestJson() {
    final Map<String, Object> values = {};

    // Values are sorted alphabetically for easy comparison with the backend
    if (attachments != null && attachments!.isNotEmpty) {
      final items = attachments!.map((it) {
        if (it is Screenshot) {
          return it.toJson();
        } else {
          throw "Unsupported attachment type ${it.runtimeType}";
        }
      }).toList();
      values.addAll({'attachments': items});
    }

    final _labels = labels;
    if (_labels != null) {
      values.addAll({'labels': _labels});
    }

    values.addAll({'message': nonNull(message)});

    values.addAll({'metadata': metadata.toJson()});

    return values.map((k, v) => MapEntry(k, v));
  }
}

extension AllMetaDataToJson on AllMetaData {
  Map<String, Object?> toJson() {
    final Map<String, Object> values = SplayTreeMap.from({});

    // Values are sorted alphabetically for easy comparison with the backend
    final _appLocale = appLocale;
    if (_appLocale != null) {
      values.addAll({'appLocale': _appLocale});
    }

    final _appName = appName;
    if (_appName != null) {
      values.addAll({'appName': _appName});
    }

    final _buildCommit = buildCommit;
    if (_buildCommit != null) {
      values.addAll({'buildCommit': _buildCommit});
    }

    final _buildNumber = buildNumber;
    if (_buildNumber != null) {
      values.addAll({'buildNumber': _buildNumber});
    }

    final _buildVersion = buildVersion;
    if (_buildVersion != null) {
      values.addAll({'buildVersion': _buildVersion});
    }

    final _bundleId = bundleId;
    if (_bundleId != null) {
      values.addAll({'bundleId': _bundleId});
    }

    values.addAll({
      'compilationMode': nonNull(compilationMode.jsonEncode()),
    });

    final customMetaData = custom?.map((key, value) {
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
    if (customMetaData != null) {
      customMetaData.removeWhere((key, value) => value == null);
      if (customMetaData.isNotEmpty) {
        values.addAll({'custom': customMetaData});
      }
    }

    values.addAll({'installId': nonNull(installId)});

    final _deviceModel = deviceModel;
    if (_deviceModel != null) {
      values.addAll({'deviceModel': _deviceModel});
    }

    values.addAll({
      'physicalGeometry': nonNull(physicalGeometry).toJson(),
    });

    values.addAll({
      'platformBrightness': nonNull(platformBrightness).jsonEncode(),
    });

    final _platformDartVersion = platformDartVersion;
    if (_platformDartVersion != null) {
      values.addAll({'platformDartVersion': _platformDartVersion});
    }

    values.addAll({
      'platformGestureInsets': nonNull(platformGestureInsets).toJson(),
    });

    values.addAll({'platformLocale': nonNull(platformLocale)});

    final _platformOS = platformOS;
    if (_platformOS != null) {
      values.addAll({'platformOS': _platformOS});
    }

    final _platformOSVersion = platformOSVersion;
    if (_platformOSVersion != null) {
      values.addAll({'platformOSVersion': _platformOSVersion});
    }

    values.addAll({
      'platformSupportedLocales': nonNull(platformSupportedLocales),
    });

    values.addAll({'sdkVersion': nonNull(sdkVersion)});

    final _userEmail = userEmail;
    if (_userEmail != null && _userEmail.isNotEmpty) {
      values.addAll({'userEmail': _userEmail});
    }

    final String? _userId = userId;
    if (_userId != null) {
      values.addAll({'userId': _userId});
    }

    values.addAll({
      'windowInsets': nonNull(windowInsets).toJson(),
    });

    values.addAll({
      'windowPadding': nonNull(windowPadding).toJson(),
    });

    values.addAll({
      'windowPixelRatio': nonNull(windowPixelRatio),
    });

    values.addAll({
      'windowSize': nonNull(windowSize).toJson(),
    });

    values.addAll({
      'windowTextScaleFactor': nonNull(windowTextScaleFactor),
    });

    return values.map((k, v) => MapEntry(k, v));
  }
}

extension on Screenshot {
  Map<String, Object> toJson() {
    return {
      'id': file.attachmentId!.value,
    };
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
