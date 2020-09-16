import 'package:test/test.dart';
import 'package:wiredash/src/feedback/data/feedback_item.dart';

void main() {
  group('FeedbackItem', () {
    test('fromJson()', () {
      expect(
        FeedbackItem.fromJson({
          'deviceInfo': '<device info>',
          'email': 'email@example.com',
          'message': 'Hello world!',
          'type': 'bug',
          'user': 'Testy McTestFace',
        }),
        const FeedbackItem(
          deviceInfo: '<device info>',
          email: 'email@example.com',
          message: 'Hello world!',
          type: 'bug',
          user: 'Testy McTestFace',
        ),
      );
    });

    test('toJson()', () {
      expect(
        const FeedbackItem(
          deviceInfo: '<device info>',
          email: 'email@example.com',
          message: 'Hello world!',
          type: 'bug',
          user: 'Testy McTestFace',
        ).toJson(),
        {
          'deviceInfo': '<device info>',
          'email': 'email@example.com',
          'message': 'Hello world!',
          'type': 'bug',
          'user': 'Testy McTestFace',
        },
      );
    });
  });
}
