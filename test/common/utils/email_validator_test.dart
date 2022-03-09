import 'package:test/test.dart';
import 'package:wiredash/src/utils/email_validator.dart';

void main() {
  group('EmailValidator', () {
    late EmailValidator validator;

    setUp(() {
      validator = const EmailValidator();
    });

    test('valid emails', () {
      expect(validator.validate('test@example.com'), true);
      expect(validator.validate('TEST@exSMAo.COM'), true);
      expect(validator.validate('dash@wiredash.io'), true);
      expect(validator.validate('hey.ho@gmail.com'), true);
      expect(validator.validate('no_reply@phntm.xyz'), true);
      expect(validator.validate('no_reply@spitch.live'), true);
    });

    test('invalid emails', () {
      expect(validator.validate('test@example.'), false);
      expect(validator.validate('TEST@exSMAocom'), false);
      expect(validator.validate('wiredash.io'), false);
      expect(validator.validate('@gmail.com'), false);
      expect(validator.validate('frank'), false);
      expect(validator.validate(''), false);
    });
  });
}
