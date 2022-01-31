/// Service locator
///
/// Like riverpod, services can depend on each other and get recreated when
/// their dependencies change.
class Locator {
  final Map<Type, InstanceFactory> _registry = {};

  void dispose() {
    for (final item in _registry.values) {
      item.dispose?.call();
    }
  }

  /// Retrieve a instance of type [T]
  T get<T>() {
    final provider = _registry[T];
    return provider!.instance as T;
  }

  InstanceFactory<T> injectProvider<T>(
    T Function(Locator) create, {
    T Function(Locator, T oldInstance)? update,
    void Function(T)? dispose,
  }) {
    late InstanceFactory<T> provider;
    provider = InstanceFactory(this, create, update, () {
      final instance = provider._instance;
      if (instance != null && dispose != null) {
        dispose(instance);
      }
    });
    final existing = _registry[T];
    _registry[T] = provider;
    if (existing != null) {
      final listeners = existing.listeners.toList();
      existing.listeners = [];
      existing.dependencies = [];
      existing.dispose?.call();
      for (final listener in listeners) {
        listener.rebuild();
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
    this.update,
    this.dispose,
  );

  final T Function(Locator) create;
  final T Function(Locator, T oldInstance)? update;
  final Locator locator;

  final int id = _id++;
  T? _instance;
  T? _oldInstance;

  List<InstanceFactory> listeners = [];
  List<InstanceFactory> dependencies = [];

  final Function()? dispose;

  late final DependencyTracker _tracker = DependencyTracker(this);

  T get instance {
    if (_instance == null) {
      _tracker.create();
      late final T i;
      if (_oldInstance != null && update != null) {
        // ignore: null_check_on_nullable_type_parameter
        i = update!.call(locator, _oldInstance!);
      } else {
        i = create(locator);
      }
      _tracker.created();
      // print("$T\n"
      //     "\t-depends on: ${dependencies.map((e) => e.runtimeType)}\n"
      //     "\t-Listeners: ${listeners.map((e) => e.runtimeType)}\n");
      _instance = i;
    } else {
      _tracker.create();
      _tracker.created();
    }
    return _instance!;
  }

  void rebuild() {
    dispose?.call();
    final listeners = this.listeners.toList();
    dependencies = [];
    this.listeners = [];
    _oldInstance = _instance;
    _instance = null;

    // invalidate existing dependency instances
    for (final provider in listeners) {
      _tracker.create();
      provider.rebuild();
      _tracker.created();
    }

    // create instance
    // instance;
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
      provider.listeners.add(listener);
      listener.dependencies.add(provider);
    }
  }

  void created() {
    _active = _prevActive;
  }
}
