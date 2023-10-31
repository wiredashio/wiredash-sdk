import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/wiredash.dart';

/// Collects metadata for any user report from multiple sources
/// - [FlutterInfo]
/// - [CustomizableWiredashMetaData]
/// - [WiredashOptionsData]
/// - [PsOptions]
/// - [BuildInfo]
/// - [DeviceInfoPlugin]
/// - [PackageInfo]
///
/// This class is statelss, all state is cached/stored in [WiredashModel]
class MetaDataCollector {
  MetaDataCollector({
    required this.wiredashModel,
    required this.deviceInfoCollector,
    required this.wiredashWidget,
  });

  final WiredashModel wiredashModel;
  final FlutterInfoCollector Function() deviceInfoCollector;
  final Wiredash Function() wiredashWidget;

  /// Collects all metadata that is pretty much static for the current session
  Future<FixedMetaData> collectFixedMetaData() async {
    final cache = wiredashModel.fixedMetaData;
    if (cache != null) {
      return wiredashModel.fixedMetaData!;
    }

    final results = await Future.wait(
      <Future<Object?>>[
        _collectAppInfo(),
        _collectDeviceInfo(),
      ].map(
        (e) => e.catchError(
          (Object e, StackTrace stack) {
            reportWiredashError(
              e,
              stack,
              'Could not collect metadata',
            );
            return null;
          },
        ),
      ),
    );
    final appInfo = results[0] as AppInfo?;
    final deviceInfo = results[1] as DeviceInfo?;

    final combined = FixedMetaData(
      appInfo: appInfo!,
      deviceInfo: deviceInfo!,
      buildInfo: buildInfo,
    );

    wiredashModel.fixedMetaData = combined;
    return combined;
  }

  Future<AppInfo> _collectAppInfo() async {
    AppInfo appInfo = const AppInfo();
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appInfo = appInfo.copyWith(
        appName: packageInfo.appName,
        bundleId: packageInfo.packageName,
        version: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
      );
    } catch (e, stack) {
      reportWiredashError(e, stack, 'Failed to collect package info');
    }

    return appInfo;
  }

  /// Collects metadata from the user, either with
  /// [WiredashFeedbackOptions.collectMetaData] or [PsOptions.collectMetaData]
  /// as [collector]
  Future<SessionMetaData> collectSessionMetaData(
    CustomMetaDataCollector? collector,
  ) async {
    final metadata =
        wiredashModel.metaData ?? await _createPopulatedSessionMetadata();

    if (collector != null) {
      try {
        final collected = await collector(metadata.makeCustomizable());
        wiredashModel.metaData = collected;
      } catch (e, stack) {
        reportWiredashError(
          e,
          stack,
          'Failed to collect custom metadata',
        );
      }
    }
    return metadata;
  }

  /// Synchronously collect all information from the FlutterWindow / FlutterView
  FlutterInfo collectFlutterInfo() {
    return deviceInfoCollector().capture();
  }

  /// Creates [SessionMetaData] pre-populated with data already collected
  Future<SessionMetaData> _createPopulatedSessionMetadata() async {
    final fixedMetaData = await collectFixedMetaData();

    final metadata = CustomizableWiredashMetaData();
    metadata.appLocale = wiredashModel.appLocaleFromContext?.toLanguageTag();
    metadata.buildVersion =
        fixedMetaData.buildInfo.buildVersion ?? fixedMetaData.appInfo.version;
    metadata.buildNumber = fixedMetaData.buildInfo.buildNumber ??
        fixedMetaData.appInfo.buildNumber;
    metadata.buildCommit = fixedMetaData.buildInfo.buildCommit;

    return metadata;
  }

  Future<DeviceInfo> _collectDeviceInfo() async {
    try {
      final deviceInfo = await DeviceInfoPlugin().deviceInfo;

      if (deviceInfo is MacOsDeviceInfo) {
        return DeviceInfo(deviceModel: deviceInfo.model);
      }
      if (deviceInfo is IosDeviceInfo) {
        return DeviceInfo(deviceModel: deviceInfo.model);
      }
      if (deviceInfo is AndroidDeviceInfo) {
        return DeviceInfo(deviceModel: deviceInfo.model);
      }
      // there's not way to get the model of windows or linux devices
    } catch (e, stack) {
      reportWiredashError(
        e,
        stack,
        'Failed to collect deviceInfo.model with device_info_plus',
      );
    }
    return const DeviceInfo();
  }
}

/// A function that is used to collect and modify the [WiredashMetaData] by
/// the developer of the app.
///
/// It is called with the latest [WiredashMetaData] returned from this callback.
/// Developers can then modify the metadata and have the final say in what is
/// collected.
typedef CustomMetaDataCollector = Future<WiredashMetaData> Function(
  CustomizableWiredashMetaData metaData,
);

/// Information about the app/device/engine that is not changing during a
/// session of the app.
class FixedMetaData {
  final DeviceInfo deviceInfo;
  final BuildInfo buildInfo;
  final AppInfo appInfo;

  const FixedMetaData({
    required this.deviceInfo,
    required this.buildInfo,
    required this.appInfo,
  });
}

/// Information about the device the user is using
class DeviceInfo {
  final String? deviceModel;

  const DeviceInfo({
    this.deviceModel,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceInfo &&
          runtimeType == other.runtimeType &&
          deviceModel == other.deviceModel);

  @override
  int get hashCode => deviceModel.hashCode;

  @override
  String toString() {
    return 'DeviceInfo{deviceModel: $deviceModel}';
  }

  DeviceInfo copyWith({String? deviceModel}) {
    return DeviceInfo(
      deviceModel: deviceModel ?? this.deviceModel,
    );
  }
}
