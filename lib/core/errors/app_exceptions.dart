
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}


class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Unable to connect. Please check your internet connection.',
  ]);
}


class ServerException extends AppException {
  const ServerException([
    super.message = 'Server error occurred. Please try again later.',
  ]);
}

class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'The requested content was not found.',
  ]);
}

class UnknownException extends AppException {
  const UnknownException([
    super.message = 'An unexpected error occurred. Please try again.',
  ]);
}
