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
    selectByType(Padding).childByType(SizedBox).text('Hello').existsOnce();
    selectByType(Padding)
        .childByType(SizedBox)
        .text('Hello')
        .existsAtLeastOnce();
    selectByType(GestureDetector).text('World').doesNotExist();
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
    multipleParents([selectByType(Wrap), selectByType(GestureDetector)])
        .text('Hello')
        .existsOnce();

    multipleParents([
      selectByType(SizedBox).childByType(GestureDetector),
      selectByType(Center)
    ]).text('Hello').existsOnce();

    multipleParents([
      selectByType(GestureDetector),
      selectByType(_UnknownWidget),
    ]).text('Hello').doesNotExist();

    // TODO unclear. Does .withParents() add parents to
    //  - `text('Hello')` or
    //  - `selectByType(SizedBox).text('Hello;)`?
    selectByType(SizedBox)
        .text('Hello')
        .withParents([selectByType(Center).childByType(Wrap)]).existsOnce();

    selectByType(SizedBox)
        .withParents([selectByType(Center).childByType(Wrap)])
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
