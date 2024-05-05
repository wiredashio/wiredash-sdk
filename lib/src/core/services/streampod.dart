import 'package:flutter/foundation.dart';

const _kDebugStreamPod = false;

void _log(Object? Function() message) {
  if (_kDebugStreamPod && kDebugMode) {
    final text = message().toString();
    debugPrint(text);
  }
}

/// Service locator, read only interface that doesn't allow to register or override services.
///
/// Like riverpod, services can depend on each other and get recreated when
/// their dependencies change.
abstract class Locator {
  /// Retrieve a instance of type [T]
  T get<T>();

  /// Retrieve a instance of type [T] and subscribe to changes when called
  /// from within `injectProvider(create:(){ ...})`
  T watch<T>();

  /// Listen to change of type [T]
  void listen<T>(void Function(T) callback);
}

/// A service locator that allows to register and override services.
///
/// Like riverpod, services can depend on each other and get recreated when
/// their dependencies change.
class InjectableLocator implements Locator {
  final Map<Type, InstanceFactory> _registry = {};

  bool _disposed = false;

  void dispose() {
    for (final item in _registry.values) {
      item.dispose?.call();
    }
    _disposed = true;
  }

  /// Retrieve a instance of type [T]
  @override
  T get<T>() {
    if (_disposed) {
      throw Exception('Locator is disposed');
    }
    final provider = _registry[T];
    return provider!.get as T;
  }

  /// Retrieve a instance of type [T] and subscribe to changes
  @override
  T watch<T>() {
    if (_disposed) {
      throw Exception('Locator is disposed');
    }
    final provider = _registry[T];
    if (provider == null) {
      throw Exception('No provider found for type $T');
    }
    return provider.watch as T;
  }

  /// Listen to change of type [T]
  @override
  void listen<T>(void Function(T) callback) {
    final factory = _registry[T]!;

    factory.listeners.add(() {
      final currentFactory = _registry[T]!;
      callback(currentFactory.get as T);
    });
    callback(factory.get as T);
  }

  InstanceFactory<T> injectProvider<T>(
    T Function(Locator) create, {
    void Function(T)? dispose,
  }) {
    if (_disposed) {
      throw Exception('Locator is disposed');
    }
    late InstanceFactory<T> provider;
    provider = InstanceFactory(this, create, () {
      final instance = provider._instance;
      if (instance != null) {
        if (dispose != null) {
          dispose(instance);
        } else {
          _autoDispose(instance);
        }
      }
    });
    final existing = _registry[T];
    _registry[T] = provider;
    if (existing != null) {
      final consumers = existing.consumers.toList();
      final listeners = existing.listeners.toList();
      _log(() {
        final deps = consumers.map((e) {
          final i = e._instance as Object?;
          if (i == null) return e.factoryType;
          if (i is Function) return i.objectId;
          return '${e.factoryType}=>${i.objectId}';
        }).join(', ');
        final depsText = deps.isEmpty ? '' : ', rebuilds $deps';

        return '${DependencyTracker._levelIndent}Recreate ${existing.factoryType}$depsText';
      });
      existing.consumers = [];
      existing.dependencies = [];
      existing.listeners = [];
      existing.dispose?.call();
      for (final consumer in consumers) {
        // rebuilding automatically registers dependencies and listeners again
        consumer.rebuild();
      }

      provider.listeners.addAll(listeners);
      for (final listener in listeners) {
        listener.call();
      }
    }
    return provider;
  }
}

