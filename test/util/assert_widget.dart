// ignore_for_file: avoid_print

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final Spot spot = Spot();

class Spot with CommonSpots {
  @override
  WidgetSelector? get _self => null;
}

mixin CommonSpots {
  WidgetSelector? get _self;

  WidgetSelector byType(
    Type type, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return WidgetSelector._(find.byType(type), parents, children);
  }

  WidgetSelector childByType(
    Type type, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return WidgetSelector._(
      find.byType(type),
      [
        if (_self != null) _self!,
        ...parents,
      ],
      children,
    );
  }

  WidgetSelector childByWidgetPredicate(
    WidgetPredicate predicate, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return WidgetSelector._(
      find.byWidgetPredicate(predicate),
      [if (_self != null) _self!, ...parents],
      children,
    );
  }

  WidgetSelector childByElementType(
    Type type, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return WidgetSelector._(
      find.byElementType(type),
      [
        if (_self != null) _self!,
        ...parents,
      ],
      children,
    );
  }

  WidgetSelector text(
    String text, {
    bool findRichText = false,
    bool skipOffstage = true,
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    final finder = find.text(
      text,
      findRichText: findRichText,
      skipOffstage: skipOffstage,
    );
    return WidgetSelector._(
      finder,
      [if (_self != null) _self!, ...parents],
      children,
    );
  }

  /// Caution: this is a very expensive operation.
  WidgetSelector childWidgetWithText(
    Type widgetType,
    String text, {
    bool skipOffstage = true,
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    final finder = find.widgetWithText(
      widgetType,
      text,
      skipOffstage: skipOffstage,
    );
    return WidgetSelector._(
      finder,
      [if (_self != null) _self!, ...parents],
      children,
    );
  }

  WidgetSelector textContaining(
    Pattern pattern, {
    bool skipOffstage = true,
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    final finder = find.textContaining(
      pattern,
      skipOffstage: skipOffstage,
    );
    return WidgetSelector._(
      finder,
      [if (_self != null) _self!, ...parents],
      children,
    );
  }

  WidgetSelector child(
    Finder finder, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return WidgetSelector._(
      finder,
      [if (_self != null) _self!, ...parents],
      children,
    );
  }
}

extension SpotFinder on Finder {
  WidgetSelector get spot {
    return WidgetSelector._(this);
  }
}

/// Represents a chain of widgets in the widget tree that can be asserted
///
/// Compared to normal [Finder], this gives great error messages along the chain
class WidgetSelector with CommonSpots {
  WidgetSelector._(
    this.standaloneFinder, [
    List<WidgetSelector>? parents,
    List<WidgetSelector>? children,
  ])  : parents = parents ?? [],
        children = children ?? [];

  final Finder standaloneFinder;
  final List<WidgetSelector> parents;
  final List<WidgetSelector> children;

  Finder get finder {
    final ancestors = parents;
    final descendants = children;
    if (descendants.isEmpty && ancestors.isEmpty) {
      return standaloneFinder;
    }

    if (descendants.isEmpty) {
      if (ancestors.length == 1) {
        return find.descendant(
          of: ancestors.first.finder,
          matching: standaloneFinder,
        );
      }
      return _MultiAncestorDescendantFinder(
        ancestors.map((e) => e.finder).toList(),
        standaloneFinder,
      );
    }

    if (ancestors.isEmpty) {
      if (descendants.length == 1) {
        return find.ancestor(
          of: descendants.first.finder,
          matching: standaloneFinder,
        );
      }
      return _MultiDescendantsAncestorFinder(
        descendants.map((e) => e.finder).toList(),
        standaloneFinder,
      );
    }

    // this always works but produces unnecessary nesting and harder to read error messages
    return _MultiAncestorDescendantFinder(
      ancestors.map((e) => e.finder).toList(),
      _MultiDescendantsAncestorFinder(
        descendants.map((e) => e.finder).toList(),
        standaloneFinder,
      ),
    );
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

  @override
  WidgetSelector get _self => this;
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

class _MultiAncestorDescendantFinder extends Finder {
  _MultiAncestorDescendantFinder(
    this.ancestors,
    this.finder, {
    bool skipOffstage = true,
  }) : super(skipOffstage: skipOffstage);

  final List<Finder> ancestors;
  final Finder finder;

  @override
  String get description {
    return '${finder.description} that has ancestors with [${ancestors.map((e) => e.description).join(' && ')}]';
  }

  @override
  Iterable<Element> apply(Iterable<Element> candidates) {
    final evaluate = finder.evaluate().toSet();
    return candidates.where((Element element) => evaluate.contains(element));
  }

  @override
  Iterable<Element> get allCandidates sync* {
    if (ancestors.isEmpty) {
      yield* super.allCandidates;
      return;
    }
    final List<Set<Element>> ancestorElements = ancestors.map((ancestor) {
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

class _MultiDescendantsAncestorFinder extends Finder {
  _MultiDescendantsAncestorFinder(this.descendants, this.finder)
      : super(skipOffstage: false);

  final Finder finder;
  final List<Finder> descendants;

  @override
  String get description {
    return '${finder.description} which is an ancestor of  [${descendants.map((e) => e.description).join(' && ')}]';
  }

  @override
  Iterable<Element> apply(Iterable<Element> candidates) {
    final allPossible = finder.evaluate().toSet();
    return candidates.where((Element element) => allPossible.contains(element));
  }

  @override
  Iterable<Element> get allCandidates {
    if (descendants.isEmpty) {
      return super.allCandidates;
    }
    final Iterable<Element> possibleParents = descendants.expand((ancestor) {
      return ancestor.evaluate().expand((element) {
        return element.parents.toList();
      });
    });

    return possibleParents;
  }
}
