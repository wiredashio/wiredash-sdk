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

  AssertableInvocation? get latest => _invocations.last;

  int get count => _invocations.length;

  void catchMethodCall({
    Map<String, Object?>? namedArgs,
    List<Object?>? positionalArguments,
  }) {
    final iv = Invocation.method(
      Symbol(methodName),
      positionalArguments,
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
    throw "argument $argument is neither a int nor a String"
        " and can't get a positional or named argument";
  }
}
