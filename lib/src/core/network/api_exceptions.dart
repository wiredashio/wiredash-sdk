import 'dart:convert';

import 'package:http/http.dart';

/// Generic error from the Wiredash API
class WiredashApiException implements Exception {
  const WiredashApiException({this.message, this.response});

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
        'endpoint: ${response?.request?.url.path}, '
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

/// Backend returns an error which silences the SDK for one week
class KillSwitchException extends WiredashApiException {
  const KillSwitchException({super.response});
  @override
  String toString() {
    return 'KillSwitchException{${response?.statusCode}, body: ${response?.body}}';
  }
}
