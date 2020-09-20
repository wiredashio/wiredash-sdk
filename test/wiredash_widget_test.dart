import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wiredash/src/common/utils/project_credential_validator.dart';
import 'package:wiredash/src/feedback/feedback_sheet.dart';
import 'package:wiredash/src/wiredash_widget.dart';
import 'package:wiredash/wiredash.dart';

class MockProjectCredentialValidator extends Mock
    implements ProjectCredentialValidator {}

void main() {
  group('Wiredash', () {
    MockProjectCredentialValidator mockProjectCredentialValidator;

    setUp(() {
      mockProjectCredentialValidator = MockProjectCredentialValidator();
      debugProjectCredentialValidator = mockProjectCredentialValidator;
    });

    tearDown(() {
      debugProjectCredentialValidator = const ProjectCredentialValidator();
    });

    testWidgets('widget can be created', (tester) async {
      await tester.pumpWidget(
        Wiredash(
          projectId: 'test',
          secret: 'test',
          navigatorKey: GlobalKey<NavigatorState>(),
          child: const SizedBox(),
        ),
      );

      expect(find.byType(Wiredash), findsOneWidget);
    });

    testWidgets(
      'calls ProjectCredentialValidator.validate() initially',
      (tester) async {
        await tester.pumpWidget(
          Wiredash(
            projectId: 'my-project-id',
            secret: 'my-secret',
            navigatorKey: GlobalKey<NavigatorState>(),
            child: const SizedBox(),
          ),
        );

        verify(
          mockProjectCredentialValidator.validate(
            projectId: 'my-project-id',
            secret: 'my-secret',
          ),
        );
        verifyNoMoreInteractions(mockProjectCredentialValidator);
      },
    );

    testWidgets('only one feedback flow will be launched at a time',
        (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      WiredashController controller;

      await tester.pumpWidget(
        Wiredash(
          projectId: 'test',
          secret: 'test',
          navigatorKey: navigatorKey,
          child: MaterialApp(
            home: const SizedBox(),
            navigatorKey: navigatorKey,
            builder: (context, child) {
              controller = Wiredash.of(context);
              return child;
            },
          ),
        ),
      );

      expect(controller, isNotNull);
      expect(find.byType(FeedbackSheet), findsNothing);

      // Calling controller.show() once should bring out the FeedbackSheet.
      controller.show();
      await tester.pump();
      await tester.pump();
      expect(find.byType(FeedbackSheet), findsOneWidget);

      // Further calls to controller.show() should not bring out additional
      // FeedbackSheets - there should still be only one.
      controller.show();
      controller.show();
      controller.show();
      await tester.pump();
      await tester.pump();
      expect(find.byType(FeedbackSheet), findsOneWidget);

      // Hide the FeedbackSheet
      navigatorKey.currentState.pop();
      await tester.pump();
      expect(find.byType(FeedbackSheet), findsNothing);

      // Calling controller.show() should bring out a FeedbackSheet normally.
      controller.show();
      await tester.pump();
      await tester.pump();
      expect(find.byType(FeedbackSheet), findsOneWidget);
    });
  });
}
