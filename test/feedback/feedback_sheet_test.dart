import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wiredash/src/common/options/wiredash_options.dart';
import 'package:wiredash/src/common/options/wiredash_options_data.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/theme/wiredash_theme_data.dart';
import 'package:wiredash/src/common/user/user_manager.dart';
import 'package:wiredash/src/common/utils/email_validator.dart';
import 'package:wiredash/src/feedback/components/input_component.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/feedback/feedback_sheet.dart';
import 'package:wiredash/wiredash.dart';

class MockFeedbackModel extends Mock implements FeedbackModel {}

class MockUserManager extends Mock implements UserManager {}

class MockEmailValidator extends Mock implements EmailValidator {}

void main() {
  group('FeedbackSheet', () {
    MockFeedbackModel mockFeedbackModel;
    MockUserManager mockUserManager;
    MockEmailValidator mockEmailValidator;

    setUp(() {
      mockFeedbackModel = MockFeedbackModel();
      mockUserManager = MockUserManager();
      mockEmailValidator = MockEmailValidator();
      debugEmailValidator = mockEmailValidator;
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
            userManager: mockUserManager,
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
            userManager: mockUserManager,
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

    testWidgets(
      'displays error message when email validation does not pass',
      (tester) async {
        when(mockFeedbackModel.feedbackUiState)
            .thenReturn(FeedbackUiState.email);
        when(mockFeedbackModel.loading).thenReturn(false);
        when(mockEmailValidator.validate(any)).thenReturn(false);

        await tester.pumpWidget(
          _TestBoilerplate(
            feedbackModel: mockFeedbackModel,
            userManager: mockUserManager,
            child: const FeedbackSheet(),
          ),
        );

        await tester.enterText(
          find.byKey(const ValueKey('wiredash.sdk.email_input_field')),
          '<does not matter>',
        );

        await tester.tap(
            find.byKey(const ValueKey('wiredash.sdk.send_feedback_button')));
        await tester.pump();

        expect(
          find.text('Please enter a valid email or leave this field blank.'),
          findsOneWidget,
        );

        verifyNever(
          mockFeedbackModel.feedbackUiState = FeedbackUiState.success,
        );
      },
    );

    testWidgets(
      'goes to success step when email validation passes',
      (tester) async {
        when(mockFeedbackModel.feedbackUiState)
            .thenReturn(FeedbackUiState.email);
        when(mockFeedbackModel.loading).thenReturn(false);
        when(mockEmailValidator.validate(any)).thenReturn(true);

        await tester.pumpWidget(
          _TestBoilerplate(
            feedbackModel: mockFeedbackModel,
            userManager: mockUserManager,
            child: const FeedbackSheet(),
          ),
        );

        await tester.enterText(
          find.byKey(const ValueKey('wiredash.sdk.email_input_field')),
          '<does not matter>',
        );

        await tester.tap(
            find.byKey(const ValueKey('wiredash.sdk.send_feedback_button')));
        await tester.pump();

        expect(
          find.text('Please enter a valid email or leave this field blank.'),
          findsNothing,
        );

        verify(mockFeedbackModel.feedbackUiState = FeedbackUiState.success);
      },
    );
  });
}

class _TestBoilerplate extends StatelessWidget {
  const _TestBoilerplate({
    Key key,
    @required this.feedbackModel,
    @required this.userManager,
    @required this.child,
  })  : assert(feedbackModel != null),
        assert(userManager != null),
        assert(child != null),
        super(key: key);

  final FeedbackModel feedbackModel;
  final UserManager userManager;
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
          child: MultiProvider(
            providers: [
              Provider<UserManager>.value(value: userManager),
              ChangeNotifierProvider<FeedbackModel>.value(value: feedbackModel),
            ],
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
