// ignore_for_file: no_leading_underscores_for_local_identifiers, unnecessary_await_in_return

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:wiredash/src/core/network/ping_request.dart';
import 'package:wiredash/src/core/network/send_feedback_request.dart';
import 'package:wiredash/src/core/network/send_promoter_score_request.dart';
import 'package:wiredash/src/core/network/upload_attachment_request.dart';
import 'package:wiredash/src/feedback/data/feedback_item.dart';

export 'package:wiredash/src/core/network/ping_request.dart';
export 'package:wiredash/src/core/network/send_feedback_request.dart';
export 'package:wiredash/src/core/network/send_promoter_score_request.dart';
export 'package:wiredash/src/core/network/upload_attachment_request.dart';

/// API client to communicate with the Wiredash servers
class WiredashApi {
  WiredashApi({
    required Client httpClient,
    required String projectId,
    required String secret,
  }) : _context = ApiClientContext(
          httpClient: httpClient,
          projectId: projectId,
          secret: secret,
        );

  final ApiClientContext _context;

  static const String _host = 'https://api.wiredash.io/sdk';

  /// Uploads a attachment to the Wiredash hosting service
  ///
  /// POST /uploadAttachment
  Future<AttachmentId> uploadAttachment({
    required Uint8List screenshot,
    required AttachmentType type,
    String? filename,
    MediaType? contentType,
  }) async {
    return await postUploadAttachment(
      _context,
      '$_host/uploadAttachment',
      screenshot,
      filename,
      contentType,
      type,
    );
  }

  /// Reports a feedback
  ///
  /// POST /sendFeedback
  Future<void> sendFeedback(FeedbackItem feedback) async {
    return await postSendFeedback(_context, '$_host/sendFeedback', feedback);
  }

  /// Submits score of the promoter score survey
  Future<void> sendPromoterScore(PromoterScoreRequestBody body) async {
    return await postSendPromoterScore(
      _context,
      '$_host/sendPromoterScore',
      body,
    );
  }

  Future<PingResponse> ping(PingRequestBody body) async {
    return await postPing(_context, '$_host/ping', body);
  }
}

class ApiClientContext {
  final Client httpClient;
  final String secret;
  final String projectId;

  ApiClientContext({
    required this.httpClient,
    required this.secret,
    required this.projectId,
  });

  /// Sends a [BaseRequest] after attaching HTTP headers
  Future<Response> send(BaseRequest request) async {
    final streamedResponse = await httpClient.send(request);
    return Response.fromStream(streamedResponse);
  }

  Never parseResponseForErrors(Response response) {
    if (response.statusCode == 401) {
      throw UnauthenticatedWiredashApiException(response, projectId, secret);
    }
    if (response.statusCode == 403) {
      throw KillSwitchException(response: response);
    }
    throw WiredashApiException(response: response);
  }
}

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

enum AttachmentType {
  screenshot,
}

/// Backend returns an error which silences the SDK for one week
class KillSwitchException extends WiredashApiException {
  const KillSwitchException({super.response});
  @override
  String toString() {
    return 'KillSwitchException{${response?.statusCode}, body: ${response?.body}}';
  }
}
