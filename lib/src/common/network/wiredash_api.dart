import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:wiredash/src/common/utils/error_report.dart';
import 'package:wiredash/src/feedback/data/persisted_feedback_item.dart';
import 'package:wiredash/src/version.dart';

/// API client to communicate with the Wiredash servers
class WiredashApi {
  WiredashApi({
    required Client httpClient,
    required String projectId,
    required String secret,
    required Future<String> Function() deviceIdProvider,
  })  : _httpClient = httpClient,
        _projectId = projectId,
        _secret = secret,
        _deviceIdProvider = deviceIdProvider;

  final Client _httpClient;

  final String _projectId;
  final String _secret;
  final Future<String> Function() _deviceIdProvider;

  static const String _host = 'https://api.wiredash.io/sdk';

  // static const String _host = 'https://api.wiredash.dev/sdk';

  /// Uploads a attachment to the Wiredash hosting service
  ///
  /// POST /uploadAttachment
  Future<AttachmentId> uploadAttachment({
    required Uint8List screenshot,
    required AttachmentType type,
    String? filename,
    MediaType? contentType,
  }) async {
    final uri = Uri.parse('$_host/uploadAttachment');

    final String mappedType;
    switch (type) {
      case AttachmentType.screenshot:
        mappedType = 'screenshot';
        break;
    }

    final req = MultipartRequest('POST', uri)
      ..files.add(
        MultipartFile.fromBytes(
          'file',
          screenshot,
          filename: filename,
          contentType: contentType,
        ),
      )
      ..fields.addAll({
        'type': mappedType,
      });

    final response = await _send(req);

    if (response.statusCode == 401) {
      throw UnauthenticatedWiredashApiException(response, _projectId, _secret);
    }

    if (response.statusCode != 200) {
      throw WiredashApiException(
        message: 'screenshot upload failed',
        response: response,
      );
    }

    final map = jsonDecode(response.body) as Map<String, dynamic>;
    return AttachmentId(map['id'] as String);
  }

  /// Reports a feedback
  ///
  /// POST /sendFeedback
  Future<void> sendFeedback(
    PersistedFeedbackItem feedback,
  ) async {
    final uri = Uri.parse('$_host/sendFeedback');
    final Request request = Request('POST', uri);
    request.headers['Content-Type'] = 'application/json';

    final args = feedback.toFeedbackBody();
    request.body = jsonEncode(args);

    final response = await _send(request);
    if (response.statusCode == 200) {
      // success 🎉
      return;
    }
    if (response.statusCode == 401) {
      throw UnauthenticatedWiredashApiException(response, _projectId, _secret);
    }
    throw WiredashApiException(
      message: 'submitting feedback failed',
      response: response,
    );
  }

  /// Sends a [BaseRequest] after attaching HTTP headers
  Future<Response> _send(BaseRequest request) async {
    request.headers['project'] = _projectId;
    request.headers['secret'] = _secret;
    request.headers['device'] = await _deviceIdProvider();
    request.headers['version'] = wiredashSdkVersion.toString();

    final streamedResponse = await _httpClient.send(request);
    return Response.fromStream(streamedResponse);
  }
}

extension UploadScreenshotApi on WiredashApi {
  /// Uploads an screenshot to the Wiredash image hosting, returning a unique
  /// [AttachmentId]
  Future<AttachmentId> uploadScreenshot(Uint8List screenshot) {
    return uploadAttachment(
      screenshot: screenshot,
      type: AttachmentType.screenshot,
      filename: 'Screenshot_${DateTime.now().toUtc().toIso8601String()}',
      contentType: MediaType('image', 'png'),
    );
  }
}

/// Generic error from the Wiredash API
class WiredashApiException implements Exception {
  WiredashApiException({this.message, this.response});

  String? get messageFromServer {
    try {
      final json = jsonDecode(response?.body ?? '') as Map?;
      return json?['message'] as String?;
    } catch (e) {
      return response?.body;
    }
  }

  final String? message;
  final Response? response;

  @override
  String toString() {
    return 'WiredashApiException{'
        '"$message", '
        'code: ${response?.statusCode}, '
        'resp: $messageFromServer'
        '}';
  }
}

