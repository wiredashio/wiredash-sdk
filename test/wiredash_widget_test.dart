import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wiredash/src/common/utils/project_credential_validator.dart';
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
  });
}
