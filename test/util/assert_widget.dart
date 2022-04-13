import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiredash/src/core/widgets/larry_page_view.dart';

WidgetSelector assertWidget(Type widget) {
  return WidgetSelector(widget);
}

/// Represents a chain of widgets in the widget tree that can be asserted
///
/// Compared to normal [Finder], this gives great error messages along the chain
class WidgetSelector {
  WidgetSelector(this.widget, [this.parent]);

  final Type widget;
  final WidgetSelector? parent;

  Finder get _finder => find.byType(widget);

  WidgetSelector existsOnce() {
    final Finder scopedFinder;
    final _parent = parent;
    if (_parent != null) {
      _parent.existsOnce();
      scopedFinder = find.descendant(of: _parent._finder, matching: _finder);
    } else {
      scopedFinder = _finder;
    }

    final elements = scopedFinder.evaluate();
    if (elements.isEmpty) {
      if (_parent == null) {
        print('Could not find $this in widget tree');
        debugDumpApp();
        fail('Could not find $this in widget tree');
      } else {
        print('Could not find $this as child of $_parent');
        print('Children of $_parent:');
        print(_parent._finder.evaluate().first.toStringDeep());
        fail('Could not find $this as child of $_parent');
      }
    }

    if (elements.length > 1) {
      if (_parent == null) {
        print('Found more than one $this in widget tree');
        debugDumpApp();
        fail('Found more than one $this in widget tree');
      } else {
        print('Found more than one $this as child of $_parent');
        print(_parent._finder.evaluate().first.toStringDeep());
        fail('Found more than one $this as child of $_parent');
      }
    }

    // all fine, found 1 element
    assert(elements.length == 1);
    return this;
  }

  WidgetSelector doesNotExist() {
    expect(_finder, findsNothing);
    return this;
  }

  WidgetSelector child(Type widget) {
    return WidgetSelector(widget, this);
  }

  @override
  String toString() {
    return widget.toString();
  }
}
