import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiredash/src/core/support/not_a_widgets_app.dart';

import 'assert_widget.dart';

void main() {
  testWidgets('narrow down search down the tree', (tester) async {
    await tester.pumpWidget(
      NotAWidgetsApp(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              children: [
                SizedBox(
                  child: GestureDetector(
                    child: const Text('Hello', maxLines: 2),
                  ),
                ),
                const Text('Hello', maxLines: 1),
              ],
            ),
          ),
        ),
      ),
    );
    spot.byType(Padding).childByType(SizedBox).text('Hello').existsOnce();
    spot
        .byType(Padding)
        .childByType(SizedBox)
        .text('Hello')
        .existsAtLeastOnce();
    spot.byType(GestureDetector).text('World').doesNotExist();
  });

  testWidgets('narrow results by checking parents', (tester) async {
    await tester.pumpWidget(
      NotAWidgetsApp(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              children: [
                SizedBox(
                  child: GestureDetector(
                    child: const Text('Hello', maxLines: 2),
                  ),
                ),
                const Text('Hello', maxLines: 1),
              ],
            ),
          ),
        ),
      ),
    );
    multipleParents([spot.byType(Wrap), spot.byType(GestureDetector)])
        .text('Hello')
        .existsOnce();

    multipleParents([
      spot.byType(SizedBox).childByType(GestureDetector),
      spot.byType(Center)
    ]).text('Hello').existsOnce();

    multipleParents([
      spot.byType(GestureDetector),
      spot.byType(_UnknownWidget),
    ]).text('Hello').doesNotExist();

    // TODO unclear. Does .withParents() add parents to
    //  - `text('Hello')` or
    //  - `selectByType(SizedBox).text('Hello;)`?
    spot
        .byType(SizedBox)
        .text('Hello')
        .withParents([spot.byType(Center).childByType(Wrap)]).existsOnce();

    spot
        .byType(SizedBox)
        .withParents([spot.byType(Center).childByType(Wrap)])
        .text('Hello')
        .existsOnce();
  });
}

class _UnknownWidget extends StatelessWidget {
  const _UnknownWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
