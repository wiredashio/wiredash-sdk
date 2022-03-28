/// https://github.com/passsy/kt.dart/blob/master/lib/standard.dart#L24
extension StandardKt<T> on T {
  /// Calls the specified function [block] with `this` value as its argument and returns its result.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  R let<R>(R Function(T) block) {
    return block(this);
  }
}
