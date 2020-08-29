import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

UuidV4Generator get uuidV4 =>
    Zone.current[_uuidGeneratorKey] as UuidV4Generator ??
    const UuidV4Generator();

final _uuidGeneratorKey = Object();

@visibleForTesting
T withUUIDV4Generator<T>(UuidV4Generator generator, T Function() callback) {
  return runZoned<T>(callback, zoneValues: {_uuidGeneratorKey: generator});
}

@visibleForTesting
class UuidV4Generator {
  const UuidV4Generator();

  String generate() {
    final random = math.Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));

    bytes[6] = (bytes[6] & 0x0F) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final chars = bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join()
        .toUpperCase();

    return '${chars.substring(0, 8)}-${chars.substring(8, 12)}-'
        '${chars.substring(12, 16)}-${chars.substring(16, 20)}-'
        '${chars.substring(20, 32)}';
  }
}
