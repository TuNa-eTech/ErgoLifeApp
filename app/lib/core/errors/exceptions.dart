/// Base exception class
class AppException implements Exception {
  final String message;
  final dynamic error;

  AppException({required this.message, this.error});

  @override
  String toString() =>
      'AppException: $message${error != null ? ' - $error' : ''}';
}

/// Server exception - thrown when API returns an error
class ServerException extends AppException {
  final int? statusCode;

  ServerException({required super.message, this.statusCode, super.error});

  @override
  String toString() =>
      'ServerException: $message (${statusCode ?? 'no status code'})${error != null ? ' - $error' : ''}';
}

/// Cache exception - thrown when local storage operations fail
class CacheException extends AppException {
  CacheException({required super.message, super.error});

  @override
  String toString() =>
      'CacheException: $message${error != null ? ' - $error' : ''}';
}

/// Network exception - thrown when there's no internet connection
class NetworkException extends AppException {
  NetworkException({super.message = 'No internet connection', super.error});

  @override
  String toString() =>
      'NetworkException: $message${error != null ? ' - $error' : ''}';
}

/// Validation exception - thrown when data validation fails
class ValidationException extends AppException {
  final Map<String, String>? errors;

  ValidationException({required super.message, this.errors, super.error});

  @override
  String toString() =>
      'ValidationException: $message${errors != null ? ' - $errors' : ''}${error != null ? ' - $error' : ''}';
}

/// Unauthorized exception - thrown when user is not authenticated
class UnauthorizedException extends AppException {
  UnauthorizedException({super.message = 'Unauthorized', super.error});

  @override
  String toString() =>
      'UnauthorizedException: $message${error != null ? ' - $error' : ''}';
}

/// Not found exception - thrown when requested resource is not found
class NotFoundException extends AppException {
  NotFoundException({super.message = 'Resource not found', super.error});

  @override
  String toString() =>
      'NotFoundException: $message${error != null ? ' - $error' : ''}';
}
