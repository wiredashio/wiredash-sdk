import 'dart:math';
import 'dart:typed_data';

import 'package:http_parser/src/media_type.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/network/send_events_request.dart';
import 'package:wiredash/src/core/network/wiredash_api.dart';

import 'invocation_catcher.dart';

class MockWiredashApi implements WiredashApi {
  MockWiredashApi();

  /// Returns "success" responses
  factory MockWiredashApi.fake() {
    final api = MockWiredashApi();
    api.uploadAttachmentInvocations.interceptor = (iv) {
      final randomFloat = Random().nextDouble().toString();
      return AttachmentId(randomFloat.replaceFirst('0.', ''));
    };

    api.pingInvocations.interceptor = (iv) {
      return PingResponse();
    };
    return api;
  }

  final MethodInvocationCatcher sendFeedbackInvocations =
      MethodInvocationCatcher('sendFeedback');

  @override
  Future<void> sendFeedback(FeedbackItem feedback) async {
    return await sendFeedbackInvocations.addMethodCall(args: [feedback])?.value;
  }

  final MethodInvocationCatcher uploadAttachmentInvocations =
      MethodInvocationCatcher('uploadAttachment');

  @override
  Future<AttachmentId> uploadAttachment({
    required Uint8List screenshot,
    required AttachmentType type,
    String? filename,
    MediaType? contentType,
  }) async {
    final mockedReturnValue =
        uploadAttachmentInvocations.addAsyncMethodCall<AttachmentId>(
      namedArgs: {
        'screenshot': screenshot,
        'type': type,
        'filename': filename,
        'contentType': contentType,
      },
    );
    if (mockedReturnValue != null) {
      return mockedReturnValue.future;
    }
    throw 'Not mocked';
  }

  final MethodInvocationCatcher sendPsInvocations =
      MethodInvocationCatcher('sendPromoterScore');

  @override
  Future<void> sendPromoterScore(PromoterScoreRequestBody body) async {
    return await sendPsInvocations.addAsyncMethodCall(args: [body])?.future;
  }

  final MethodInvocationCatcher pingInvocations =
      MethodInvocationCatcher('ping');

  @override
  Future<PingResponse> ping(PingRequestBody body) async {
    final mockedReturnValue =
        pingInvocations.addAsyncMethodCall<PingResponse>(args: [body]);
    if (mockedReturnValue != null) {
      return mockedReturnValue.future;
    }
    throw 'Not mocked';
  }

  final MethodInvocationCatcher sendEventsInvocations =
      MethodInvocationCatcher('sendEvents');

  @override
  Future<void> sendEvents(List<RequestEvent> events) async {
    final mockedReturnValue =
        sendEventsInvocations.addAsyncMethodCall(args: [events]);
    if (mockedReturnValue != null) {
      return mockedReturnValue.future;
    }
    throw 'Not mocked';
  }
}
