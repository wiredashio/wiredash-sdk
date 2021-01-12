import 'package:test/test.dart';
import 'package:wiredash/src/common/utils/project_credential_validator.dart';

void main() {
  group('ProjectCredentialValidator', () {
    ProjectCredentialValidator validator;

    setUp(() {
      validator = const ProjectCredentialValidator();
    });

    test('throws when using the copy-pasted project id value', () {
      expect(
        () async =>
            validator.validate(projectId: 'YOUR-PROJECT-ID', secret: null),
        throwsA(
          const TypeMatcher<ArgumentError>()
              .having((e) => e.name, 'name', 'projectId')
              .having(
                (e) => e.message,
                'message',
                'It seems like you forgot to add the projectId from your Wiredash console in your Wiredash widget.',
              ),
        ),
      );
    });

    test('throws when using the copy-pasted secret value', () {
      expect(
        () async => validator.validate(projectId: null, secret: 'YOUR-SECRET'),
        throwsA(
          const TypeMatcher<ArgumentError>()
              .having((e) => e.name, 'name', 'secret')
              .having(
                (e) => e.message,
                'message',
                'It seems like you forgot to add the secret from your Wiredash console in your Wiredash widget.',
              ),
        ),
      );
    });
  });
}
