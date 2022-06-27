import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:wiredash/src/core/services/error_report.dart';
import 'package:wiredash/src/core/version.dart';
import 'package:wiredash/src/feedback/data/persisted_feedback_item.dart';
import 'package:wiredash/src/metadata/build_info/build_info.dart';
import 'package:wiredash/src/nps/nps_model.dart';

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
        message: '$type upload failed',
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

  Future<void> sendNps(NpsRequestBody body) async {
    final uri = Uri.parse('$_host/sendNps');
    final Request request = Request('POST', uri);
    request.headers['Content-Type'] = 'application/json';

    final args = body.toJson();
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
      message: 'submitting nps failed',
      response: response,
    );
  }

  Future<PingResponse> ping() async {
    throw "TODO implement";
    // TODO throw KillSwitchException();
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
      // TODO generate filename when taking the screenshot
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
      // Official error format for wiredash backend
      final json = jsonDecode(response?.body ?? '') as Map?;
      final message = json?['errorMessage'] as String?;
      final code = json?['errorCode'] as int?;
      if (code != null) {
        return '[$code] ${message ?? '<no message>'}';
      }
      return message!;
    } catch (_) {
      // ignore
    }
    try {
      // Parsing errors often have this format
      final json = jsonDecode(response?.body ?? '') as Map?;
      final message = json?['message'] as String?;
      return message!;
    } catch (_) {
      // ignore
    }
    return response?.body;
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

    // Values are sorted alphabetically for easy comparison with the backend
    values.addAll({'appLocale': nonNull(appInfo.appLocale)});

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

    values.addAll({
      'compilationMode': nonNull(buildInfo.compilationMode).jsonEncode(),
    });

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

    values.addAll({'deviceId': nonNull(deviceId)});

    final _labels = labels;
    if (_labels != null) {
      values.addAll({'labels': _labels});
    }

    values.addAll({'message': nonNull(message)});

    values.addAll({
      'physicalGeometry': nonNull(deviceInfo.physicalGeometry).toJson(),
    });

    values.addAll({
      'platformBrightness': nonNull(deviceInfo.platformBrightness).jsonEncode()
    });

    final platformDartVersion = deviceInfo.platformVersion;
    if (platformDartVersion != null) {
      values.addAll({'platformDartVersion': platformDartVersion});
    }

    values.addAll({
      'platformGestureInsets': nonNull(deviceInfo.gestureInsets).toJson(),
    });

    values.addAll({'platformLocale': nonNull(deviceInfo.platformLocale)});

    final platformOS = deviceInfo.platformOS;
    if (platformOS != null) {
      values.addAll({'platformOS': platformOS});
    }

    final platformOSVersion = deviceInfo.platformOSVersion;
    if (platformOSVersion != null) {
      values.addAll({'platformOSVersion': platformOSVersion});
    }

    values.addAll({
      'platformSupportedLocales': nonNull(deviceInfo.platformSupportedLocales)
    });

    // Web only
    final platformUserAgent = deviceInfo.userAgent;
    if (platformUserAgent != null) {
      values.addAll({'platformUserAgent': platformUserAgent});
    }

    values.addAll({'sdkVersion': nonNull(sdkVersion)});

    final userEmail = email;
    if (userEmail != null && userEmail.isNotEmpty) {
      values.addAll({'userEmail': userEmail});
    }

    final String? _userId = userId;
    if (_userId != null) {
      values.addAll({'userId': _userId});
    }

    values.addAll({
      'windowInsets': nonNull(deviceInfo.viewInsets).toJson(),
    });

    values.addAll({
      'windowPadding': nonNull(deviceInfo.padding).toJson(),
    });

    values.addAll({
      'windowPixelRatio': nonNull(deviceInfo.pixelRatio),
    });

    values.addAll({
      'windowSize': nonNull(deviceInfo.physicalSize).toJson(),
    });

    values.addAll({
      'windowTextScaleFactor': nonNull(deviceInfo.textScaleFactor),
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

/// The reference id returned by the backend identifying the binary attachment
/// hosted in the wiredash cloud
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

class NpsRequestBody {
  const NpsRequestBody({
    this.appLocale,
    required this.deviceId,
    this.message,
    required this.question,
    this.platformLocale,
    this.platformOS,
    this.platformOSVersion,
    this.platformUserAgent,
    required this.score,
    required this.sdkVersion,
    this.userEmail,
    this.userId,
  });

  final String? appLocale;
  final String deviceId;
  final String? message;
  final String question;
  final String? platformLocale;
  final String? platformOS;
  final String? platformOSVersion;
  final String? platformUserAgent;
  final NpsScore score;
  final int sdkVersion;
  final String? userEmail;
  final String? userId;

  Map<String, Object> toJson() {
    final Map<String, Object> body = {};

    if (appLocale != null) {
      body['appLocale'] = appLocale!;
    }

    body['deviceId'] = deviceId;

    if (message != null && message!.isNotEmpty) {
      // TODO make nullable in backend
      body['message'] = message!;
    }

    body['question'] = question;

    if (platformLocale != null) {
      body['platformLocale'] = platformLocale!;
    }

    if (platformOS != null) {
      body['platformOS'] = platformOS!;
    }
    if (platformOSVersion != null) {
      // TODO add to backend
      // body['platformOSVersion'] = platformOSVersion!;
    }

    if (platformUserAgent != null) {
      body['platformUserAgent'] = platformUserAgent!;
    }

    body['score'] = score.intValue;

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

class PingResponse {
  /// The id of the last message from dev or user
  ///
  /// Used to detect if there are new messages
  ///
  /// can be `null` when user never gave any feedback
  // TODO double check with backend
  final String? latestMessageId;

  PingResponse({
    required this.latestMessageId,
  });
}

/// Backend returns an error which silences the SDK (preventing automatic pings)
/// until [silentUntil]
class KillSwitchException extends WiredashApiException {
  KillSwitchException(this.silentUntil, {Response? response})
      : super(response: response);

  final DateTime silentUntil;

  @override
  String toString() {
    return 'KillSwitchException{${response?.statusCode}, silentUntil: $silentUntil, body: ${response?.body}}';
  }
}
