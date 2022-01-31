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

  /// Uploads an image to the Wiredash image hosting
  ///
  /// POST /sendImage
  Future<ImageBlob> sendImage(Uint8List screenshot) async {
    final uri = Uri.parse('$_host/sendImage');
    final multipartFile = MultipartFile.fromBytes(
      'file',
      screenshot,
      filename: 'file',
      contentType: MediaType('image', 'png'),
    );
    final req = MultipartRequest('POST', uri)..files.add(multipartFile);
    final response = await _send(req);

    if (response.statusCode == 401) {
      throw UnauthenticatedWiredashApiException(response, _projectId, _secret);
    }

    if (response.statusCode != 200) {
      throw WiredashApiException(
        message: 'image upload failed',
        response: response,
      );
    }

    // backend returns a rather complex image object. We don't care much about
    // the actual content, It will be attached to feedbacks as is
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    return ImageBlob(map);
  }

  /// Reports a feedback
  ///
  /// POST /sendFeedback
  Future<void> sendFeedback(
    PersistedFeedbackItem feedback, {
    List<ImageBlob> images = const [],
  }) async {
    final uri = Uri.parse('$_host/sendFeedback');
    final Request request = Request('POST', uri);
    request.headers['Content-Type'] = 'application/json';

    final args = feedback.toFeedbackBody();
    args.addAll({'images': images.map((blob) => blob.data).toList()});
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

/// Generic error from the Wiredash API
class WiredashApiException implements Exception {
  WiredashApiException({String? message, this.response}) : _message = message;

  String? get message {
    final String? bodyMessage = () {
      try {
        final json = jsonDecode(response?.body ?? '') as Map?;
        return json?['message'] as String?;
      } catch (e) {
        return response?.body;
      }
    }();
    if (_message == null) {
      return bodyMessage;
    }
    return '$_message $bodyMessage';
  }

  final String? _message;
  final Response? response;

  @override
  String toString() {
    return 'WiredashApiException{'
        '${response?.statusCode}, '
        'message: $message, '
        'body: ${response?.body}'
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

/// A response from backend after image upload
///
/// This image object has to be sent as-is back to the backend
class ImageBlob {
  ImageBlob(this.data);

  final Map<String, dynamic> data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageBlob &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}

extension FeedbackBody on PersistedFeedbackItem {
  Map<String, dynamic> toFeedbackBody() {
    final Map<String, Object> values = {};

    // Required values
    values.addAll({
      'deviceId': nonNull(deviceId),
      'compilationMode': nonNull(buildInfo.compilationMode).jsonEncode(),
      if (labels != null) 'labels': nonNull(labels!),
      'message': nonNull(message),
      'sdkVersion': nonNull(sdkVersion),
      'windowPixelRatio': nonNull(deviceInfo.pixelRatio),
      'windowSize': nonNull(deviceInfo.physicalSize).toJson(),
      'windowTextScaleFactor': nonNull(deviceInfo.textScaleFactor),
    });

    // Not yet required but we can trust those are non null
    values.addAll({
      'appLocale': nonNull(appInfo.appLocale),
      'platformLocale': nonNull(deviceInfo.platformLocale),
      'platformSupportedLocales': nonNull(deviceInfo.platformSupportedLocales),
      'platformGestureInsets': nonNull(deviceInfo.gestureInsets).toJson(),
      'windowInsets': nonNull(deviceInfo.viewInsets).toJson(),
      'windowPadding': nonNull(deviceInfo.padding).toJson(),
      'physicalGeometry': nonNull(deviceInfo.physicalGeometry).toJson(),
      'platformBrightness': nonNull(deviceInfo.platformBrightness).jsonEncode(),
    });

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
