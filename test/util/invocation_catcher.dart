/// Keeps track of method invocations
class MethodInvocationCatcher {
  MethodInvocationCatcher(this.methodName);

  final String methodName;

  final List<AssertableInvocation> _invocations = [];

  List<AssertableInvocation> get invocations =>
      _invocations.toList(growable: false);

  void clear() {
    _invocations.clear();
  }

  AssertableInvocation get latest {
    if (_invocations.isEmpty) {
      throw "$methodName was not called.";
    }
    return _invocations.last;
  }

  int get count => _invocations.length;

  MockedReturnValue<dynamic>? addMethodCall({
    Map<String, Object?>? namedArgs,
    List<Object?>? args,
  }) {
    final iv = Invocation.method(
      Symbol(methodName),
      args,
      namedArgs?.map((key, value) => MapEntry(Symbol(key), value)),
    );
    _invocations.add(AssertableInvocation(iv));
    if (interceptor != null) {
      return MockedReturnValue(interceptor!.call(iv));
    }
    return null;
  }

  MockedReturnValue<Future<dynamic>>? addAsyncMethodCall({
    Map<String, Object?>? namedArgs,
    List<Object?>? args,
  }) {
    final iv = Invocation.method(
      Symbol(methodName),
      args,
      namedArgs?.map((key, value) => MapEntry(Symbol(key), value)),
    );
    _invocations.add(AssertableInvocation(iv));
    if (interceptor != null) {
      return MockedReturnValue(interceptor!.call(iv) as Future<dynamic>);
    }
    return null;
  }

  /// Add an interceptor to get a callback when a method is called or return mock data to the caller
  dynamic Function(Invocation invocation)? interceptor;

  void verifyInvocationCount(int n) {
    if (_invocations.length == n) {
      return;
    }
    throw 'Expected $n invocations, actual invocations: ${_invocations.length}\n${_invocations.join('\n')}';
  }

  void verifyHasNoInvocation() {
    if (_invocations.isEmpty) {
      return;
    }
    throw 'There have been ${_invocations.length} invocations - '
        'zero where expected. Invocations where:\n${_invocations.join('\n')}';
  }
}

class MockedReturnValue<T> {
  MockedReturnValue(this.value);
  final T value;
}

/// A invocation which can be used to assert specific values
class AssertableInvocation {
  AssertableInvocation(this.original);

  final Invocation original;

  Object? operator [](dynamic argument) {
    if (argument is int) {
      try {
        return original.positionalArguments[argument];
        // ignore: avoid_catching_errors
      } on RangeError {
        throw "there is no positional arguments at index $argument."
            "\nInvocation: $this";
      }
    }
    if (argument is String) {
      if (!original.namedArguments.containsKey(Symbol(argument))) {
        throw "there is no positional arguments named $argument."
            "\nInvocation: $this";
      }
      return original.namedArguments[Symbol(argument)];
    }
    throw 'argument $argument is neither a int nor a String'
        ' and can not get a positional or named argument';
  }

  @override
  String toString() {
    return "${original.memberName}(named: ${original.namedArguments}, positional: ${original.positionalArguments})";
  }
}
