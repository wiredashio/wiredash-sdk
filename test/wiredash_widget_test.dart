import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/fake.dart';
import 'package:wiredash/src/capture/capture.dart';
import 'package:wiredash/src/common/utils/project_credential_validator.dart';
import 'package:wiredash/src/feedback/feedback_sheet.dart';
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

    testWidgets(
        'only one feedback flow will be launched at a time - intro mode',
        (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      WiredashController? controller;

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
              return child!;
            },
          ),
        ),
      );

      expect(controller, isNotNull);
      expect(find.byType(FeedbackSheet), findsNothing);

      // Calling controller.show() once should bring out the FeedbackSheet.
      controller!.show();
      await tester.pump();
      await tester.pump();
      expect(find.byType(FeedbackSheet), findsOneWidget);

      // Further calls to controller.show() should not bring out additional
      // FeedbackSheets - there should still be only one.
      controller!.show();
      controller!.show();
      controller!.show();
      await tester.pump();
      await tester.pump();
      expect(find.byType(FeedbackSheet), findsOneWidget);

      // Hide the FeedbackSheet
      navigatorKey.currentState!.pop();
      await tester.pump();
      expect(find.byType(FeedbackSheet), findsNothing);

      // Calling controller.show() should bring out a FeedbackSheet normally.
      controller!.show();
      await tester.pump();
      await tester.pump();
      expect(find.byType(FeedbackSheet), findsOneWidget);
    });

    testWidgets(
        'only one feedback flow will be launched at a time - in capture mode',
        (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        Wiredash(
          projectId: 'test',
          secret: 'test',
          navigatorKey: navigatorKey,
          child: MaterialApp(
            home: Builder(builder: (context) {
              return Scaffold(
                floatingActionButton: FloatingActionButton(
                  onPressed: Wiredash.of(context)!.show,
                ),
              );
            }),
            navigatorKey: navigatorKey,
          ),
        ),
      );

      expect(find.byType(FeedbackSheet), findsNothing);

      // Open the FeedbackSheet.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(FeedbackSheet), findsOneWidget);

      // Go to capture mode
      await tester.tap(
          find.byKey(const ValueKey('wiredash.sdk.intro.report_a_bug_button')));
      await tester.pumpAndSettle();
      expect(find.byType(Capture), findsOneWidget);

      // Tapping the FeedbackSheet again does nothing
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      // FeedbackSheet doesn't open
      expect(find.byType(FeedbackSheet), findsNothing);
    });
  });
}

class _MockProjectCredentialValidator extends Fake
    implements ProjectCredentialValidator {
  final MethodInvocationCatcher validateInvocations =
      MethodInvocationCatcher('validate');

  @override
  Future<void> validate(
      {required String projectId, required String secret}) async {
    await validateInvocations.addAsyncMethodCall(
        namedArgs: {'projectId': projectId, 'secret': secret})?.value;
  }
}
