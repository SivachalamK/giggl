class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error occurred']);
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

class PaymentException extends AppException {
  const PaymentException(super.message, {super.code});
}
