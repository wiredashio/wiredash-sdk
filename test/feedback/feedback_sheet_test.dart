import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wiredash/src/common/options/wiredash_options.dart';
import 'package:wiredash/src/common/options/wiredash_options_data.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/theme/wiredash_theme_data.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/feedback/feedback_sheet.dart';
import 'package:wiredash/wiredash.dart';

class MockFeedbackModel extends Mock implements FeedbackModel {}

void main() {
  group('FeedbackSheet', () {
    MockFeedbackModel mockFeedbackModel;

    setUp(() {
      mockFeedbackModel = MockFeedbackModel();
    });

    testWidgets(
      'displays error message when submitting blank feedback',
      (tester) async {
        when(mockFeedbackModel.feedbackUiState)
            .thenReturn(FeedbackUiState.feedback);
        when(mockFeedbackModel.loading).thenReturn(false);

        await tester.pumpWidget(
          _TestBoilerplate(
            feedbackModel: mockFeedbackModel,
            child: const FeedbackSheet(),
          ),
        );

        await tester.enterText(
          find.byKey(const ValueKey('wiredash.sdk.feedback_input_field')),
          '        ',
        );

        await tester.tap(
            find.byKey(const ValueKey('wiredash.sdk.save_feedback_button')));
        await tester.pump();

        expect(find.text('Please provide your feedback.'), findsOneWidget);
        verifyNever(mockFeedbackModel.feedbackUiState = FeedbackUiState.email);
      },
    );

    testWidgets(
      'goes to email step when submitting non-empty feedback',
      (tester) async {
        when(mockFeedbackModel.feedbackUiState)
            .thenReturn(FeedbackUiState.feedback);
        when(mockFeedbackModel.loading).thenReturn(false);

        await tester.pumpWidget(
          _TestBoilerplate(
            feedbackModel: mockFeedbackModel,
            child: const FeedbackSheet(),
          ),
        );

        await tester.enterText(
          find.byKey(const ValueKey('wiredash.sdk.feedback_input_field')),
          'amazing game!! 0/5 stars I love it',
        );

        await tester.tap(
            find.byKey(const ValueKey('wiredash.sdk.save_feedback_button')));
        await tester.pump();

        expect(find.text('Please provide your feedback.'), findsNothing);
        verify(mockFeedbackModel.feedbackUiState = FeedbackUiState.email);
      },
    );
  });
}

class _TestBoilerplate extends StatelessWidget {
  const _TestBoilerplate({
    Key key,
    @required this.feedbackModel,
    @required this.child,
  })  : assert(feedbackModel != null),
        assert(child != null),
        super(key: key);

  final FeedbackModel feedbackModel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WiredashTheme(
      data: WiredashThemeData(),
      child: WiredashOptions(
        data: WiredashOptionsData(
          locale: const Locale('en', 'US'),
        ),
        child: WiredashLocalizations(
          child: ChangeNotifierProvider<FeedbackModel>.value(
            value: feedbackModel,
            child: MaterialApp(
              locale: const Locale('en', 'US'),
              home: ChangeNotifierProvider<FeedbackModel>.value(
                value: feedbackModel,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
