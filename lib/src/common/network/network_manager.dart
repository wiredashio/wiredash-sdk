import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:wiredash/src/common/network/api_client.dart';
import 'package:wiredash/src/feedback/data/feedback_item.dart';

class NetworkManager {
  NetworkManager(this._apiClient);
  final ApiClient _apiClient;

  Future<void> sendFeedback(FeedbackItem item, Uint8List screenshot) async {
    MultipartFile screenshotFile;

    if (screenshot != null) {
      screenshotFile = MultipartFile.fromBytes(
        'file',
        screenshot,
        filename: 'file',
        contentType: MediaType('image', 'png'),
      );
    }

    return _apiClient.post(
      urlPath: 'feedback',
      arguments: item.toMultipartFormFields(),
      files: [screenshotFile],
    );
  }
}
