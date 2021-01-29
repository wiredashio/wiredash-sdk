import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiredash/src/common/network/wiredash_api.dart';
import 'package:wiredash/src/common/options/wiredash_options.dart';
import 'package:wiredash/src/common/options/wiredash_options_data.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/theme/wiredash_theme_data.dart';
import 'package:wiredash/src/common/user/user_manager.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/feedback/feedback_sheet.dart';
import 'package:wiredash/src/wiredash_provider.dart';
import 'package:wiredash/wiredash.dart';
import 'package:test/fake.dart';

import '../util/invocation_catcher.dart';

void main() {
  final findFeedbackInputField =
      find.byKey(const ValueKey('wiredash.sdk.feedback_input_field'));
  final findSaveButton =
      find.byKey(const ValueKey('wiredash.sdk.save_feedback_button'));
  final findEmailInput =
      find.byKey(const ValueKey('wiredash.sdk.email_input_field'));
  final findFeedbackButton =
      find.byKey(const ValueKey('wiredash.sdk.send_feedback_button'));

  group('FeedbackSheet', () {
    late MockFeedbackModel mockFeedbackModel;
    late MockUserManager mockUserManager;
    late MockNetworkManager mockNetworkManager;

    setUp(() {
      mockFeedbackModel = MockFeedbackModel();
      mockUserManager = MockUserManager();
      mockNetworkManager = MockNetworkManager();
    });

    testWidgets(
      'displays error message when submitting blank feedback',
      (tester) async {
        await tester.pumpWidget(
          _TestBoilerplate(
            feedbackModel: mockFeedbackModel,
            userManager: mockUserManager,
            networkManager: mockNetworkManager,
            child: const FeedbackSheet(),
          ),
        );

        await tester.enterText(findFeedbackInputField, '        ');

        await tester.tap(findSaveButton);
        await tester.pump();

        expect(find.text('Please provide your feedback.'), findsOneWidget);
        expect(mockFeedbackModel.feedbackUiState, FeedbackUiState.feedback);
        mockFeedbackModel.feedbackUiStateInvocations.verifyHasNoInvocation();
      },
    );

    testWidgets(
      'displays counter & error message when submitting too long feedback',
      (tester) async {
        await tester.pumpWidget(
          _TestBoilerplate(
            feedbackModel: mockFeedbackModel,
            userManager: mockUserManager,
            networkManager: mockNetworkManager,
            child: const SingleChildScrollView(
              child: FeedbackSheet(),
            ),
          ),
        );
        await tester.enterText(findFeedbackInputField, 'a'.padLeft(2049, 'a'));
        await tester.pumpAndSettle();
        expect(find.text('2049 / 2048'), findsOneWidget);

        await tester.scrollUntilVisible(findSaveButton, 100,
            scrollable: find.byType(Scrollable).first);
        await tester.tap(findSaveButton);
        await tester.pump();

        expect(find.text('Your feedback is too long.'), findsOneWidget);
        expect(mockFeedbackModel.feedbackUiState, FeedbackUiState.feedback);
        mockFeedbackModel.feedbackUiStateInvocations.verifyHasNoInvocation();
      },
    );

    testWidgets(
      'displays counter when close to max input length',
      (tester) async {
        await tester.pumpWidget(
          _TestBoilerplate(
            feedbackModel: mockFeedbackModel,
            userManager: mockUserManager,
            networkManager: mockNetworkManager,
            child: const SingleChildScrollView(
              child: FeedbackSheet(),
            ),
          ),
        );

        await tester.enterText(findFeedbackInputField, 'a'.padLeft(2040, 'a'));
        await tester.pumpAndSettle();
        expect(find.text('2040 / 2048'), findsOneWidget);

        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(mockFeedbackModel.feedbackUiState, FeedbackUiState.feedback);
        mockFeedbackModel.feedbackUiStateInvocations.verifyHasNoInvocation();
      },
    );

    testWidgets(
      'goes to email step when submitting non-empty feedback',
      (tester) async {
        await tester.pumpWidget(
          _TestBoilerplate(
            feedbackModel: mockFeedbackModel,
            userManager: mockUserManager,
            networkManager: mockNetworkManager,
            child: const FeedbackSheet(),
          ),
        );

        await tester.enterText(
            findFeedbackInputField, 'amazing game!! 0/5 stars I love it');

        await tester.tap(findSaveButton);
        await tester.pump();

        expect(find.text('Please provide your feedback.'), findsNothing);
        expect(mockFeedbackModel.feedbackUiState, FeedbackUiState.email);
      },
    );

    testWidgets(
      'displays error message when email validation does not pass',
      (tester) async {
        mockFeedbackModel.feedbackUiState = FeedbackUiState.email;
        mockFeedbackModel.feedbackUiStateInvocations.clear();

        await tester.pumpWidget(
          _TestBoilerplate(
            feedbackModel: mockFeedbackModel,
            userManager: mockUserManager,
            networkManager: mockNetworkManager,
            child: const FeedbackSheet(),
          ),
        );

        await tester.enterText(findEmailInput, '<does not matter>');

        await tester.tap(findFeedbackButton);
        await tester.pump();

        expect(
          find.text('Please enter a valid email or leave this field blank.'),
          findsOneWidget,
        );

        expect(mockFeedbackModel.feedbackUiState, FeedbackUiState.email);
        mockFeedbackModel.feedbackUiStateInvocations.verifyHasNoInvocation();
      },
    );

    testWidgets(
      'goes to success step when email validation passes',
      (tester) async {
        mockFeedbackModel.feedbackUiState = FeedbackUiState.email;

        await tester.pumpWidget(
          _TestBoilerplate(
            feedbackModel: mockFeedbackModel,
            userManager: mockUserManager,
            networkManager: mockNetworkManager,
            child: const FeedbackSheet(),
          ),
        );

        await tester.enterText(findEmailInput, 'valid@email.address');

        await tester.tap(findFeedbackButton);
        await tester.pump();

        expect(
          find.text('Please enter a valid email or leave this field blank.'),
          findsNothing,
        );

        expect(mockFeedbackModel.feedbackUiState, FeedbackUiState.success);
      },
    );
  });
}

class _TestBoilerplate extends StatelessWidget {
  const _TestBoilerplate({
    Key? key,
    required this.networkManager,
    required this.feedbackModel,
    required this.userManager,
    required this.child,
  }) : super(key: key);

  final WiredashApi networkManager;
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
          child: WiredashProvider(
            userManager: userManager,
            feedbackModel: feedbackModel,
            child: MaterialApp(
              locale: const Locale('en', 'US'),
              home: child,
            ),
          ),
        ),
      ),
    );
  }
}

class MockFeedbackModel extends Fake
    with ChangeNotifier
    implements FeedbackModel {
  @override
  bool get loading => false;

  final MethodInvocationCatcher feedbackUiStateInvocations =
      MethodInvocationCatcher('set feedbackUiState');
  @override
  FeedbackUiState _feedbackUiState = FeedbackUiState.feedback;

  FeedbackUiState get feedbackUiState => _feedbackUiState;

  set feedbackUiState(FeedbackUiState feedbackUiState) {
    _feedbackUiState = feedbackUiState;
    feedbackUiStateInvocations.addMethodCall(args: [feedbackUiState]);
  }

  @override
  String? feedbackMessage;
}

class MockUserManager extends Fake implements UserManager {
  @override
  String? userEmail;
}

class MockNetworkManager extends Fake implements WiredashApi {}
