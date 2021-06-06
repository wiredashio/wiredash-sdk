/// Taken from
/// https://github.com/jamesblasco/snap_scroll_physics
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const double _kNavBarLargeTitleHeightExtension = 52.0;

mixin _SnapScrollPhysics on ScrollPhysics {
  @override
  BaseSnapScrollPhysics applyTo(ScrollPhysics? ancestor);
}

abstract class SnapScrollPhysics extends ScrollPhysics with _SnapScrollPhysics {
  factory SnapScrollPhysics({
    ScrollPhysics? parent,
    List<Snap> snaps,
  }) = RawSnapScrollPhysics;

  factory SnapScrollPhysics.builder(
    SnapBuilder builder, {
    ScrollPhysics? parent,
  }) = BuilderSnapScrollPhysics;

  static final cupertinoAppBar = SnapScrollPhysics._forCupertinoAppBar();

  factory SnapScrollPhysics._forCupertinoAppBar() =
      CupertinoAppBarSnapScrollPhysics;

  factory SnapScrollPhysics.preventStopBetween(
    double minExtent,
    double maxExtent, {
    double? delimiter,
    ScrollPhysics? parent,
  }) {
    return SnapScrollPhysics(parent: parent, snaps: [
      Snap.avoidZone(minExtent, maxExtent, delimiter: delimiter),
    ]);
  }
}

class RawSnapScrollPhysics extends BaseSnapScrollPhysics {
  const RawSnapScrollPhysics({
    ScrollPhysics? parent,
    this.snaps = const [],
  }) : super(parent: parent);

  @override
  final List<Snap> snaps;

  @override
  RawSnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return RawSnapScrollPhysics(
      parent: buildParent(ancestor),
      snaps: snaps,
    );
  }
}

class CupertinoAppBarSnapScrollPhysics extends BaseSnapScrollPhysics {
  CupertinoAppBarSnapScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);
  @override
  final List<Snap> snaps = [
    Snap.avoidZone(0, _kNavBarLargeTitleHeightExtension)
  ];

  @override
  CupertinoAppBarSnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CupertinoAppBarSnapScrollPhysics(
      parent: buildParent(ancestor),
    );
  }
}

typedef SnapBuilder = List<Snap> Function();

class BuilderSnapScrollPhysics extends BaseSnapScrollPhysics {
  const BuilderSnapScrollPhysics(this.builder, {ScrollPhysics? parent})
      : super(parent: parent);

  final SnapBuilder builder;

  @override
  List<Snap> get snaps => builder();

  @override
  BuilderSnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return BuilderSnapScrollPhysics(
      builder,
      parent: buildParent(ancestor),
    );
  }
}

abstract class BaseSnapScrollPhysics extends ScrollPhysics
    implements SnapScrollPhysics {
  const BaseSnapScrollPhysics({
    ScrollPhysics? parent,
  }) : super(parent: parent);

  List<Snap> get snaps;

  double _getTargetPixels(ScrollMetrics position, double proposedEnd,
      Tolerance tolerance, double velocity) {
    final Snap? snap = getSnap(position, proposedEnd, tolerance, velocity);
    if (snap == null) return proposedEnd;

    return snap.targetPixelsFor(position, proposedEnd, tolerance, velocity);
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final simulation = super.createBallisticSimulation(position, velocity);
    final proposedPixels = simulation?.x(double.infinity) ?? position.pixels;

    final double target =
        _getTargetPixels(position, proposedPixels, tolerance, velocity);
    // print('p $proposedPixels, $target, v=$velocity');
    if ((target - proposedPixels).abs() > precisionErrorTolerance) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        math.max(velocity.abs(), 1000) * velocity.sign,
        tolerance: tolerance,
      );
    }
    return simulation;
  }

  @override
  bool get allowImplicitScrolling => false;

  Snap? getSnap(ScrollMetrics position, double proposedEnd, Tolerance tolerance,
      double velocity) {
    for (final snap in snaps) {
      if (snap.shouldApplyFor(position, proposedEnd)) return snap;
    }
    return null;
  }
}

abstract class Snap {
  factory Snap(
    double extent, {
    double? distance = 10,
    double? trailingDistance,
    double? leadingDistance,
  }) =>
      _SnapPoint(
        extent,
        toleranceDistance: distance,
        trailingToleranceDistance: trailingDistance,
        leadingToleranceDistance: leadingDistance,
      );

  factory Snap.avoidZone(
    double minExtent,
    double maxExtent, {
    double? delimiter,
  }) = _PreventSnapArea;

  bool shouldApplyFor(ScrollMetrics position, double proposedEnd);

  double targetPixelsFor(
    ScrollMetrics position,
    double proposedEnd,
    Tolerance tolerance,
    double velocity,
  );
}

class _SnapPoint implements Snap {
  final double extent;
  final double trailingExtent;
  final double leadingExtent;

  _SnapPoint(
    this.extent, {
    double? toleranceDistance,
    double? trailingToleranceDistance,
    double? leadingToleranceDistance,
  })  : leadingExtent =
            extent - (leadingToleranceDistance ?? toleranceDistance ?? 0),
        trailingExtent =
            extent + (trailingToleranceDistance ?? toleranceDistance ?? 0);

  @override
  bool shouldApplyFor(ScrollMetrics position, double proposedEnd) {
    return proposedEnd > leadingExtent && proposedEnd < trailingExtent;
  }

  @override
  double targetPixelsFor(
    ScrollMetrics position,
    double proposedEnd,
    Tolerance tolerance,
    double velocity,
  ) {
    return extent;
  }
}

class _PreventSnapArea implements Snap {
  final double minExtent;
  final double maxExtent;
  final double delimiter;

  _PreventSnapArea(
    this.minExtent,
    this.maxExtent, {
    double? delimiter,
  })  : assert(
            delimiter == null ||
                (delimiter >= minExtent) && (delimiter <= maxExtent),
            'The delimiter value should be between the minExtent and maxExtent'),
        delimiter = delimiter ?? (minExtent + (maxExtent - minExtent) / 2);

  @override
  bool shouldApplyFor(ScrollMetrics position, double proposedEnd) {
    return proposedEnd > minExtent && proposedEnd < maxExtent;
  }

  @override
  double targetPixelsFor(
    ScrollMetrics position,
    double proposedEnd,
    Tolerance tolerance,
    double velocity,
  ) {
    if (delimiter < proposedEnd) {
      return maxExtent;
    } else {
      return minExtent;
    }
  }
}
