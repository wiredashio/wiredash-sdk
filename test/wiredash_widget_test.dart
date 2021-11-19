import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/fake.dart';
import 'package:wiredash/src/common/utils/project_credential_validator.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';
import 'package:wiredash/src/feedback/ui/big_blue_button.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';
import 'package:wiredash/src/wiredash_widget.dart';
import 'package:wiredash/wiredash.dart';

import 'util/invocation_catcher.dart';

void main() {
  group('Wiredash', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
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
        final _MockProjectCredentialValidator validator =
            _MockProjectCredentialValidator();
        debugProjectCredentialValidator = validator;
        addTearDown(() {
          debugProjectCredentialValidator = const ProjectCredentialValidator();
        });

        await tester.pumpWidget(
          Wiredash(
            projectId: 'my-project-id',
            secret: 'my-secret',
            navigatorKey: GlobalKey<NavigatorState>(),
            child: const SizedBox(),
          ),
        );

        validator.validateInvocations.verifyInvocationCount(1);
        final lastCall = validator.validateInvocations.latest;
        expect(lastCall['projectId'], 'my-project-id');
        expect(lastCall['secret'], 'my-secret');
      },
    );

    testWidgets('Capture a screenshot', (tester) async {
      await tester.pumpWidget(
        Wiredash(
          projectId: 'test',
          secret: 'test',
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  floatingActionButton: FloatingActionButton(
                    onPressed: Wiredash.of(context)!.show,
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(WiredashFeedbackFlow), findsNothing);

      // Open Wiredash
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(WiredashFeedbackFlow), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'asdfasdf');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(BigBlueButton));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Click the screenshot button
      await tester.tap(find.byIcon(WiredashIcons.screenshotAction));

      final saveScreenshotButtonFinder = find.byIcon(WiredashIcons.check);

      while (saveScreenshotButtonFinder.evaluate().isEmpty) {
        // Wait for screenshot (in real time until calculation is done)
        await tester
            .runAsync(() => Future.delayed(const Duration(milliseconds: 200)));
        await tester.pumpAndSettle();
      }

      // Check for save screenshot button
      expect(saveScreenshotButtonFinder, findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  });
}

class _MockProjectCredentialValidator extends Fake
    implements ProjectCredentialValidator {
  final MethodInvocationCatcher validateInvocations =
      MethodInvocationCatcher('validate');

  @override
  Future<void> validate({
    required String projectId,
    required String secret,
  }) async {
    validateInvocations
        .addMethodCall(namedArgs: {'projectId': projectId, 'secret': secret});
  }
}
