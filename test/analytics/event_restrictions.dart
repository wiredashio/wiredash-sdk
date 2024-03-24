import 'package:test/test.dart';
import 'package:wiredash/src/analytics/analytics.dart';

void main() {
  group('event name', () {
    test('common cases', () {
      expect(() => validateEventName('Hello World'), returnsNormally);
      expect(() => validateEventName('buy_item'), returnsNormally);
    });

    test('minimum 3 characters', () {
      expect(
        () => validateEventName('a'),
        argErrorContaining('between 3 and 64'),
      );
      expect(
        () => validateEventName('aa'),
        argErrorContaining('between 3 and 64'),
      );
      expect(() => validateEventName('aaa'), returnsNormally);
      expect(
        () => validateEventName('A'),
        argErrorContaining('between 3 and 64'),
      );
      expect(
        () => validateEventName('AA'),
        argErrorContaining('between 3 and 64'),
      );
      expect(() => validateEventName('AAA'), returnsNormally);
    });

    test('must start with a-zA-Z', () {
      expect(() => validateEventName('a__'), returnsNormally);
      expect(() => validateEventName('z__'), returnsNormally);
      expect(() => validateEventName('A__'), returnsNormally);
      expect(() => validateEventName('Z__'), returnsNormally);

      expect(() => validateEventName('1__'), argErrorContaining('(a-zA-Z)'));
      expect(() => validateEventName('___'), argErrorContaining('(a-zA-Z)'));
      expect(() => validateEventName('-__'), argErrorContaining('(a-zA-Z)'));
      expect(() => validateEventName('\$__'), argErrorContaining('(a-zA-Z)'));
      expect(
        () => validateEventName('#__'),
        argErrorContaining('Unknown internal event'),
      );
      expect(() => validateEventName('?__'), argErrorContaining('(a-zA-Z)'));
      expect(() => validateEventName('ä__'), argErrorContaining('umlaut'));
    });

    test('may not contain umlauts', () {
      expect(() => validateEventName('event_ä'), argErrorContaining('umlaut'));
      expect(() => validateEventName('event_ö'), argErrorContaining('umlaut'));
      expect(() => validateEventName('event_ü'), argErrorContaining('umlaut'));
    });

    test('internal events', () {
      expect(() => validateEventName('#first_launch'), returnsNormally);
      expect(
        () => validateEventName('#unkown'),
        argErrorContaining('Unknown internal event'),
      );
    });

    test('no leading or trailing spaces', () {
      expect(
        () => validateEventName('trailing '),
        argErrorContaining('trailing spaces'),
      );
      expect(
        () => validateEventName(' leading'),
        argErrorContaining('start with a letter (a-zA-Z)'),
      );
      expect(
        () => validateEventName('no  double_space'),
        argErrorContaining('double spaces'),
      );
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
