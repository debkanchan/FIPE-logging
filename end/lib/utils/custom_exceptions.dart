/// Custom Exception for when we know an exception can occur and we need to handle it.
///
/// The [message] must be a human readbable message in case it needs to be shown to the user
class ExpectedException implements Exception {
  final Object? cause;
  final String message;
  ExpectedException(this.message, [this.cause]);
}
