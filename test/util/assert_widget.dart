// ignore_for_file: avoid_print

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

WidgetSelector selectByType(Type widget) {
  return WidgetSelector._(find.byType(widget));
}

WidgetSelector select(Finder finder) {
  return WidgetSelector._(finder);
}

extension Select on Finder {
  WidgetSelector get select => WidgetSelector._(this);
}

/// Represents a chain of widgets in the widget tree that can be asserted
///
/// Compared to normal [Finder], this gives great error messages along the chain
class WidgetSelector {
  WidgetSelector._(this.standaloneFinder, [this.parent]);

  final Finder standaloneFinder;
  final WidgetSelector? parent;

  Finder get finder {
    final _parent = parent;
    if (_parent != null) {
      return find.descendant(of: _parent.finder, matching: standaloneFinder);
    }
    return standaloneFinder;
  }

  WidgetSelector childByType(Type type) {
    return WidgetSelector._(find.byType(type), this);
  }

  WidgetSelector childByWidgetPredicate(WidgetPredicate predicate) {
    return WidgetSelector._(find.byWidgetPredicate(predicate), this);
  }

  WidgetSelector childByElementType(Type type) {
    return WidgetSelector._(find.byElementType(type), this);
  }

  WidgetSelector text(
    String text, {
    bool findRichText = false,
    bool skipOffstage = true,
  }) {
    final finder = find.text(
      text,
      findRichText: findRichText,
      skipOffstage: skipOffstage,
    );
    return WidgetSelector._(finder, this);
  }

  WidgetSelector textContaining(Pattern pattern, {bool skipOffstage = true}) {
    final finder = find.textContaining(
      pattern,
      skipOffstage: skipOffstage,
    );
    return WidgetSelector._(finder, this);
  }

  WidgetSelector child(Finder finder) {
    return WidgetSelector._(finder, this);
  }

  @override
  String toString() {
    return "'${standaloneFinder.description}'";
  }

  String toStringBreadcrumb() {
    final parent = this.parent;
    if (parent == null) {
      return toString();
    }
    return '${parent.toStringBreadcrumb()} > ${toString()}';
  }
}

extension WidgetSelectorMatcher on WidgetSelector {
  WidgetSelector existsOnce() {
    final _parent = parent;
    if (_parent != null) {
      _parent.existsAtLeastOnce();
    }
    final elements = finder.evaluate();
    if (elements.isEmpty) {
      if (_parent == null) {
        print('Could not find $this in widget tree');
        debugDumpApp();
        fail('Could not find $this in widget tree');
      } else {
        final possibleParents = _parent.finder.evaluate();
        print(
          'Could not find $this as child of ${_parent.toStringBreadcrumb()}',
        );
        print(
          'There are ${possibleParents.length} possible parents for '
          '$this matching ${_parent.toStringBreadcrumb()}. But non matched. '
          'The widget trees starting at ${_parent.finder.description} are:',
        );
        int index = 0;
        for (final possibleParent in possibleParents) {
          print("Possible parent $index:");
          print(possibleParent.toStringDeep());
          index++;
        }
        fail(
          'Could not find $this as child of ${_parent.toStringBreadcrumb()}',
        );
      }
    }

    if (elements.length > 1) {
      if (_parent == null) {
        print(
          'Found ${elements.length} elements matching $this in widget tree, '
          'expected only one',
        );
        debugDumpApp();
        fail(
          'Found ${elements.length} elements matching $this in widget tree, '
          'expected only one',
        );
      } else {
        print(
          'Found ${elements.length} elements matching $this as child of ${_parent.toStringBreadcrumb()}, '
          'exepcting only one',
        );
        int index = 0;
        for (final candidate in elements) {
          print("Possible candidate $index:");
          // TODO: print tree of parent until candidate
          print(candidate.toStringDeep());
          index++;
        }
        fail(
          'Found more than one $this as child of ${_parent.toStringBreadcrumb()}',
        );
      }
    }

    // all fine, found 1 element
    assert(elements.length == 1);
    return this;
  }

  WidgetSelector existsAtLeastOnce() {
    final _parent = parent;
    if (_parent != null) {
      _parent.existsAtLeastOnce();
    }
    final elements = finder.evaluate();
    if (elements.isEmpty) {
      if (_parent == null) {
        print('Could not find $this in widget tree');
        debugDumpApp();
        fail('Could not find $this in widget tree');
      } else {
        print(
          'Could not find $this as child of ${_parent.toStringBreadcrumb()}',
        );
        print('Children of $_parent:');
        print(_parent.finder.evaluate().first.toStringDeep());
        fail(
          'Could not find $this as child of ${_parent.toStringBreadcrumb()}',
        );
      }
    }

    // all fine, found at least 1 element
    assert(elements.isNotEmpty);
    return this;
  }

  WidgetSelector doesNotExist() {
    expect(finder, findsNothing);
    return this;
  }
}
