import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:wiredash/src/core/network/wiredash_api.dart';

/// Generic error from the Wiredash API
class WiredashApiException implements Exception {
  const WiredashApiException({this.message, this.response});

  String? get messageFromServer {
    try {
      // Official error format for wiredash backend
      final json = jsonDecode(response?.body ?? '') as Map?;
      final message = json?['errorMessage'] as String?;
      final code = json?['errorCode'] as int?;
      final data = json?['data'] as Map?;
      final warnings = response?.readWiredashWarnings();

      final sb = StringBuffer();
      if (code != null) {
        sb.write('[$code] ');
      }
      sb.write(message ?? '<no message>');
      if (data != null) {
        sb.write(' data: $data');
      }
      if (warnings != null && warnings.isNotEmpty) {
        sb.write(' warnings: $warnings');
      }
      return sb.toString();
    } catch (_) {
      // ignore
    }
    return response?.body;
  }

  final String? message;
  final Response? response;

  @override
  String toString() {
    final sb = StringBuffer();
    sb.write('WiredashApiException{');
    if (message != null) {
      sb.write('"$message", ');
    }
    sb.write('code: ${response?.statusCode}, ');
    sb.write('endpoint: ${response?.request?.url.path}, ');
    sb.write('resp: $messageFromServer');
    sb.write('}');
    return sb.toString();
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

/// Backend returns an error which silences the SDK for one week
class KillSwitchException extends WiredashApiException {
  const KillSwitchException({super.response});
  @override
  String toString() {
    return 'KillSwitchException{${response?.statusCode}, body: ${response?.body}}';
  }
}

/// A general error response from [WiredashApi] with a known error [code]
class WiredashApiErrorResponse {
  final String? message;
  final int code;

  WiredashApiErrorResponse(this.message, this.code);

  static WiredashApiErrorResponse? tryParse(Response response) {
    try {
      final json = jsonDecode(response.body) as Map?;
      final message = json?['errorMessage'] as String?;
      final code = json?['errorCode'] as int;
      return WiredashApiErrorResponse(message, code);
    } catch (_) {
      return null;
    }
  }
}

/// A warning that may be returned by any response from the [WiredashApi]
///
/// Use via `response.readWiredashWarnings()`
class WiredashApiWarning {
  final int code;
  final String message;
  final Map data;

  WiredashApiWarning(this.code, this.message, this.data);

  static WiredashApiWarning? tryParse(Map json) {
    try {
      final code = json['code'] as int;
      final message = json['message'] as String;
      final data = Map.of(json)
        ..removeWhere((key, value) => key == 'code' || key == 'message');
      return WiredashApiWarning(code, message, data);
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() {
    return 'WiredashApiWarning{code: $code, message: $message, data: $data}';
  }
}

/// Allows parsing of the 'warnings' key from a [Response]
extension WiredashApiWarnings on Response {
  /// Any response from the Wiredash API might contain a
  /// top-level 'warnings' key with a list of warnings that
  /// may have popped up during the request
  List<WiredashApiWarning> readWiredashWarnings() {
    try {
      final json = jsonDecode(body) as Map?;
      final warnings = json?['warnings'] as List?;
      if (warnings == null) {
        return [];
      }
      return warnings
          .whereType<Map>()
          .map((w) => WiredashApiWarning.tryParse(w))
          // Switch to .nonNulls when minSdk is Dart 3.0
          // ignore: deprecated_member_use
          .whereNotNull()
          .toList();
    } catch (_) {
      return [];
    }
  }
}
