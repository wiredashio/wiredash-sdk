import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wiredash/src/capture/capture.dart';
import 'package:wiredash/src/common/device_info/device_info.dart';
import 'package:wiredash/src/common/device_info/device_info_generator.dart';
import 'package:wiredash/src/common/user/user_manager.dart';
import 'package:wiredash/src/feedback/data/feedback_item.dart';
import 'package:wiredash/src/feedback/data/retrying_feedback_submitter.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';

// ignore: must_be_immutable
class MockGlobalKey<T extends State<StatefulWidget>> extends Mock
    implements GlobalKey<T> {}

class MockUserManager extends Mock implements UserManager {}

class MockDeviceInfoGenerator extends Mock implements DeviceInfoGenerator {}

class MockRetryingFeedbackSubmitter extends Mock
    implements RetryingFeedbackSubmitter {}

void main() {
  group('FeedbackModel', () {
    late MockGlobalKey<CaptureState> mockCaptureKey;
    late MockGlobalKey<NavigatorState> mockNavigatorKey;
    late MockUserManager mockUserManager;
    late MockDeviceInfoGenerator mockDeviceInfoGenerator;
    late MockRetryingFeedbackSubmitter mockRetryingFeedbackSubmitter;
    late FeedbackModel model;

    setUp(() {
      mockCaptureKey = MockGlobalKey();
      mockNavigatorKey = MockGlobalKey();
      mockUserManager = MockUserManager();
      mockDeviceInfoGenerator = MockDeviceInfoGenerator();
      mockRetryingFeedbackSubmitter = MockRetryingFeedbackSubmitter();
      model = FeedbackModel(
        mockCaptureKey,
        mockNavigatorKey,
        mockUserManager,
        mockRetryingFeedbackSubmitter,
        mockDeviceInfoGenerator,
      );
    });

    test('when feedbackUiState is FeedbackUiState.success, submits feedback',
        () {
      when(mockUserManager.userId).thenReturn('<user id>');
      when(mockUserManager.userEmail).thenReturn('<user email>');

      when(mockDeviceInfoGenerator.generate()).thenReturn(
        const DeviceInfo(appVersion: 'test'),
      );

      when(mockRetryingFeedbackSubmitter.submit(any, any))
          .thenAnswer((_) async {});

      fakeAsync((async) {
        model
          ..feedbackMessage = 'app not work pls send help'
          ..screenshot = kTransparentImage
          ..feedbackUiState = FeedbackUiState.success;

        expect(model.loading, isTrue);
        async.flushMicrotasks();
        expect(model.loading, isFalse);

        final captures =
            verify(mockRetryingFeedbackSubmitter.submit(captureAny, captureAny))
                .captured;

        final item = captures[0] as FeedbackItem;
        final screenshot = captures[1] as Uint8List;
        expect(item.user, '<user id>');
        expect(item.email, '<user email>');
        expect(item.deviceInfo, isNotNull);
        expect(item.message, 'app not work pls send help');
        expect(screenshot, kTransparentImage);
      });
    });
  });
}
