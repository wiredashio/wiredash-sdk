import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/fake.dart';
import 'package:wiredash/src/common/utils/project_credential_validator.dart';
import 'package:wiredash/src/common/widgets/wirecons.dart';
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
      await tester.waitUntil(find.byType(BigBlueButton), findsOneWidget);

      await tester.tap(find.byType(BigBlueButton));
      await tester.pumpHardAndSettle();
      await tester.waitUntil(find.text('Skip'), findsOneWidget);

      await tester.tap(find.text('Skip'));
      await tester.pumpHardAndSettle();
      await tester.waitUntil(find.text('Skip'), findsOneWidget);

      await tester.tap(find.text('Skip'));
      await tester.pumpHardAndSettle();
      await tester.waitUntil(find.text('Yes'), findsOneWidget);

      await tester.tap(find.text('Yes'));
      await tester.pumpHardAndSettle();

      // Click the screenshot button
      await tester.tap(find.byIcon(Wirecons.camera));
      await tester.pumpAndSettle();
      await tester.waitUntil(find.byIcon(Wirecons.check), findsOneWidget);

      // Check for save screenshot button
      expect(find.byIcon(Wirecons.check), findsOneWidget);
    });
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

  Future<void> waitUntil(Finder finder, Matcher matcher) async {
    await pumpAndSettle();
    // ignore: literal_only_boolean_expressions
    while (true) {
      if (matcher.matches(finder, {})) {
        break;
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