/// Thrown when the server couldn't match the project + secret to a existing
/// project
class UnauthenticatedWiredashApiException extends WiredashApiException {
  UnauthenticatedWiredashApiException(
    Response response,
    this.projectId,
    this.secret,
  ) : super(
          message: "Unknown projectId:'$projectId' or invalid secret:'$secret'",
          response: response,
        );

  final String projectId;
  final String secret;

  @override
  String toString() {
    return 'UnauthenticatedWiredashApiException{'
        '$message, '
        'status code: ${response?.statusCode}, '
        '${response?.body}'
        '}';
  }
}

extension FeedbackBody on PersistedFeedbackItem {
  Map<String, dynamic> toFeedbackBody() {
    final Map<String, Object> values = {};

    // Required values
    values.addAll({
      'appLocale': nonNull(appInfo.appLocale),
      'compilationMode': nonNull(buildInfo.compilationMode).jsonEncode(),
      'deviceId': nonNull(deviceId),
      'message': nonNull(message),
      'platformBrightness': nonNull(deviceInfo.platformBrightness).jsonEncode(),
      'platformLocale': nonNull(deviceInfo.platformLocale),
      'platformSupportedLocales': nonNull(deviceInfo.platformSupportedLocales),
      'sdkVersion': nonNull(sdkVersion),
    });

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

    final buildCommit = buildInfo.buildCommit;
    if (buildCommit != null) {
      values.addAll({'buildCommit': buildCommit});
    }

    final buildNumber = buildInfo.buildNumber;
    if (buildNumber != null) {
      values.addAll({'buildNumber': buildNumber});
    }

    final buildVersion = buildInfo.buildVersion;
    if (buildVersion != null) {
      values.addAll({'buildVersion': buildVersion});
    }

    final _labels = labels;
    if (_labels != null) {
      values.addAll({'labels': _labels});
    }

    final platformDartVersion = deviceInfo.platformVersion;
    if (platformDartVersion != null) {
      values.addAll({'platformDartVersion': platformDartVersion});
    }

    final platformOS = deviceInfo.platformOS;
    if (platformOS != null) {
      values.addAll({'platformOS': platformOS});
    }

    final platformOSVersion = deviceInfo.platformOSVersion;
    if (platformOSVersion != null) {
      values.addAll({'platformOSVersion': platformOSVersion});
    }

    // Web only
    final platformUserAgent = deviceInfo.userAgent;
    if (platformUserAgent != null) {
      values.addAll({'platformUserAgent': platformUserAgent});
    }

    final userEmail = email;
    if (userEmail != null && userEmail.isNotEmpty) {
      values.addAll({'userEmail': userEmail});
    }

    final String? _userId = userId;
    if (_userId != null) {
      values.addAll({'userId': _userId});
    }

    final _customMetaData = customMetaData?.map((key, value) {
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
          '$key=${value.toString()}',
        );
        return MapEntry(key, null);
      }
    });
    if (_customMetaData != null) {
      _customMetaData.removeWhere((key, value) => value == null);
      if (_customMetaData.isNotEmpty) {
        values.addAll({'customMetaData': _customMetaData});
      }
    }

    return values.map((k, v) => MapEntry(k, v));
  }
}

/// Explicitly defines a values a non null, making it a compile time error
/// when [value] becomes nullable
///
/// This prevents accidental null values here that may happen due to refactoring
T nonNull<T extends Object>(T value) {
  return value;
}

enum AttachmentType {
  screenshot,
}

class ScreenshotDeviceInfo {
  final Rect physicalGeometry;
  final Brightness platformBrightness;
  final WindowPadding platformGestureInsets;
  final WindowPadding windowInsets;
  final WindowPadding windowPadding;
  final double windowPixelRatio;
  final Size windowSize;
  final double windowTextScaleFactor;

//<editor-fold desc="Data Methods">

