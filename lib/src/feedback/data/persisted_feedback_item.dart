import 'dart:io';
import 'dart:typed_data';

import 'package:wiredash/src/common/build_info/app_info.dart';
import 'package:wiredash/src/common/build_info/build_info.dart';
import 'package:wiredash/src/common/device_info/device_info.dart';
import 'package:wiredash/src/common/network/wiredash_api.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item.dart';
import 'package:wiredash/src/version.dart';

export 'package:wiredash/src/common/build_info/app_info.dart';
export 'package:wiredash/src/common/build_info/build_info.dart';
export 'package:wiredash/src/common/device_info/device_info.dart';

/// Contains all relevant feedback information, both user-provided and
/// automatically inferred, that will be eventually sent to the Wiredash
/// console and are in the meantime persisted on disk inside
/// [PendingFeedbackItem].
///
/// Actual serialization happens in [PendingFeedbackItem]
class PersistedFeedbackItem {
  const PersistedFeedbackItem({
    required this.attachments,
    required this.buildInfo,
    required this.deviceId,
    this.email,
    required this.message,
    this.userId,
    this.labels,
    this.customMetaData,
    required this.deviceInfo,
    required this.appInfo,
    this.sdkVersion = wiredashSdkVersion,
  });

  final List<PersistedAttachment> attachments;
  final BuildInfo buildInfo;
  final String deviceId;
  final String? email;
  final String message;
  final String? userId;
  final int sdkVersion;
  final DeviceInfo deviceInfo;
  final List<String>? labels;
  final AppInfo appInfo;
  final Map<String, Object?>? customMetaData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersistedFeedbackItem &&
          runtimeType == other.runtimeType &&
          attachments == other.attachments &&
          buildInfo == other.buildInfo &&
          deviceId == other.deviceId &&
          email == other.email &&
          message == other.message &&
          userId == other.userId &&
          sdkVersion == other.sdkVersion &&
          deviceInfo == other.deviceInfo &&
          labels == other.labels &&
          appInfo == other.appInfo &&
          customMetaData == other.customMetaData;

  @override
  int get hashCode =>
      attachments.hashCode ^
      buildInfo.hashCode ^
      deviceId.hashCode ^
      email.hashCode ^
      message.hashCode ^
      userId.hashCode ^
      sdkVersion.hashCode ^
      deviceInfo.hashCode ^
      labels.hashCode ^
      appInfo.hashCode ^
      customMetaData.hashCode;

  @override
  String toString() {
    return 'PersistedFeedbackItem{'
        'buildInfo: $buildInfo, '
        'deviceId: $deviceId, '
        'email: $email, '
        'message: $message, '
        'userId: $userId, '
        'deviceInfo: $deviceInfo, '
        'sdkVersion: $sdkVersion, '
        'labels: $labels, '
        'appInfo: $appInfo, '
        'customMetaData: $customMetaData, '
        'attachments: $attachments, '
        '}';
  }

  PersistedFeedbackItem copyWith({
    List<PersistedAttachment>? attachments,
    BuildInfo? buildInfo,
    String? deviceId,
    String? email,
    String? message,
    String? userId,
    int? sdkVersion,
    DeviceInfo? deviceInfo,
    List<String>? labels,
    AppInfo? appInfo,
    Map<String, Object?>? customMetaData,
  }) {
    return PersistedFeedbackItem(
      attachments: attachments ?? this.attachments,
      buildInfo: buildInfo ?? this.buildInfo,
      deviceId: deviceId ?? this.deviceId,
      email: email ?? this.email,
      message: message ?? this.message,
      userId: userId ?? this.userId,
      sdkVersion: sdkVersion ?? this.sdkVersion,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      labels: labels ?? this.labels,
      appInfo: appInfo ?? this.appInfo,
      customMetaData: customMetaData ?? this.customMetaData,
    );
  }
}

class PersistedAttachment {
  PersistedAttachment._();

  // ignore: prefer_constructors_over_static_methods
  static Screenshot screenshot({
    required FileDataEventuallyOnDisk file,
    required DeviceInfo deviceInfo,
  }) {
    return Screenshot._(
      file: file,
      deviceInfo: deviceInfo,
    );
  }
}

class Screenshot implements PersistedAttachment {
  const Screenshot._({
    required this.file,
    required this.deviceInfo,
  });

  final FileDataEventuallyOnDisk file;
  final DeviceInfo deviceInfo;

  @override
  String toString() {
    return 'Screenshot{'
        'file: $file, '
        'deviceInfo: $deviceInfo, '
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Screenshot &&
          runtimeType == other.runtimeType &&
          file == other.file &&
          deviceInfo == other.deviceInfo;

  @override
  int get hashCode => file.hashCode ^ deviceInfo.hashCode;

  Screenshot copyWith({
    FileDataEventuallyOnDisk? file,
    DeviceInfo? deviceInfo,
  }) {
    return PersistedAttachment.screenshot(
      file: file ?? this.file,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }
}

/// Usually on disk, but maybe already in memory
class FileDataEventuallyOnDisk {
  final Uint8List? _data;
  final String? _pathToFile;
  final ImageBlob? imageBlob;

  FileDataEventuallyOnDisk.inMemory(Uint8List data)
      : _data = data,
        _pathToFile = null,
        imageBlob = null;

  FileDataEventuallyOnDisk.file(File file)
      : _pathToFile = file.path,
        _data = null,
        imageBlob = null;

  FileDataEventuallyOnDisk.uploaded(ImageBlob blob)
      : imageBlob = blob,
        _data = null,
        _pathToFile = null;

  Uint8List? get binaryData {
    if (_data != null) return _data!;
    if (_pathToFile != null) {
      return File(_pathToFile!).readAsBytesSync();
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileDataEventuallyOnDisk &&
          runtimeType == other.runtimeType &&
          _data == other._data &&
          _pathToFile == other._pathToFile;

  @override
  int get hashCode => _data.hashCode ^ _pathToFile.hashCode;
}
