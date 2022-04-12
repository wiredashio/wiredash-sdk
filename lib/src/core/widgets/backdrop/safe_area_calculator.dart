import 'dart:ui';

/// Calculates the [rect] and [size] of a [SafeArea] constrained by multiple
/// overlapping insets.
class SafeAreaCalculator {
  final Size screenSize;
  SafeAreaCalculator({
    required this.screenSize,
  });

  final List<_Entry> _topInsets = [];
  final List<_Entry> _bottomInsets = [];

  /// Adds an inset to the top of the view.
  ///
  /// Adding mutliple insets results in the max to be picked
  void addTopInset(double height, String debugName) {
    _topInsets.add(_Entry(height, debugName));
  }

  /// Adds an inset from the bottom of the screen
  ///
  /// Adding multiple insets results in the max to be picked
  void addBottomInset(double height, String debugName) {
    _bottomInsets.add(_Entry(height, debugName));
  }

  double get topInset => _topInsets.maxBy((it) => it.height)?.height ?? 0.0;
  double get bottomInset =>
      _bottomInsets.maxBy((it) => it.height)?.height ?? 0.0;

  Size get size => rect.size;

  /// The are that is not covered by any insets
  Rect get rect {
    final top = topInset;
    return Rect.fromLTWH(
      0,
      top,
      screenSize.width,
      screenSize.height - top - bottomInset,
    );
  }

  @override
  String toString() {
    return 'SafeAreaCalculator{screenSize: $screenSize, _topInsets: $_topInsets, _bottomInsets: $_bottomInsets}';
  }

  SafeAreaCalculator withoutTopInsets() {
    final calc = SafeAreaCalculator(
      screenSize: screenSize,
    );
    for (final entry in _bottomInsets) {
      calc.addBottomInset(entry.height, entry.debugName);
    }
    return calc;
  }

  SafeAreaCalculator withoutBottomInsets() {
    final calc = SafeAreaCalculator(
      screenSize: screenSize,
    );
    for (final entry in _topInsets) {
      calc.addTopInset(entry.height, entry.debugName);
    }
    return calc;
  }
}

class _Entry implements Comparable<_Entry> {
  final double height;
  final String debugName;

  _Entry(this.height, this.debugName);

  @override
  String toString() {
    return '$debugName: $height';
  }

  @override
  int compareTo(_Entry other) {
    return height.compareTo(other.height);
  }
}

extension NumIterableMax<E extends num> on Iterable<E> {
  /// Returns the largest element or `null` if there are no elements.
  ///
  /// All elements must be of type [Comparable].
  E? max() => _minMaxBy(1, (it) => it);
}

extension IterableMax<E> on Iterable<E> {
  /// Returns the first element yielding the largest value of the given
  /// [selector] or `null` if there are no elements.
  E? maxBy(Comparable Function(E element) selector) => _minMaxBy(1, selector);

  E? _minMaxBy(int order, Comparable Function(E element) selector) {
    final it = iterator;
    if (!it.moveNext()) {
      return null;
    }

    var currentMin = it.current;
    var currentMinValue = selector(it.current);
    while (it.moveNext()) {
      final comp = selector(it.current);
      if (comp.compareTo(currentMinValue) == order) {
        currentMin = it.current;
        currentMinValue = comp;
      }
    }

    return currentMin;
  }
}