/// Tries to call common dispose methods on the instance dynamically
///
/// Returns true if the [instance] reacted to a dispose method call
bool _autoDispose(dynamic instance) {
  // try calling dispose on the instance
  final dynamic eventuallyDisposable = instance;
  final methods = [
    (i) {
      if (i is ChangeNotifier) {
        i.dispose();
      } else {
        throw NoSuchMethodError.withInvocation(
          'Not a ChangeNotifier',
          Invocation.method(#dispose, []),
        );
      }
    },
    // ignore: avoid_dynamic_calls
    (i) => i.dispose(),
    // ignore: avoid_dynamic_calls
    (i) => i.close(),
    // ignore: avoid_dynamic_calls
    (i) => i.cancel(),
  ];

  for (final method in methods) {
    try {
      method(eventuallyDisposable);
      return true;
      // ignore: avoid_catching_errors
    } on NoSuchMethodError catch (_) {
      // ignore when method does not exist
      // ignore: avoid_catching_errors
    } on UnimplementedError catch (_) {
      // ignore fakes
    }
  }
  return false;
}

class InstanceFactory<T> {
  static int _id = 0;

  InstanceFactory(
    this.locator,
    this.create,
    this.dispose,
  );

  final T Function(Locator) create;
  final InjectableLocator locator;

  final int id = _id++;
  T? _instance;

  /// Those factories that use the instance and rebuild when it changes
  List<InstanceFactory> consumers = [];

  /// Receive notifications about instance changes
  List<void Function()> listeners = [];

  /// When those change, instance gets recreated
  List<InstanceFactory> dependencies = [];

  final Function()? dispose;

  late final DependencyTracker _tracker = DependencyTracker(this);

  /// Rebuilds the calling [InstanceFactory] when [_instance] changes.
  T get watch {
    _log(() {
      if (DependencyTracker._active == null) {
        return '${DependencyTracker._levelIndent}Get $factoryType (via watch)';
      } else {
        return '${DependencyTracker._levelIndent}Watch $factoryType';
      }
    });

    if (_instance == null) {
      _tracker.create();
      _log(() => '${DependencyTracker._levelIndent}Creating $factoryType');
      late final T i;
      i = create(locator);
      _log(() {
        final deps = dependencies.map((e) {
          final i = e._instance as Object?;
          if (i == null) return e.factoryType;
          if (i is Function) return i.objectId;
          return '${e.factoryType}=>${i.objectId}';
        }).join(', ');
        final depsText = deps.isEmpty ? '' : ', watching $deps';
        return '${DependencyTracker._levelIndent}Created $factoryType=>${(i as Object?).objectId}$depsText';
      });
      _tracker.created();
      _instance = i;
    } else {
      _tracker.create();
      _tracker.created();
    }
    return _instance as T;
  }

  /// Reads the current [_instance], doesn't subscribe the calling [InstanceFactory] to changes.
  T get get {
    _log(() => '${DependencyTracker._levelIndent}Get $factoryType');
    // temporarily disable dependency tracking
    final tempActive = DependencyTracker._active;
    DependencyTracker._active = null;
    if (_instance == null) {
      _tracker.create();
      _log(() => '${DependencyTracker._levelIndent}Creating $factoryType');
      late final T i;
      i = create(locator);
      _log(() {
        final deps = dependencies.map((e) {
          final i = e._instance as Object?;
          if (i == null) return e.factoryType;
          if (i is Function) return i.objectId;
          return '${e.factoryType}=>${i.objectId}';
        }).join(', ');
        final depsText = deps.isEmpty ? '' : ', watching $deps';
        return '${DependencyTracker._levelIndent}Created $factoryType=>${(i as Object?).objectId}$depsText';
      });
      _tracker.created();
      _instance = i;
    } else {
      _tracker.create();
      _tracker.created();
    }
    DependencyTracker._active = tempActive;
    return _instance as T;
  }

  /// Discards the current [_instance] and rebuilds it with updated dependencies.
  ///
  /// Tracks dependencies to other providers during rebuild
  void rebuild() {
    dispose?.call();
    final consumers = this.consumers.toList();
    _log(() {
      final deps = consumers.map((e) {
        final i = e._instance as Object?;
        if (i == null) return e.factoryType;
        if (i is Function) return i.objectId;
        return '${e.factoryType}=>${i.objectId}';
      }).join('\n- ');
      final depsText = deps.isEmpty ? '' : ', recreating\n- $deps';

      return '${DependencyTracker._levelIndent}Disposing $factoryType=>${_instance.objectId}$depsText';
    });
    dependencies = [];
    this.consumers = [];
    _instance = null;

    // invalidate existing dependency instances
    for (final provider in consumers) {
      _tracker.create();
      provider.rebuild();
      _tracker.created();
    }
  }

  Type get factoryType => T;

  @override
  String toString() {
    return 'InstanceFactory<$T>{id: $id}';
  }
}

class DependencyTracker {
  static int? _active;
  static int _level = 0;

  static String get _levelIndent => ''.padLeft(DependencyTracker._level);

  DependencyTracker(this.provider);

  final InstanceFactory provider;

  InjectableLocator get locator => provider.locator;

  int? _prevActive;

  void create() {
    _prevActive = _active;
    if (_active != provider.id) {
      _active = provider.id;
    }
    _level++;
    if (_prevActive != null) {
      final listener = locator._registry.values
          .firstWhere((element) => element.id == _prevActive);
      provider.consumers.add(listener);
      listener.dependencies.add(provider);
    }
  }

  void created() {
    _active = _prevActive;
    _level--;
  }
}

extension ObjectExt on Object? {
  // ignore: no_runtimetype_tostring
  String get objectId => '$runtimeType@${hashCode.toRadixString(16)}';
}
