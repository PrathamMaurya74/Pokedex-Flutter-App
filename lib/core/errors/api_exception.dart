enum ApiErrorType { network, timeout, notFound, server, parsing }

/// The only error type the data layer throws, so the UI can show a clear
/// message without knowing about `http`, sockets or JSON.
class ApiException implements Exception {
  const ApiException(this.type, {this.statusCode});

  final ApiErrorType type;
  final int? statusCode;

  /// User-facing message shown in error states.
  String get message => switch (type) {
    ApiErrorType.network =>
      'No internet connection. Check your connection and try again.',
    ApiErrorType.timeout => 'The server took too long to respond. Try again.',
    ApiErrorType.notFound => 'This Pokémon could not be found.',
    ApiErrorType.server =>
      'PokéAPI is unavailable right now (error $statusCode). Try again later.',
    ApiErrorType.parsing => 'Received unexpected data from PokéAPI.',
  };

  /// Message for any error object, including unexpected ones.
  static String describe(Object error) => error is ApiException
      ? error.message
      : 'Something went wrong. Try again.';

  @override
  String toString() => 'ApiException($type, statusCode: $statusCode)';
}
