import 'dart:ui';

class KeyPointInterpolator {
  KeyPointInterpolator(this.keypoints);

  final Map<double, double> keypoints;

  double interpolate(double value) {
    final smallKey = lastKeyBefore(value) ?? smallestKey;
    final bigKey = firstKeyAfter(value) ?? biggestKey;
    final smallValue = keypoints[smallKey]!;
    final bigValue = keypoints[bigKey]!;

    if (smallValue == bigValue) {
      return smallValue;
    }

    final keyDiff = (bigKey - smallKey).abs();
    final fraction = (value - smallKey) / keyDiff;

    return lerpDouble(smallValue, bigValue, fraction)!;
  }

  double get smallestKey {
    double? key;
    for (final lookup in keypoints.keys) {
      if (key == null || lookup < key) {
        key = lookup;
      }
    }
    if (key == null) {
      throw "No keypoints";
    }
    return key;
  }

  double get biggestKey {
    double? key;
    for (final lookup in keypoints.keys) {
      if (key == null || lookup > key) {
        key = lookup;
      }
    }
    if (key == null) {
      throw "No keypoints";
    }
    return key;
  }

  double? lastKeyBefore(double value) {
    double? key;
    for (final lookup in keypoints.keys) {
      if (lookup < value) {
        if (key == null || lookup > key) {
          key = lookup;
        }
      }
    }
    return key;
  }

  double? firstKeyAfter(double value) {
    double? key;
    for (final lookup in keypoints.keys) {
      if (lookup > value) {
        if (key == null || lookup < key) {
          key = lookup;
        }
      }
    }
    return key;
  }
}
