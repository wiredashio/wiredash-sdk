// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:file/file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wiredash/src/core/version.dart';
import 'package:wiredash/src/feedback/_feedback.dart';
import 'package:wiredash/src/metadata/build_info/app_info.dart';
import 'package:wiredash/src/metadata/build_info/build_info.dart';
import 'package:wiredash/src/metadata/device_info/device_info.dart';

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
  final FlutterDeviceInfo deviceInfo;
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
      // ignore: deprecated_member_use
      hashList(attachments) ^
      buildInfo.hashCode ^
      deviceId.hashCode ^
      email.hashCode ^
      message.hashCode ^
      userId.hashCode ^
      sdkVersion.hashCode ^
      deviceInfo.hashCode ^
      // ignore: deprecated_member_use
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
    FlutterDeviceInfo? deviceInfo,
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
    required FlutterDeviceInfo deviceInfo,
  }) {
    return Screenshot._(
      file: file,
      deviceInfo: deviceInfo,
    );
  }

// TODO add freezed like when() for more attachment types
}

/// A attachment type the user created using Wiredash screenshot feature
class Screenshot extends PersistedAttachment {
  const Screenshot._({
    required this.file,
    required this.deviceInfo,
  });

  @override
  final FileDataEventuallyOnDisk file;
  final FlutterDeviceInfo deviceInfo;

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
    FlutterDeviceInfo? deviceInfo,
  }) {
    return PersistedAttachment.screenshot(
      file: file ?? this.file,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }
}

/// A [PersistedAttachment] type that is either in-memory, on disk or already
/// uploaded to the cloud
class FileDataEventuallyOnDisk {
  final Uint8List? data;
  final String? pathToFile;
  final AttachmentId? attachmentId;

  FileDataEventuallyOnDisk.inMemory(Uint8List data)
      // ignore: prefer_initializing_formals
      : data = data,
        pathToFile = null,
        attachmentId = null;

  FileDataEventuallyOnDisk.file(String path)
      : pathToFile = path,
        data = null,
        attachmentId = null;

  FileDataEventuallyOnDisk.uploaded(AttachmentId attachmentId)
      // ignore: prefer_initializing_formals
      : attachmentId = attachmentId,
        data = null,
        pathToFile = null;

  bool get isOnDisk => pathToFile != null;

  bool get isUploaded => attachmentId != null;

  bool get isInMemomry => data != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileDataEventuallyOnDisk &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          pathToFile == other.pathToFile &&
          attachmentId == other.attachmentId;

  @override
  int get hashCode =>
      data.hashCode ^ pathToFile.hashCode ^ attachmentId.hashCode;

  @override
  String toString() {
    if (isUploaded) return "FileDataEventuallyOnDisk.uploaded($attachmentId)";
    if (isOnDisk) return "FileDataEventuallyOnDisk.file($pathToFile)";
    return 'FileDataEventuallyOnDisk.inMemory(${data!.lengthInBytes}bytes)';
  }
}

extension BinaryDataFromFile on FileDataEventuallyOnDisk {
  Uint8List? binaryData(FileSystem filesystem) {
    if (data != null) return data!;
    if (pathToFile != null) {
      return filesystem.file(pathToFile).readAsBytesSync();
    }
    return null;
  }
}
