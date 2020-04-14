import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:wiredash/src/common/network/data_state.dart';

typedef DataStateCallback<T> = void Function(DataState<T> dataState);

class ApiClient {
  ApiClient(
      {@required this.httpClient,
      @required this.projectId,
      @required this.secret});

  static const String _host = 'https://api.wiredash.io/';
  static const String _feedbackPath = 'feedback';

  static const String _parameterDeviceInfo = 'deviceInfo';
  static const String _parameterEmail = 'email';
  static const String _parameterPayload = 'payload';
  static const String _parameterUser = 'user';

  static const String _parameterFeedbackMessage = 'message';
  static const String _parameterFeedbackScreenshot = 'file';
  static const String _parameterFeedbackType = 'type';

  final Client httpClient;
  final String projectId;
  final String secret;

  Future<Map<String, dynamic>> get(String urlPath) async {
    final url = '$_host$urlPath';
    final BaseResponse response = await httpClient.get(url, headers: {
      'project': 'Project $projectId',
      'authorization': 'Secret $secret'
    });
    final responseString = utf8.decode((response as Response).bodyBytes);
    if (response.statusCode != 200) {
      throw Exception('${response.statusCode}:\n$responseString');
    }
    try {
      return json.decode(responseString) as Map<String, dynamic>;
    } catch (exception) {
      throw Exception('${exception.toString()}\n$responseString');
    }
  }

  Future<Map<String, dynamic>> post({
    @required String urlPath,
    @required Map<String, String> arguments,
    List<MultipartFile> files,
  }) async {
    final url = '$_host$urlPath';
    BaseResponse response;
    String responseString;

    arguments.removeWhere((key, value) => value == null || value.isEmpty);
    files.removeWhere((element) => element == null);

    if (files != null && files.isNotEmpty) {
      final multipartRequest = MultipartRequest('POST', Uri.parse(url))
        ..fields.addAll(arguments)
        ..files.addAll(files);
      multipartRequest.headers['project'] = 'Project $projectId';
      multipartRequest.headers['authorization'] = 'Secret $secret';

      response = await multipartRequest.send();
      responseString =
          utf8.decode(await (response as StreamedResponse).stream.toBytes());
    } else {
      response = await httpClient.post(
        url,
        headers: {
          'project': 'Project $projectId',
          'authorization': 'Secret $secret'
        },
        body: arguments,
      );
      responseString = utf8.decode((response as Response).bodyBytes);
    }

    if (response.statusCode != 200) {
      throw Exception('${response.statusCode}:\n$responseString');
    }
    try {
      return json.decode(responseString) as Map<String, dynamic>;
    } catch (exception) {
      throw Exception('${exception.toString()}\n$responseString');
    }
  }

  Future<void> sendFeedback({
    @required Map<String, dynamic> deviceInfo,
    String email,
    @required String message,
    Map<String, dynamic> payload,
    Uint8List picture,
    @required String type,
    String user,
    @required DataStateCallback<Map<String, dynamic>> onDataStateChanged,
  }) async {
    onDataStateChanged(
      DataState<Map<String, dynamic>>.loading(),
    );

    MultipartFile screenshotFile;

    if (picture != null) {
      screenshotFile = MultipartFile.fromBytes(
        _parameterFeedbackScreenshot,
        picture,
        filename: 'file',
        contentType: MediaType('image', 'png'),
      );
    }

    try {
      onDataStateChanged(
        DataState<Map<String, dynamic>>.success(
          await post(
            urlPath: '$_feedbackPath',
            arguments: {
              _parameterDeviceInfo: json.encode(deviceInfo),
              if (email != null) _parameterEmail: email,
              _parameterFeedbackMessage: message,
              if (payload != null) _parameterPayload: json.encode(payload),
              _parameterFeedbackType: type,
              if (user != null) _parameterUser: user
            },
            files: [screenshotFile],
          ),
        ),
      );
    } catch (exception) {
      onDataStateChanged(
        DataState<Map<String, dynamic>>.error(exception),
      );
    }
  }
}
