// lib/core/error/app_error.dart
class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppError(this.message, {this.code, this.details});

  @override
  String toString() => 'AppError: $message${code != null ? ' (Code: $code)' : ''}';
}

class NetworkError extends AppError {
  const NetworkError(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

class ValidationError extends AppError {
  final Map<String, String> fieldErrors;

  const ValidationError(String message, this.fieldErrors, {String? code})
      : super(message, code: code);
}

class AuthenticationError extends AppError {
  const AuthenticationError(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

class BusinessLogicError extends AppError {
  const BusinessLogicError(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

class StorageError extends AppError {
  const StorageError(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}