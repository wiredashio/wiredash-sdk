import 'package:test/test.dart';
import 'package:wiredash/src/feedback/data/feedback_item.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item.dart';

void main() {
  group('PendingFeedbackItem', () {
    test('fromJson()', () {
      expect(
        PendingFeedbackItem.fromJson({
          'id': 'abc123',
          'screenshotPath': 'path/to/file.png',
          'feedbackItem': {
            'deviceInfo': '<device info>',
            'email': 'email@example.com',
            'message': 'Hello world!',
            'type': 'bug',
            'user': 'Testy McTestFace',
          },
        }),
        const PendingFeedbackItem(
          id: 'abc123',
          screenshotPath: 'path/to/file.png',
          feedbackItem: FeedbackItem(
            deviceInfo: '<device info>',
            email: 'email@example.com',
            message: 'Hello world!',
            type: 'bug',
            user: 'Testy McTestFace',
          ),
        ),
      );
    });

    test('toJson()', () {
      expect(
        const PendingFeedbackItem(
          id: 'abc123',
          screenshotPath: 'path/to/file.png',
          feedbackItem: FeedbackItem(
            deviceInfo: '<device info>',
            email: 'email@example.com',
            message: 'Hello world!',
            type: 'bug',
            user: 'Testy McTestFace',
          ),
        ).toJson(),
        {
          'id': 'abc123',
          'screenshotPath': 'path/to/file.png',
          'feedbackItem': {
            'deviceInfo': '<device info>',
            'email': 'email@example.com',
            'message': 'Hello world!',
            'type': 'bug',
            'user': 'Testy McTestFace',
          },
        },
      );
    });
  });
}
