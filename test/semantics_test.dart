import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import 'util/robot.dart';

void main() {
  group('Semantics', () {
    testWidgets('feedback form is in the semantics tree', (tester) async {
      SemanticsHandle? handle = tester.ensureSemantics();
      addTearDown(() => handle?.dispose());
      final robot = await WiredashTestRobot(tester).launchApp();
      await robot.openWiredash();

      final nodes = _semanticsNodes(tester);
      expect(
        // ignore: deprecated_member_use
        nodes.where((it) => it.hasFlag(SemanticsFlag.isTextField)),
        hasLength(1),
      );
      expect(
        nodes.map((it) => it.label),
        anyElement(contains('l10n.feedbackCloseButton')),
      );
      // Flutter checks for active handles before running addTearDown callbacks.
      handle.dispose();
      handle = null;
    });
  });
}

List<SemanticsData> _semanticsNodes(WidgetTester tester) {
  final nodes = <SemanticsData>[];
  void visit(SemanticsNode node) {
    nodes.add(node.getSemanticsData());
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
  return nodes;
}
