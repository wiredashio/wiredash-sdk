// ignore_for_file: avoid_print

import 'package:collection/collection.dart';
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

WidgetSelector multipleParents(List<WidgetSelector> parents) {
  final anyWidget = find.byWidgetPredicate((widget) => true);
  return WidgetSelector._(anyWidget, parents);
}

/// Represents a chain of widgets in the widget tree that can be asserted
///
/// Compared to normal [Finder], this gives great error messages along the chain
class WidgetSelector {
  WidgetSelector._(this.standaloneFinder, [this.parents = const []]);

  final Finder standaloneFinder;
  final List<WidgetSelector> parents;

  Finder get finder {
    final parents = this.parents;
    if (parents.isEmpty) {
      return standaloneFinder;
    }
    if (parents.length == 1) {
      return find.descendant(
        of: parents.first.finder,
        matching: standaloneFinder,
      );
    }
    return _MultiDescendantFinder(
      parents.map((e) => e.finder).toList(),
      standaloneFinder,
    );
  }

  WidgetSelector childByType(Type type) {
    return WidgetSelector._(find.byType(type), [this]);
  }

  WidgetSelector childByWidgetPredicate(WidgetPredicate predicate) {
    return WidgetSelector._(find.byWidgetPredicate(predicate), [this]);
  }

  WidgetSelector childByElementType(Type type) {
    return WidgetSelector._(find.byElementType(type), [this]);
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
    return WidgetSelector._(finder, [this]);
  }

  /// Caution: this is a very expensive operation.
  WidgetSelector childWidgetWithText(
    Type widgetType,
    String text, {
    bool skipOffstage = true,
  }) {
    final finder = find.widgetWithText(
      widgetType,
      text,
      skipOffstage: skipOffstage,
    );
    return WidgetSelector._(finder, [this]);
  }

  WidgetSelector textContaining(Pattern pattern, {bool skipOffstage = true}) {
    final finder = find.textContaining(
      pattern,
      skipOffstage: skipOffstage,
    );
    return WidgetSelector._(finder, [this]);
  }

  WidgetSelector child(Finder finder) {
    return WidgetSelector._(finder, [this]);
  }

  @override
  String toString() {
    return "'${standaloneFinder.description}'";
  }

  String toStringBreadcrumb() {
    final parents = this.parents;

    if (parents.isEmpty) {
      return standaloneFinder.description;
    }
    final parentBreadcrumbs = parents.map((e) => e.toStringBreadcrumb());
    if (parentBreadcrumbs.length == 1) {
      return '${parentBreadcrumbs.first} > ${toString()}';
    } else {
      return '[${parentBreadcrumbs.join(' && ')}] > ${toString()}';
    }
  }
}

extension WidgetSelectorMatcher on WidgetSelector {
  WidgetSelector existsOnce() {
    final parents = this.parents;

    final elements = finder.evaluate().toList();

    // early exit when finder finds nothing
    if (elements.isEmpty) {
      if (parents.isEmpty) {
        print('Could not find $this in widget tree');
        debugDumpApp();
        fail('Could not find $this in widget tree');
      } else {
        int i = 0;
        for (final parent in parents) {
          i++;
          final possibleParents = parent.finder.evaluate();
          print(
            'Could not find $this as child of #$i ${parent.toStringBreadcrumb()}',
          );
          print(
            'There are ${possibleParents.length} possible parents for '
            '$this matching #$i ${parent.toStringBreadcrumb()}. But non matched. '
            'The widget trees starting at #$i ${parent.finder.description} are:',
          );
          int index = 0;
          for (final possibleParent in possibleParents) {
            print("Possible parent $index:");
            print(possibleParent.toStringDeep());
            index++;
          }
        }
        fail(
          'Could not find $this as child of ${parents.toStringBreadcrumb()}',
        );
      }
    }

    Iterable<Element> matches = elements;
    if (parents.isNotEmpty) {
      // check if elements matches parents
      matches = elements.where((candidate) {
        return parents.every((WidgetSelector parent) {
          final elementParents = candidate.parents;
          final found = parent.finder.apply(elementParents).toList();
          return found.isNotEmpty;
        });
      });

      if (matches.isEmpty) {
        int i = 0;
        for (final parent in parents) {
          i++;
          final possibleParents = parent.finder.evaluate();
          print(
            'Could not find $this as child of #$i ${parent.toStringBreadcrumb()}',
          );
          print(
            'There are ${possibleParents.length} possible parents for '
            '$this matching #$i ${parent.toStringBreadcrumb()}. But non matched. '
            'The widget trees starting at #$i ${parent.finder.description} are:',
          );
          int index = 0;
          for (final possibleParent in possibleParents) {
            print("Possible parent $index:");
            print(possibleParent.toStringDeep());
            index++;
          }
        }
        fail(
          'Could not find $this as child of ${parents.toStringBreadcrumb()}',
        );
      }
    }

    if (matches.length > 1) {
      if (parents.isEmpty) {
        print(
          'Found ${matches.length} elements matching $this in widget tree, '
          'expected only one',
        );
        debugDumpApp();
        fail(
          'Found ${matches.length} elements matching $this in widget tree, '
          'expected only one',
        );
      } else {
        print(
          'Found ${matches.length} elements matching $this as child of ${parents.toStringBreadcrumb()}, '
          'exepcting only one',
        );
        int index = 0;
        for (final candidate in matches) {
          print("Possible candidate $index:");
          // TODO: print tree of parent until candidate
          print(candidate.toStringDeep());
          index++;
        }
        fail(
          'Found more than one $this as child of ${parents.toStringBreadcrumb()}',
        );
      }
    }

    // all fine, found 1 element
    assert(matches.length == 1);
    return this;
  }

