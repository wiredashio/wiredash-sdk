import 'dart:convert';

import 'package:http/http.dart';
import 'package:wiredash/src/_ps.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/version.dart';

Future<void> postSendPromoterScore(
  ApiClientContext context,
  String url,
  PromoterScoreRequestBody body,
) async {
  final Request request = Request('POST', Uri.parse(url));

  request.headers.addAll({
    'Content-Type': 'application/json',
    'project': context.projectId,
    'secret': context.secret,
    'version': wiredashSdkVersion.toString(),
  });

  final args = body.toRequestJson();
  request.body = jsonEncode(args);

  final response = await context.send(request);
  if (response.statusCode == 200) {
    // success 🎉
    return;
  }
  context.throwApiError(response);
}

class PromoterScoreRequestBody {
  const PromoterScoreRequestBody({
    this.message,
    required this.question,
    this.score,
    required this.metadata,
  });

  final String? message;
  final String question;
  final PromoterScoreRating? score;
  final AllMetaData metadata;

  Map<String, Object> toRequestJson() {
    final Map<String, Object> body = {};

    if (message != null && message!.isNotEmpty) {
      body['message'] = message!;
    }

    body['metadata'] = metadata.toRequestJson();

    body['question'] = question;

    if (score != null) {
      body['score'] = score!.intValue;
    }

    return body;
  }
}
