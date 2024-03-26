import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
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
/// This class is stateless, all state is cached/stored in [WiredashModel]
class MetaDataCollector {
  MetaDataCollector({
    required this.deviceInfoCollector,
    required this.buildInfoProvider,
  });

  final FlutterInfoCollector Function() deviceInfoCollector;
  final BuildInfo Function() buildInfoProvider;

  /// In-memory cache for fixed metadata
  FixedMetaData? fixedMetaData;

  /// Collects all metadata that is pretty much static for the current session
  Future<FixedMetaData> collectFixedMetaData() async {
    final cache = fixedMetaData;
    if (cache != null) {
      return fixedMetaData!;
    }

    final results = await Future.wait(
      [
        _collectAppInfo(),
        _collectDeviceInfo(),
        Future.sync(buildInfoProvider),
      ].map((Future<Object> future) {
        return future.then<Object?>((value) => value);
      }).map((e) {
        return e.timeout(const Duration(seconds: 1)).catchError(
          (Object e, StackTrace stack) {
            reportWiredashInfo(
              e,
              stack,
              'Could not collect metadata',
            );
            // ignore: avoid_redundant_argument_values
            return Future.value(null);
          },
        );
      }),
    );
    final appInfo = results[0] as AppInfo?;
    final deviceInfo = results[1] as DeviceInfo?;
    final buildInfo = results[2] as BuildInfo?;

    final combined = FixedMetaData(
      appInfo: appInfo ?? const AppInfo(),
      deviceInfo: deviceInfo ?? const DeviceInfo(),
      buildInfo: buildInfo ??
          const BuildInfo(compilationMode: CompilationMode.profile),
    );

    fixedMetaData = combined;
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
      reportWiredashInfo(e, stack, 'Failed to collect package info');
    }

    return appInfo;
  }

  /// Synchronously collect all information from the FlutterWindow / FlutterView
  FlutterInfo collectFlutterInfo() {
    return deviceInfoCollector().capture();
  }

  Future<DeviceInfo> _collectDeviceInfo() async {
    if (!kIsWeb && Platform.isLinux) {
      // it just hangs on linux for some reason
      // https://github.com/fluttercommunity/plus_plugins/issues/1552
      return const DeviceInfo();
    }

    try {
      final deviceInfo = await DeviceInfoPlugin().deviceInfo;

      if (deviceInfo is MacOsDeviceInfo) {
        String? version;
        try {
          // stay backwards compatible with older versions of device_info_plus:8.0.0
          // which did not have the version properties
          final dynamic dynamicDeviceInfo = deviceInfo;
          // ignore: avoid_dynamic_calls
          version = "${dynamicDeviceInfo.majorVersion}."
              // ignore: avoid_dynamic_calls
              "${dynamicDeviceInfo.minorVersion}."
              // ignore: avoid_dynamic_calls
              "${dynamicDeviceInfo.patchVersion}";
        } catch (e) {
          // ignore
        }
        return DeviceInfo(
          deviceModel: deviceInfo.model,
          osVersion: version,
        );
      }
      if (deviceInfo is IosDeviceInfo) {
        return DeviceInfo(
          deviceModel: deviceInfo.model,
          osVersion: deviceInfo.systemVersion,
        );
      }
      if (deviceInfo is AndroidDeviceInfo) {
        return DeviceInfo(
          deviceModel: deviceInfo.model,
          osVersion: deviceInfo.version.release,
        );
      }
      if (deviceInfo is LinuxDeviceInfo) {
        return DeviceInfo(
          osVersion: deviceInfo.version,
        );
      }
      if (deviceInfo is WindowsDeviceInfo) {
        String? version;
        try {
          version = "${deviceInfo.majorVersion}.${deviceInfo.minorVersion}";
        } catch (e) {
          // ignore
        }
        return DeviceInfo(
          osVersion: version,
        );
      }

      // there's not way to get the model of windows or linux devices
    } catch (e, stack) {
      const issue1552 =
          "type 'BaseDeviceInfo' is not a subtype of type 'LinuxDeviceInfo' in type cast";
      if (e.toString().contains(issue1552)) {
        // ignore, will be fixed in an upcoming device_info_plus release
        // https://github.com/fluttercommunity/plus_plugins/issues/1552
        return const DeviceInfo();
      }

      reportWiredashInfo(
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
typedef CustomMetaDataCollector = Future<CustomizableWiredashMetaData> Function(
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

  String? get resolvedBuildVersion {
    final fromBuildInfo = buildInfo.buildVersion;
    if (fromBuildInfo != null && fromBuildInfo.isNotEmpty) {
      return fromBuildInfo;
    }
    return appInfo.version;
  }

  String? get resolvedBuildNumber {
    final fromBuildInfo = buildInfo.buildNumber;
    if (fromBuildInfo != null && fromBuildInfo.isNotEmpty) {
      return fromBuildInfo;
    }
    return appInfo.buildNumber;
  }

  String? get resolvedBuildCommit {
    final commit = buildInfo.buildCommit;
    if (commit != null && commit.isNotEmpty) {
      return commit;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FixedMetaData &&
          runtimeType == other.runtimeType &&
          deviceInfo == other.deviceInfo &&
          buildInfo == other.buildInfo &&
          appInfo == other.appInfo;

  @override
  int get hashCode =>
      deviceInfo.hashCode ^ buildInfo.hashCode ^ appInfo.hashCode;
}

/// Information about the device the user is using
class DeviceInfo {
  final String? deviceModel;
  final String? osVersion;

  const DeviceInfo({
    this.deviceModel,
    this.osVersion,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceInfo &&
          runtimeType == other.runtimeType &&
          deviceModel == other.deviceModel &&
          osVersion == other.osVersion);

  @override
  int get hashCode => deviceModel.hashCode ^ osVersion.hashCode;

  @override
  String toString() {
    return 'DeviceInfo{ '
        'deviceModel: $deviceModel, '
        'osVersion: $osVersion, '
        '}';
  }

  DeviceInfo copyWith({
    String? deviceModel,
    String? osVersion,
  }) {
    return DeviceInfo(
      deviceModel: deviceModel ?? this.deviceModel,
      osVersion: osVersion ?? this.osVersion,
    );
  }
}