  WidgetSelector existsAtLeastOnce() {
    final Iterable<Element> elements = finder.evaluate();

    final match = elements.firstWhereOrNull((element) {
      return parents.any((WidgetSelector parent) {
        return parent.finder.apply(element.parents).isNotEmpty;
      });
    });

    if (match == null) {
      if (parents.isEmpty) {
        print('Could not find $this in widget tree');
        debugDumpApp();
        fail('Could not find $this in widget tree');
      } else {
        print(
          'Could not find $this as child of ${parents.toStringBreadcrumb()}',
        );
        int i = 0;
        for (final parent in parents) {
          i++;
          print('Children of #$i $parent:');
          print(parent.finder.evaluate().first.toStringDeep());
          fail(
            'Could not find $this as child of #$i ${parent.toStringBreadcrumb()}',
          );
        }
      }
    }

    // all fine, found at least 1 element
    assert(elements.isNotEmpty);
    return this;
  }

  WidgetSelector withParents(List<WidgetSelector> selectors) {
    return WidgetSelector._(
      finder,
      [...parents, ...selectors],
    );
  }

  WidgetSelector doesNotExist() {
    expect(finder, findsNothing);
    return this;
  }
}

extension ElementParent on Element {
  Element? get parent {
    Element? parent;
    visitAncestorElements((element) {
      parent = element;
      return false;
    });
    return parent;
  }

  Iterable<Element> get parents sync* {
    Element? element = this;
    while (element != null) {
      yield element;
      element = element.parent;
    }
  }
}

extension on List<WidgetSelector> {
  String toStringBreadcrumb() {
    if (this.isEmpty) {
      return '[]';
    }
    final parentBreadcrumbs = map((e) => e.toStringBreadcrumb());
    if (parentBreadcrumbs.length == 1) {
      return parentBreadcrumbs.first;
    } else {
      return '[${parentBreadcrumbs.join(' && ')}]';
    }
  }
}

class _MultiDescendantFinder extends Finder {
  _MultiDescendantFinder(
    this.ancestors,
    this.descendant, {
    bool skipOffstage = true,
  }) : super(skipOffstage: skipOffstage);

  final List<Finder> ancestors;
  final Finder descendant;

  @override
  String get description {
    return '${descendant.description} that has ancestors with [${ancestors.map((e) => e.description).join(' && ')}]';
  }

  @override
  Iterable<Element> apply(Iterable<Element> candidates) {
    final evaluate = descendant.evaluate().toSet();
    return candidates.where((Element element) => evaluate.contains(element));
  }

  @override
  Iterable<Element> get allCandidates sync* {
    final List<Iterable<Element>> ancestorElements = ancestors.map((ancestor) {
      return ancestor.evaluate().expand((element) {
        return collectAllElementsFrom(element, skipOffstage: skipOffstage);
      }).toSet();
    }).toList();

    // find elements that are in all iterables
    final firstList = ancestorElements.removeAt(0);
    for (final element in firstList) {
      bool allMatch = true;
      for (final ancestorElements in ancestorElements) {
        if (!ancestorElements.contains(element)) {
          allMatch = false;
          break;
        }
      }
      if (allMatch) {
        // element in all ancestors
        yield element;
      }
    }
  }
}
