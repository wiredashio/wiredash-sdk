import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:wiredash/src/feedback/data/feedback_item.dart';

class WiredashApi {
  WiredashApi({
    @required Client httpClient,
    @required String projectId,
    @required String secret,
  })  : _httpClient = httpClient,
        _projectId = projectId,
        _secret = secret;

  final Client _httpClient;
  final String _projectId;
  final String _secret;

  static const String _host = 'https://api.wiredash.io';

  /// Reports a feedback
  ///
  /// POST /feedback
  Future<void> sendFeedback({
    @required FeedbackItem feedback,
    Uint8List screenshot,
  }) async {
    assert(feedback != null);
    final uri = Uri.parse('$_host/feedback');
    final arguments = feedback.toMultipartFormFields()
      ..removeWhere((key, value) => value == null || value.isEmpty);

    final BaseRequest request = () {
      if (screenshot != null) {
        return MultipartRequest('POST', uri)
          ..fields.addAll(arguments)
          ..files.add(MultipartFile.fromBytes(
            'file',
            screenshot,
            filename: 'file',
            contentType: MediaType('image', 'png'),
          ));
      }
      return Request('POST', uri)..bodyFields = arguments;
    }();

    final response = await _send(request);
    if (response.statusCode == 200) {
      // success 🎉
      return;
    }
    if (response.statusCode == 401) {
      throw UnauthenticatedWiredashApiException(response, _projectId, _secret);
    }
    throw WiredashApiException(response: response);
  }

  /// Sends a [BaseRequest]
  Future<Response> _send(BaseRequest request) async {
    request.headers['project'] = 'Project $_projectId';
    request.headers['authorization'] = 'Secret $_secret';

    final streamedResponse = await _httpClient.send(request);
    return Response.fromStream(streamedResponse);
  }
}

/// Generic error from the Wiredash API
class WiredashApiException implements Exception {
  WiredashApiException({this.message, this.response});

  final String /*?*/ message;
  final Response /*?*/ response;
}

/// Thrown when the server couldn't match the project + secret to a existing project
class UnauthenticatedWiredashApiException extends WiredashApiException {
  UnauthenticatedWiredashApiException(
    Response response,
    this.projectId,
    this.secret,
  ) : super(response: response);

  final String projectId;
  final String secret;

  @override
  String get message =>
      "Unknown projectId:'$projectId' or invalid secret:'$secret'";

  @override
  String toString() {
    return 'UnauthenticatedWiredashApiException{$message, status code: ${response?.statusCode}';
  }
}
