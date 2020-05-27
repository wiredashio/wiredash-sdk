import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiredash/wiredash.dart';

void main() {
  testWidgets('Wiredash widget can be created', (WidgetTester tester) async {
    final key = ValueKey('wiredash');
    await tester.pumpWidget(
      Wiredash(
        projectId: 'test',
        secret: 'test',
        navigatorKey: GlobalKey<NavigatorState>(),
        key: key,
        child: const SizedBox(),
      ),
    );

    final wiredashFinder = find.byKey(key);

    expect(wiredashFinder, findsOneWidget);
  });
}
