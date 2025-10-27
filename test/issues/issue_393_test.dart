import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiredash/wiredash.dart';

import '../util/robot.dart';

void main() {
  group('issue 393', () {
    testWidgets('metadata should be encapsulated per opened Wiredash Feedback',
        (tester) async {
      final robot = WiredashTestRobot(tester);

      MapEntry<String, String> customMetaData = const MapEntry('foo', 'bar');

      CustomizableWiredashMetaData? metadata;
      await robot.launchApp(
        builder: (context) {
          return Scaffold(
            body: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    final wiredash = Wiredash.of(context);
                    wiredash.modifyMetaData((metaData) {
                      return metadata = metaData
                        ..custom[customMetaData.key] = customMetaData.value;
                    });
                    wiredash.show();
                  },
                  child: const Text('Feedback'),
                ),
              ],
            ),
          );
        },
      );
      await robot.openWiredash();
      expect(metadata!.custom['foo'], 'bar');
      await robot.closeWiredash();

      customMetaData = const MapEntry('bar', 'foo');
      await robot.openWiredash();
      expect(metadata!.custom.length, 1);
      expect(metadata!.custom['bar'], 'foo');
    });
  });
}
