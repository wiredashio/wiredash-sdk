import 'package:test/test.dart';
import 'package:wiredash/src/core/wiredash_widget.dart';

void main() {
  group('env name', () {
    test('common cases', () {
      expect(() => validateEnvironment('dev'), returnsNormally);
      expect(() => validateEnvironment('prod'), returnsNormally);
      expect(() => validateEnvironment('qa'), returnsNormally);
      expect(() => validateEnvironment('staging'), returnsNormally);
    });

    test('minimum 2 characters', () {
      expect(
        () => validateEnvironment('a'),
        argErrorContaining('between 2 and 32'),
      );
      expect(() => validateEnvironment('aa'), returnsNormally);
      expect(
        () => validateEnvironment('A'),
        argErrorContaining('between 2 and 32'),
      );
      expect(() => validateEnvironment('AA'), returnsNormally);
    });

    test('must start with a-zA-Z', () {
      expect(() => validateEnvironment('a__'), returnsNormally);
      expect(() => validateEnvironment('z__'), returnsNormally);
      expect(() => validateEnvironment('A__'), returnsNormally);
      expect(() => validateEnvironment('Z__'), returnsNormally);

      expect(() => validateEnvironment('1__'), argErrorContaining('(a-zA-Z)'));
      expect(() => validateEnvironment('___'), argErrorContaining('(a-zA-Z)'));
      expect(() => validateEnvironment('-__'), argErrorContaining('(a-zA-Z)'));
      expect(() => validateEnvironment('\$__'), argErrorContaining('(a-zA-Z)'));
      expect(() => validateEnvironment('?__'), argErrorContaining('(a-zA-Z)'));
      expect(() => validateEnvironment('ä__'), argErrorContaining('umlaut'));
    });

    test('may not contain umlauts', () {
      expect(() => validateEnvironment('env_ä'), argErrorContaining('umlaut'));
      expect(() => validateEnvironment('env_ö'), argErrorContaining('umlaut'));
      expect(() => validateEnvironment('env_ü'), argErrorContaining('umlaut'));
    });

    test('do not allow spaces', () {
      expect(
        () => validateEnvironment('env name'),
        argErrorContaining('space'),
      );
      expect(() => validateEnvironment('env '), argErrorContaining('space'));
      expect(() => validateEnvironment(' env'), argErrorContaining('space'));
    });
  });
}

Matcher argErrorContaining(String containing) {
  return throwsA(
    isA<ArgumentError>().having(
      (e) => e.message,
      'message',
      contains(containing),
    ),
  );
}
