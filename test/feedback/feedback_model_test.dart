import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wiredash/src/common/device_info/device_info.dart';
import 'package:wiredash/src/common/device_info/device_info_generator.dart';
import 'package:wiredash/src/common/user/user_manager.dart';
import 'package:wiredash/src/feedback/data/feedback_item.dart';
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

class MockRetryingFeedbackSubmitter extends Fake
    implements RetryingFeedbackSubmitter {
  final MethodInvocationCatcher submitInvocations =
      MethodInvocationCatcher('submit');
  @override
  Future<void> submit(FeedbackItem item, Uint8List? screenshot) async {
    submitInvocations
        .addMethodCall(namedArgs: {'item': item, 'screenshot': screenshot});
  }
}

void main() {
  group('FeedbackModel', () {
    late MockGlobalKey<NavigatorState> mockNavigatorKey;
    late UserManager usermanager;
    final StaticDeviceInfoGenerator deviceInfoGenerator =
        StaticDeviceInfoGenerator(const DeviceInfo(appVersion: 'test'));
    late MockRetryingFeedbackSubmitter mockRetryingFeedbackSubmitter;
    late FeedbackModel model;

    setUp(() {
      mockNavigatorKey = MockGlobalKey();
      usermanager = UserManager();
      mockRetryingFeedbackSubmitter = MockRetryingFeedbackSubmitter();
      model = FeedbackModel(
        mockNavigatorKey,
        usermanager,
        mockRetryingFeedbackSubmitter,
        deviceInfoGenerator,
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

        final item = lastSubmit['item']! as FeedbackItem;
        final screenshot = lastSubmit['screenshot']! as Uint8List;
        expect(item.user, '<user id>');
        expect(item.email, '<user email>');
        expect(item.deviceInfo, isNotNull);
        expect(item.message, 'app not work pls send help');
        expect(screenshot, kTransparentImage);
      });
    });
  });
}
