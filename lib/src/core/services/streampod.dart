/// Service locator
///
/// Like riverpod, services can depend on each other and get recreated when
/// their dependencies change.
class Locator {
  final Map<Type, InstanceFactory> _registry = {};

  bool _disposed = false;

  void dispose() {
    for (final item in _registry.values) {
      item.dispose?.call();
    }
    _disposed = true;
  }

  /// Retrieve a instance of type [T]
  T get<T>() {
    if (_disposed) {
      throw Exception('Locator is disposed');
    }
    final provider = _registry[T];
    return provider!.get as T;
  }

  /// Retrieve a instance of type [T]
  T watch<T>() {
    if (_disposed) {
      throw Exception('Locator is disposed');
    }
    final provider = _registry[T];
    return provider!.watch as T;
  }

  /// Listen to change of type [T]
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
      if (instance != null && dispose != null) {
        dispose(instance);
      }
    });
    final existing = _registry[T];
    _registry[T] = provider;
    if (existing != null) {
      final consumers = existing.consumers.toList();
      final listeners = existing.listeners.toList();
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

class InstanceFactory<T> {
  static int _id = 0;

  InstanceFactory(
    this.locator,
    this.create,
    this.dispose,
  );

  final T Function(Locator) create;
  final Locator locator;

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
    if (_instance == null) {
      _tracker.create();
      late final T i;
      i = create(locator);
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
    if (_instance == null) {
      final T i = create(locator);
      _instance = i;
    }
    return _instance as T;
  }

  /// Discards the current [_instance] and rebuilds it with updated dependencies.
  ///
  /// Tracks dependencies to other providers during rebuild
  void rebuild() {
    dispose?.call();
    final consumers = this.consumers.toList();
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

  @override
  String toString() {
    return 'InstanceFactory<$T>{id: $id}';
  }
}

class DependencyTracker {
  static int? _active;

  DependencyTracker(this.provider);

  final InstanceFactory provider;

  Locator get locator => provider.locator;

  int? _prevActive;

  void create() {
    _prevActive = _active;
    if (_active != provider.id) {
      _active = provider.id;
    }
    if (_prevActive != null) {
      final listener = locator._registry.values
          .firstWhere((element) => element.id == _prevActive);
      provider.consumers.add(listener);
      listener.dependencies.add(provider);
    }
  }

  void created() {
    _active = _prevActive;
  }
}
