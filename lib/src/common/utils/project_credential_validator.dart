/// Validates project credentials, such as project id and secret, and throws
/// errors if they are invalid.
///
/// Does validation only in debug mode to prevent crashing production applications.
class ProjectCredentialValidator {
  const ProjectCredentialValidator();

  Future<void> validate({
    required String projectId,
    required String secret,
  }) async {
    assert(() {
      if (projectId == 'YOUR-PROJECT-ID') {
        throw ArgumentError.value(
          projectId,
          'projectId',
          "It seems like you forgot to add the projectId from your Wiredash console in your Wiredash widget.",
        );
      }

      if (secret == 'YOUR-SECRET') {
        throw ArgumentError.value(
          secret,
          'secret',
          "It seems like you forgot to add the secret from your Wiredash console in your Wiredash widget.",
        );
      }

      // TODO: In the future, send projectId & secret to the backend server for validation.
      return true;
    }());
  }
}
