import 'package:test/test.dart';
import 'package:wiredash/src/analytics/analytics.dart';

import '../util/flutter_error.dart';

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

  group('parameters', () {
    test('no more than 10 parameters', () {
      _runValidateParameters({
        'one': 1,
        'two': 2,
        'three': 3,
        'four': 4,
        'five': 5,
        'six': 6,
        'seven': 7,
        'eight': 8,
        'nine': 9,
        'ten': 10,
      }).hasNoErrorsNoInfos().parametersAreUnchanged();
      _runValidateParameters({
        'one': 1,
        'two': 2,
        'three': 3,
        'four': 4,
        'five': 5,
        'six': 6,
        'seven': 7,
        'eight': 8,
        'nine': 9,
        'ten': 10,
        'eleven': 11,
      })
          .hasInfoContaining('Dropped the keys [eleven]')
          .hasInfoContaining('exceed 10 key-value pairs')
          .remainingKeys([
        'one',
        'two',
        'three',
        'four',
        'five',
        'six',
        'seven',
        'eight',
        'nine',
        'ten',
      ]);
    });

    test('value types', () {
      _runValidateParameters({'key': 'a string'})
          .hasNoErrorsNoInfos()
          .parametersAreUnchanged();
      _runValidateParameters({'bool': true})
          .hasNoErrorsNoInfos()
          .parametersAreUnchanged();
      _runValidateParameters({'bool': false})
          .hasNoErrorsNoInfos()
          .parametersAreUnchanged();
      _runValidateParameters({'int': 0})
          .hasNoErrorsNoInfos()
          .parametersAreUnchanged();
      _runValidateParameters({'int': -25})
          .hasNoErrorsNoInfos()
          .parametersAreUnchanged();
      _runValidateParameters({'null': null})
          .hasNoErrorsNoInfos()
          .parametersAreUnchanged();
      _runValidateParameters({'list': <String>[]})
          .hasInfoContaining('list')
          .hasInfoContaining('unsupported type List<')
          .remainingKeys([]);
      _runValidateParameters({'map': <String, String>{}})
          .hasInfoContaining('map')
          .hasInfoContaining('unsupported type')
          .hasInfoContaining('Map<')
          .remainingKeys([]);
      _runValidateParameters({'set': <String>{}})
          .hasInfoContaining('set')
          .hasInfoContaining('unsupported type')
          .hasInfoContaining('Set<')
          .remainingKeys([]);
      _runValidateParameters({'object': Object()})
          .hasInfoContaining('object')
          .hasInfoContaining('unsupported type Object')
          .remainingKeys([]);
    });

    test('key length', () {
      _runValidateParameters({'x'.padLeft(128, 'x'): 'long key'})
          .hasNoErrorsNoInfos()
          .parametersAreUnchanged();

      _runValidateParameters({'x'.padLeft(128 + 1, 'x'): 'too long key'})
          .hasInfoContaining('Dropped the key')
          .hasInfoContaining(
            'event event_name because it exceeds 128 characters',
          )
          .hasNoErrors()
          .remainingKeys([]);

      _runValidateParameters({'x': 'short key'})
          .hasNoErrorsNoInfos()
          .parametersAreUnchanged();

      _runValidateParameters({'': 'empty key'})
          .hasInfoContaining('Dropped the key ""')
          .hasInfoContaining('because it is empty.')
          .hasNoErrors()
          .remainingKeys([]);
    });

    test('value length', () {
      _runValidateParameters({'long value': 'x'.padLeft(1022, 'x')})
          .hasNoErrorsNoInfos()
          .parametersAreUnchanged();

      _runValidateParameters({'too long value': 'x'.padLeft(1022 + 1, 'x')})
          .hasInfoContaining('value for "too long value"')
          .hasInfoContaining('has a length of 1025')
          .hasInfoContaining('maximum of 1024 characters')
          .hasNoErrors()
          .remainingKeys([]);

      _runValidateParameters({'short value': 'x'})
          .hasNoErrorsNoInfos()
          .parametersAreUnchanged();
      _runValidateParameters({'short value': ''})
          .hasNoErrorsNoInfos()
          .parametersAreUnchanged();
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

_ValidateResult _runValidateParameters(Map<String, Object?>? params) {
  final FlutterErrors errors = captureFlutterErrors();
  final Map<String, Object?> processed = validateParams(params, 'event_name');
  return _ValidateResult(params, processed, errors);
}

class _ValidateResult {
  final Map<String, Object?>? input;
  final Map<String, Object?>? processed;
  final FlutterErrors errors;

  _ValidateResult(this.input, this.processed, this.errors);

  _ValidateResult hasNoErrorsNoInfos() {
    expect(errors.onError, isEmpty, reason: 'Expected no errors');
    expect(errors.presentError, isEmpty, reason: 'Expected no errors');
    return this;
  }

  _ValidateResult hasNoErrors() {
    expect(errors.onError, isEmpty, reason: 'Expected no errors');
    return this;
  }

  _ValidateResult hasNoInfos() {
    expect(errors.presentError, isEmpty, reason: 'Expected no errors');
    return this;
  }

  _ValidateResult parametersAreUnchanged() {
    expect(
      processed,
      equals(input),
      reason: 'Expected parameters to be unchanged',
    );
    return this;
  }

  _ValidateResult hasErrorContaining(String text) {
    expect(
      errors.onError.join(),
      contains(text),
      reason: 'Expected an error containing "$text"',
    );
    return this;
  }

  _ValidateResult hasInfoContaining(String text) {
    expect(
      errors.presentError.join(),
      contains(text),
      reason: 'Expected an info containing "$text"',
    );
    return this;
  }

  _ValidateResult remainingKeys(List<String> list) {
    expect(
      processed!.keys,
      list,
      reason: 'Expected remaining keys to be $list',
    );
    return this;
  }
}
