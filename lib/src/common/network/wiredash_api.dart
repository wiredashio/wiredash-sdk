import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:wiredash/src/feedback/data/persisted_feedback_item.dart';
import 'package:wiredash/src/version.dart';

/// API client to communicate with the Wiredash servers
class WiredashApi {
  WiredashApi(
      {required Client httpClient,
      required String projectId,
      required String secret,
      required Future<String> Function() deviceIdProvider})
      : _httpClient = httpClient,
        _projectId = projectId,
        _secret = secret,
        _deviceIdProvider = deviceIdProvider;

  final Client _httpClient;
  final String _projectId;
  final String _secret;
  final Future<String> Function() _deviceIdProvider;

  // static const String _host = 'https://api.wiredash.io';
  static const String _host = 'https://dev-api.wiredash.io/sdk';

  /// Uploads an image to the Wiredash image hosting
  ///
  /// POST /sendImage
  Future<ImageBlob> sendImage(Uint8List screenshot) async {
    final uri = Uri.parse('$_host/sendImage');
    final req = MultipartRequest('POST', uri)
      ..files.add(MultipartFile.fromBytes(
        'file',
        screenshot,
        filename: 'file',
        contentType: MediaType('image', 'png'),
      ));
    final response = await _send(req);
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
  /// POST /feedback
  Future<void> sendFeedback(PersistedFeedbackItem feedback,
      {List<ImageBlob> images = const []}) async {
    final uri = Uri.parse('$_host/sendFeedback');
    final Request request = Request('POST', uri);
    request.headers["Content-Type"] = "application/json";

    final args = feedback.toFeedbackBody();
    args.addAll({'images': images.map((blob) => blob.data).toList()});
    request.body = jsonEncode(args);
    // request.bodyFields =
    //     args.map((key, value) => MapEntry(key, jsonEncode(value)));
    print(request.body);

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
        final json = jsonDecode(response?.body ?? "") as Map?;
        return json?['message'] as String?;
      } catch (e) {
        return response?.body;
      }
    }();
    if (_message == null) {
      return bodyMessage;
    }
    return "$_message $bodyMessage";
  }

  final String? _message;
  final Response? response;

  @override
  String toString() {
    return 'WiredashApiException{${response?.statusCode}, message: $message, body: ${response?.body}';
  }
}

/// Thrown when the server couldn't match the project + secret to a existing project
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
    return 'UnauthenticatedWiredashApiException{$message, status code: ${response?.statusCode}, ${response?.body}';
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
    // TODO better handle required values
    final raw = <String, Object?>{
      'deviceId': deviceInfo.deviceId,
      'isDebugBuild': deviceInfo.appIsDebug,
      // TODO
      'labels': ['bug'],
      'message': message,
      'sdkVersion': sdkVersion,
      // TODO can be null
      'windowPixelRatio': deviceInfo.pixelRatio,
      'windowSize': deviceInfo.physicalSize,
      'windowTextScaleFactor': deviceInfo.textScaleFactor,
      'appLocale': deviceInfo.locale,
      'buildCommit': deviceInfo.buildCommit,
      'buildNumber': deviceInfo.buildNumber,
      'buildVersion': deviceInfo.appVersion,
      // TODO
      'images': [],
      // TODO
      'platformBrightness': null,
      'platformDartVersion': deviceInfo.platformVersion,
      'platformGestureInsets': deviceInfo.viewInsets,
      // TODO how to distinguish app and platform locale?
      'platformLocale': deviceInfo.locale,
      'platformOS': deviceInfo.platformOS,
      'platformOSVersion': deviceInfo.platformOSBuild,
      // TODO get real value
      'platformSupportedLocales': [deviceInfo.locale],
      'platformUserAgent': deviceInfo.userAgent,
      'userEmail': email,
      // TODO
      'userId': null,
      'windowInsets': deviceInfo.viewInsets,
      'windowPadding': deviceInfo.padding,
    };

    raw.removeWhere(
        (key, value) => value == null || value is String && value.isEmpty);

    return raw.map((k, v) => MapEntry(k, v!));
  }
}
