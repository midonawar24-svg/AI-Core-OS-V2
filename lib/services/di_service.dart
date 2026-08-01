/// Dependency Injection - بدل Singleton في بعض الأجزاء
/// يسهل الاختبار وإضافة sqflite_common_ffi

class DIContainer {
  static final DIContainer _instance = DIContainer._internal();
  factory DIContainer() => _instance;
  DIContainer._internal();

  final Map<Type, dynamic> _services = {};
  final Map<Type, Function> _factories = {};

  void registerSingleton<T>(T instance) {
    _services[T] = instance;
  }

  void registerFactory<T>(T Function() factory) {
    _factories[T] = factory;
  }

  T get<T>() {
    if (_services.containsKey(T)) {
      return _services[T] as T;
    }
    if (_factories.containsKey(T)) {
      final instance = _factories[T]!() as T;
      _services[T] = instance;
      return instance;
    }
    throw Exception('Service $T not registered');
  }

  bool isRegistered<T>() => _services.containsKey(T) || _factories.containsKey(T);

  void unregister<T>() {
    _services.remove(T);
    _factories.remove(T);
  }

  void clear() {
    _services.clear();
    _factories.clear();
  }
}

// Global accessor
final di = DIContainer();
