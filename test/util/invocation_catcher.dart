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
    if (_invocations.last == null) {
      throw "$methodName was not called.";
    }
    return _invocations.last;
  }

  int get count => _invocations.length;

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

  void addMethodCall({
    Map<String, Object?>? namedArgs,
    List<Object?>? args,
  }) {
    final iv = Invocation.method(
      Symbol(methodName),
      args,
      namedArgs?.map((key, value) => MapEntry(Symbol(key), value)),
    );
    _invocations.add(AssertableInvocation(iv));
  }
}

class AssertableInvocation {
  AssertableInvocation(this.original);

  final Invocation original;

  Object? operator [](dynamic argument) {
    if (argument is int) {
      return original.positionalArguments[argument];
    }
    if (argument is String) {
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
