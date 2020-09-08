import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wiredash/src/capture/capture.dart';
import 'package:wiredash/src/feedback/data/feedback_item.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';

import '../mocks.dart';

void main() {
  group('FeedbackModel', () {
    MockGlobalKey<CaptureState> mockCaptureKey;
    MockGlobalKey<NavigatorState> mockNavigatorKey;
    MockUserManager mockUserManager;
    MockBuildInfoManager mockBuildInfoManager;
    MockBuildInfo mockBuildInfo;
    MockRetryingFeedbackSubmitter mockRetryingFeedbackSubmitter;
    FeedbackModel model;

    setUp(() {
      mockCaptureKey = MockGlobalKey();
      mockNavigatorKey = MockGlobalKey();
      mockUserManager = MockUserManager();
      mockBuildInfoManager = MockBuildInfoManager();
      mockBuildInfo = MockBuildInfo();
      mockRetryingFeedbackSubmitter = MockRetryingFeedbackSubmitter();
      model = FeedbackModel(
        mockCaptureKey,
        mockNavigatorKey,
        mockUserManager,
        mockBuildInfoManager,
        mockRetryingFeedbackSubmitter,
      );
    });

    test('when feedbackUiState is FeedbackUiState.success, submits feedback',
        () {
      when(mockUserManager.userId).thenReturn('<user id>');
      when(mockUserManager.userEmail).thenReturn('<user email>');

      when(mockBuildInfoManager.buildInfo).thenReturn(mockBuildInfo);
      when(mockBuildInfo.deviceId).thenReturn('<device id>');

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
