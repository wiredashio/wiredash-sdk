import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/common/utils/project_credential_validator.dart';
import 'package:wiredash/src/common/widgets/wirecons.dart';
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
        const Wiredash(
          projectId: 'test',
          secret: 'test',
          child: SizedBox(),
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
          const Wiredash(
            projectId: 'my-project-id',
            secret: 'my-secret',
            child: SizedBox(),
          ),
        );

        validator.validateInvocations.verifyInvocationCount(1);
        final lastCall = validator.validateInvocations.latest;
        expect(lastCall['projectId'], 'my-project-id');
        expect(lastCall['secret'], 'my-secret');
      },
    );

    testWidgets('Send feedback with screenshot', (tester) async {
      await tester.pumpWidget(
        Wiredash(
          projectId: 'test',
          secret: 'test',
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  floatingActionButton: FloatingActionButton(
                    onPressed: Wiredash.of(context).show,
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
      await tester.waitUntil(
        find.byIcon(Wirecons.arrow_narrow_right),
        findsOneWidget,
      );
      expect(find.byIcon(Wirecons.arrow_narrow_right), findsOneWidget);
      expect(find.byIcon(Wirecons.chevron_double_up), findsOneWidget);
      // next to screenshot overview
      await tester.tap(find.byIcon(Wirecons.arrow_narrow_right));
      await tester.pumpHardAndSettle();

      // Go to screenshot section
      await tester.tap(find.byIcon(Wirecons.arrow_narrow_right));
      await tester.waitUntil(find.byIcon(Wirecons.camera), findsOneWidget);
      // TODO check app is interactive

      // Click the screenshot button
      await tester.tap(find.byIcon(Wirecons.camera));
      await tester.pumpAndSettle();

      // Wait for edit screen
      await tester.waitUntil(find.byIcon(Wirecons.check), findsOneWidget);

      // Check for save screenshot button
      expect(find.byIcon(Wirecons.check), findsOneWidget);
      expect(find.byIcon(Wirecons.pencil), findsOneWidget);

      await tester.tap(find.byIcon(Wirecons.check));
      await tester.pumpAndSettle();

      await tester.waitUntil(
        find.byIcon(Wirecons.arrow_narrow_right),
        findsOneWidget,
      );

      // TODO check that we see the screenshot
      await tester.tap(find.byIcon(Wirecons.arrow_narrow_right));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'dash@wiredash.io');
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.byIcon(Wirecons.check));
      await tester.pumpAndSettle();
      await tester.waitUntil(
        find.text('Thanks for your feedback!'),
        findsOneWidget,
      );
    });
  });

  testWidgets('Send feedback with labels and screenshot', (tester) async {
    await tester.pumpWidget(
      Wiredash(
        projectId: 'test',
        secret: 'test',
        feedbackOptions: const WiredashFeedbackOptions(
          labels: [
            Label(id: 'lbl-1', title: 'One', description: 'First'),
            Label(id: 'lbl-2', title: 'Two', description: 'Second'),
          ],
        ),
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                floatingActionButton: FloatingActionButton(
                  onPressed: Wiredash.of(context).show,
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
    await tester.waitUntil(
      find.byIcon(Wirecons.arrow_narrow_right),
      findsOneWidget,
    );
    expect(find.byIcon(Wirecons.arrow_narrow_right), findsOneWidget);
    expect(find.byIcon(Wirecons.chevron_double_up), findsOneWidget);

    await tester.tap(find.byIcon(Wirecons.arrow_narrow_right));
    await tester.pumpHardAndSettle();
    // Check labels exist
    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);

    // screenshot overview
    await tester.tap(find.byIcon(Wirecons.arrow_narrow_right));
    await tester.pumpHardAndSettle();

    // Go to screenshot section
    await tester.tap(find.byIcon(Wirecons.arrow_narrow_right));
    await tester.waitUntil(find.byIcon(Wirecons.camera), findsOneWidget);
    // TODO check app is interactive

    // Click the screenshot button
    await tester.tap(find.byIcon(Wirecons.camera));
    await tester.pumpAndSettle();

    // Wait for edit screen
    await tester.waitUntil(find.byIcon(Wirecons.check), findsOneWidget);

    // Check for save screenshot button
    expect(find.byIcon(Wirecons.check), findsOneWidget);
    expect(find.byIcon(Wirecons.pencil), findsOneWidget);

    await tester.tap(find.byIcon(Wirecons.check));
    await tester.pumpAndSettle();

    await tester.waitUntil(
      find.byIcon(Wirecons.arrow_narrow_right),
      findsOneWidget,
    );

    // TODO check that we see the screenshot
    await tester.tap(find.byIcon(Wirecons.arrow_narrow_right));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'dash@wiredash.io');
    await tester.pumpAndSettle();

    // Submit
    await tester.tap(find.byIcon(Wirecons.check));
    await tester.pumpAndSettle();
    await tester.waitUntil(
      find.text('Thanks for your feedback!'),
      findsOneWidget,
    );
  });
}

extension on WidgetTester {
  /// Pumps and also drains the event queue, then pumps again and settles
  Future<void> pumpHardAndSettle() async {
    await pumpAndSettle();
    // pump event queue, trigger timers
    await runAsync(() => Future.delayed(const Duration(milliseconds: 1)));
    await pumpAndSettle();
  }

  Future<void> waitUntil(
    Finder finder,
    Matcher matcher, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final start = DateTime.now();
    await pumpAndSettle();
    // ignore: literal_only_boolean_expressions
    while (true) {
      if (matcher.matches(finder, {})) {
        break;
      }

      final now = DateTime.now();
      if (now.isAfter(start..add(timeout))) {
        throw 'Did not find $finder after $timeout';
      }

      // ignore: avoid_print
      print('Waiting for\n\tFinder: $finder to match\n\tMatcher: $matcher');
      await pumpHardAndSettle();
    }
  }
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
