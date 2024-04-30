// ignore_for_file: no_leading_underscores_for_local_identifiers, unnecessary_await_in_return

import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:wiredash/src/core/network/api_exceptions.dart';
import 'package:wiredash/src/core/network/ping_request.dart';
import 'package:wiredash/src/core/network/send_events_request.dart';
import 'package:wiredash/src/core/network/send_feedback_request.dart';
import 'package:wiredash/src/core/network/send_promoter_score_request.dart';
import 'package:wiredash/src/core/network/upload_attachment_request.dart';
import 'package:wiredash/src/core/services/error_report.dart';
import 'package:wiredash/src/feedback/data/feedback_item.dart';

export 'package:wiredash/src/core/network/api_exceptions.dart';
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

  /// Sends analytics events to Wiredash
  ///
  /// POST /sendEvents
  ///
  /// May throw [PaidFeatureException] or [CouldNotHandleRequestException]
  Future<void> sendEvents(List<RequestEvent> events) async {
    return await postSendEvents(_context, '$_host/sendEvents', events);
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

  Never throwApiError(Response response) {
    if (response.statusCode == 401) {
      throw UnauthenticatedWiredashApiException(response, projectId, secret);
    }
    if (response.statusCode == 403) {
      throw KillSwitchException(response: response);
    }
    throw WiredashApiException(response: response);
  }

  /// Reports all warnings from [response] to [FlutterError.presentError]
  ///
  /// Return a specific exceptions from [handleWarning] to enhance error reporting
  void reportResponseWarnings(
    Response response,
    Exception? Function(WiredashApiWarning warning)? handleWarning,
  ) {
    final warnings = response.readWiredashWarnings();
    if (warnings.isEmpty) return;
    for (final warning in warnings) {
      Object? mappedException;
      try {
        mappedException = handleWarning?.call(warning);
      } catch (_) {
        // ignore
      }
      reportWiredashInfo(
        mappedException ?? warning,
        StackTrace.current,
        'Warning from Wiredash API',
      );
    }
  }

  void handleWarning() {}
}
