import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
          listEquals(attachments, other.attachments) &&
          buildInfo == other.buildInfo &&
          deviceId == other.deviceId &&
          email == other.email &&
          message == other.message &&
          userId == other.userId &&
          sdkVersion == other.sdkVersion &&
          deviceInfo == other.deviceInfo &&
          listEquals(labels, other.labels) &&
          appInfo == other.appInfo &&
          const DeepCollectionEquality.unordered()
              .equals(customMetaData, other.customMetaData);

  @override
  int get hashCode =>
      hashList(attachments) ^
      buildInfo.hashCode ^
      deviceId.hashCode ^
      email.hashCode ^
      message.hashCode ^
      userId.hashCode ^
      sdkVersion.hashCode ^
      deviceInfo.hashCode ^
      hashList(labels) ^
      appInfo.hashCode ^
      const DeepCollectionEquality.unordered().hash(customMetaData);

  @override
  String toString() {
    return 'PersistedFeedbackItem{\n'
        'buildInfo: $buildInfo,\n'
        'deviceId: $deviceId,\n'
        'email: $email,\n'
        'message: $message,\n'
        'userId: $userId,\n'
        'deviceInfo: $deviceInfo,\n'
        'sdkVersion: $sdkVersion,\n'
        'labels: $labels,\n'
        'appInfo: $appInfo,\n'
        'customMetaData: $customMetaData,\n'
        'attachments: $attachments\n'
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

abstract class PersistedAttachment {
  const PersistedAttachment();

  FileDataEventuallyOnDisk get file;

  bool get isUploaded => file.isUploaded;

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

class Screenshot extends PersistedAttachment {
  const Screenshot._({
    required this.file,
    required this.deviceInfo,
  });

  @override
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
  final String? pathToFile;
  final AttachmentId? attachmentId;

  FileDataEventuallyOnDisk.inMemory(Uint8List data)
      : _data = data,
        pathToFile = null,
        attachmentId = null;

  FileDataEventuallyOnDisk.file(File file)
      : pathToFile = file.path,
        _data = null,
        attachmentId = null;

  FileDataEventuallyOnDisk.uploaded(AttachmentId attachmentId)
      // ignore: prefer_initializing_formals
      : attachmentId = attachmentId,
        _data = null,
        pathToFile = null;

  bool get isOnDisk => pathToFile != null;
  bool get isUploaded => attachmentId != null;
  bool get isInMemomry => _data != null;

  Uint8List? get binaryData {
    if (_data != null) return _data!;
    if (pathToFile != null) {
      return File(pathToFile!).readAsBytesSync();
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileDataEventuallyOnDisk &&
          runtimeType == other.runtimeType &&
          _data == other._data &&
          pathToFile == other.pathToFile &&
          attachmentId == other.attachmentId;

  @override
  int get hashCode =>
      _data.hashCode ^ pathToFile.hashCode ^ attachmentId.hashCode;

  @override
  String toString() {
    if (isUploaded) return "FileDataEventuallyOnDisk.uploaded($attachmentId)";
    if (isOnDisk) return "FileDataEventuallyOnDisk.file($pathToFile)";
    return 'FileDataEventuallyOnDisk.inMemory(${_data!.lengthInBytes}bytes)';
  }
}