  const ScreenshotDeviceInfo({
    required this.physicalGeometry,
    required this.platformBrightness,
    required this.platformGestureInsets,
    required this.windowInsets,
    required this.windowPadding,
    required this.windowPixelRatio,
    required this.windowSize,
    required this.windowTextScaleFactor,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScreenshotDeviceInfo &&
          runtimeType == other.runtimeType &&
          physicalGeometry == other.physicalGeometry &&
          platformBrightness == other.platformBrightness &&
          platformGestureInsets == other.platformGestureInsets &&
          windowInsets == other.windowInsets &&
          windowPadding == other.windowPadding &&
          windowPixelRatio == other.windowPixelRatio &&
          windowSize == other.windowSize &&
          windowTextScaleFactor == other.windowTextScaleFactor);

  @override
  int get hashCode =>
      physicalGeometry.hashCode ^
      platformBrightness.hashCode ^
      platformGestureInsets.hashCode ^
      windowInsets.hashCode ^
      windowPadding.hashCode ^
      windowPixelRatio.hashCode ^
      windowSize.hashCode ^
      windowTextScaleFactor.hashCode;

  @override
  String toString() {
    return 'ScreenshotDeviceInfo{'
        'physicalGeometry: $physicalGeometry, '
        'platformBrightness: $platformBrightness, '
        'platformGestureInsets: $platformGestureInsets, '
        'windowInsets: $windowInsets, '
        'windowPadding: $windowPadding, '
        'windowPixelRatio: $windowPixelRatio, '
        'windowSize: $windowSize, '
        'windowTextScaleFactor: $windowTextScaleFactor, '
        '}';
  }

  ScreenshotDeviceInfo copyWith({
    Rect? physicalGeometry,
    Brightness? platformBrightness,
    WindowPadding? platformGestureInsets,
    WindowPadding? windowInsets,
    WindowPadding? windowPadding,
    double? windowPixelRatio,
    Size? windowSize,
    double? windowTextScaleFactor,
  }) {
    return ScreenshotDeviceInfo(
      physicalGeometry: physicalGeometry ?? this.physicalGeometry,
      platformBrightness: platformBrightness ?? this.platformBrightness,
      platformGestureInsets:
          platformGestureInsets ?? this.platformGestureInsets,
      windowInsets: windowInsets ?? this.windowInsets,
      windowPadding: windowPadding ?? this.windowPadding,
      windowPixelRatio: windowPixelRatio ?? this.windowPixelRatio,
      windowSize: windowSize ?? this.windowSize,
      windowTextScaleFactor:
          windowTextScaleFactor ?? this.windowTextScaleFactor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'physicalGeometry': nonNull(physicalGeometry).toJson(),
      'platformBrightness': nonNull(platformBrightness).jsonEncode(),
      'platformGestureInsets': nonNull(platformGestureInsets).toJson(),
      'windowInsets': nonNull(windowInsets).toJson(),
      'windowPadding': nonNull(windowPadding).toJson(),
      'windowPixelRatio': nonNull(windowPixelRatio),
      'windowSize': nonNull(windowSize).toJson(),
      'windowTextScaleFactor': nonNull(windowTextScaleFactor),
    };
  }

  factory ScreenshotDeviceInfo.fromMap(Map<String, dynamic> map) {
    return ScreenshotDeviceInfo(
      physicalGeometry: map['physicalGeometry'] as Rect,
      platformBrightness: map['platformBrightness'] as Brightness,
      platformGestureInsets: map['platformGestureInsets'] as WindowPadding,
      windowInsets: map['windowInsets'] as WindowPadding,
      windowPadding: map['windowPadding'] as WindowPadding,
      windowPixelRatio: map['windowPixelRatio'] as double,
      windowSize: map['windowSize'] as Size,
      windowTextScaleFactor: map['windowTextScaleFactor'] as double,
    );
  }

//</editor-fold>
}

class AttachmentId {
  final String value;

  AttachmentId(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttachmentId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return 'AttachmentId{$value}';
  }
}

extension on WindowPadding {
  List<double> toJson() {
    return [left, top, right, bottom];
  }
}

extension on Rect {
  // ignore: unused_element
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

extension on Screenshot {
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> values = {
      'id': file.attachmentId!.value,
      'physicalGeometry': nonNull(deviceInfo.physicalGeometry).toJson(),
      'brightness': nonNull(deviceInfo.physicalGeometry).toJson(),
      'platformGestureInsets': nonNull(deviceInfo.gestureInsets).toJson(),
      'windowPixelRatio': nonNull(deviceInfo.pixelRatio),
      'windowSize': nonNull(deviceInfo.physicalSize).toJson(),
      'windowTextScaleFactor': nonNull(deviceInfo.textScaleFactor),
      'windowInsets': nonNull(deviceInfo.viewInsets).toJson(),
      'windowPadding': nonNull(deviceInfo.padding).toJson(),
    };

    return values;
  }
}
