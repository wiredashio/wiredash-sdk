import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:wiredash/src/common/network/api_client.dart';

class NetworkManager {
  NetworkManager(this._apiClient);

  final ApiClient _apiClient;

  static const String _feedbackPath = 'feedback';

  static const String _parameterDeviceInfo = 'deviceInfo';
  static const String _parameterEmail = 'email';
  static const String _parameterPayload = 'payload';
  static const String _parameterUser = 'user';

  static const String _parameterFeedbackMessage = 'message';
  static const String _parameterFeedbackScreenshot = 'file';
  static const String _parameterFeedbackType = 'type';

  Future<void> sendFeedback({
    @required Map<String, dynamic> deviceInfo,
    String email,
    @required String message,
    Map<String, dynamic> payload,
    Uint8List picture,
    @required String type,
    String user,
  }) async {
    MultipartFile screenshotFile;

    if (picture != null) {
      screenshotFile = MultipartFile.fromBytes(
        _parameterFeedbackScreenshot,
        picture,
        filename: 'file',
        contentType: MediaType('image', 'png'),
      );
    }

    await _apiClient.post(
      urlPath: _feedbackPath,
      arguments: {
        _parameterDeviceInfo: json.encode(deviceInfo),
        if (email != null) _parameterEmail: email,
        _parameterFeedbackMessage: message,
        if (payload != null) _parameterPayload: json.encode(payload),
        _parameterFeedbackType: type,
        if (user != null) _parameterUser: user
      },
      files: [screenshotFile],
    );
  }
}
