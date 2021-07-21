import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wiredash/src/capture/capture.dart';
import 'package:wiredash/src/common/build_info/build_info.dart';
import 'package:wiredash/src/common/build_info/build_info_manager.dart';
import 'package:wiredash/src/common/build_info/device_id_generator.dart';
import 'package:wiredash/src/common/device_info/device_info.dart';
import 'package:wiredash/src/common/device_info/device_info_generator.dart';
import 'package:wiredash/src/common/user/user_manager.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item.dart';
import 'package:wiredash/src/feedback/data/persisted_feedback_item.dart';
import 'package:wiredash/src/feedback/data/retrying_feedback_submitter.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';

import '../util/invocation_catcher.dart';

// ignore: must_be_immutable
class MockGlobalKey<T extends State<StatefulWidget>> extends Fake
    implements GlobalKey<T> {}

class StaticDeviceInfoGenerator implements DeviceInfoGenerator {
  StaticDeviceInfoGenerator(this.deviceInfo);

  DeviceInfo deviceInfo;

  @override
  DeviceInfo generate() {
    return deviceInfo;
  }
}

class StaticBuildInfoManager implements BuildInfoManager {
  StaticBuildInfoManager(this.buildInfo);

  @override
  final BuildInfo buildInfo;

  @override
  String? buildNumberOverride;

  @override
  String? buildVersionOverride;
}

class StaticDeviceIdGenerator implements DeviceIdGenerator {
  StaticDeviceIdGenerator(String deviceId) : _deviceId = deviceId;
  final String _deviceId;

  @override
  Future<String> get deviceId async => _deviceId;
}

class MockRetryingFeedbackSubmitter extends Fake
    implements RetryingFeedbackSubmitter {
  final MethodInvocationCatcher submitInvocations =
      MethodInvocationCatcher('submit');

  @override
  Future<void> submit(PersistedFeedbackItem item, Uint8List? screenshot) async {
    submitInvocations
        .addMethodCall(namedArgs: {'item': item, 'screenshot': screenshot});
  }
}

void main() {
  group('FeedbackModel', () {
    late MockGlobalKey<CaptureState> mockCaptureKey;
    late MockGlobalKey<NavigatorState> mockNavigatorKey;
    late UserManager usermanager;
    final StaticDeviceInfoGenerator deviceInfoGenerator =
        StaticDeviceInfoGenerator(const DeviceInfo(
      pixelRatio: 1.0,
      textScaleFactor: 1.0,
      platformLocale: "en_US",
      platformSupportedLocales: ['en_US', 'de_DE'],
      platformBrightness: Brightness.dark,
      gestureInsets:
          WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
      padding: WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
      viewInsets: WiredashWindowPadding(left: 0, top: 0, right: 0, bottom: 0),
      physicalGeometry: Rect.fromLTRB(0, 0, 0, 0),
      physicalSize: Size(800, 1200),
    ));
    final StaticBuildInfoManager buildInfoManager =
        StaticBuildInfoManager(const BuildInfo(
      buildCommit: 'df321aa',
      buildNumber: '1.2.0',
      buildVersion: '42',
    ));
    final DeviceIdGenerator deviceIdGenerator = StaticDeviceIdGenerator('125');
    late MockRetryingFeedbackSubmitter mockRetryingFeedbackSubmitter;
    late FeedbackModel model;

    setUp(() {
      mockCaptureKey = MockGlobalKey();
      mockNavigatorKey = MockGlobalKey();
      usermanager = UserManager();
      mockRetryingFeedbackSubmitter = MockRetryingFeedbackSubmitter();
      model = FeedbackModel(
        mockCaptureKey,
        mockNavigatorKey,
        usermanager,
        mockRetryingFeedbackSubmitter,
        deviceInfoGenerator,
        buildInfoManager,
        deviceIdGenerator,
      );
    });

    test('when feedbackUiState is FeedbackUiState.success, submits feedback',
        () {
      usermanager.userId = '<user id>';
      usermanager.userEmail = '<user email>';

      fakeAsync((async) {
        model
          ..feedbackMessage = 'app not work pls send help'
          ..screenshot = kTransparentImage
          ..feedbackUiState = FeedbackUiState.submit;

        expect(model.loading, isTrue);
        async.flushMicrotasks();
        expect(model.loading, isFalse);

        final lastSubmit =
            mockRetryingFeedbackSubmitter.submitInvocations.latest;

        final item = lastSubmit['item']! as PersistedFeedbackItem;
        final screenshot = lastSubmit['screenshot']! as Uint8List;
        expect(item.user, '<user id>');
        expect(item.email, '<user email>');
        expect(item.deviceInfo, isNotNull);
        expect(item.appInfo, isNotNull);
        expect(item.buildInfo, isNotNull);
        expect(item.deviceId, '125');
        expect(item.message, 'app not work pls send help');
        expect(screenshot, kTransparentImage);
      });
    });
  });
}
