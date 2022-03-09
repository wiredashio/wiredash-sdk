class EmailValidator {
  const EmailValidator();

  bool validate(String email) {
    return _pattern.hasMatch(email);
  }
}

final _pattern = RegExp(
  r"^\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*",
  caseSensitive: false,
);
