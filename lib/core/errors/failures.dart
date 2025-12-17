import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  final dynamic error;

  const Failure({required this.message, this.error});

  @override
  List<Object?> get props => [message, error];
}

/// Server failure - occurs when API returns an error
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({required super.message, this.statusCode, super.error});

  @override
  List<Object?> get props => [message, statusCode, error];
}

/// Cache failure - occurs when local storage operations fail
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.error});
}

/// Network failure - occurs when there's no internet connection
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection', super.error});
}

/// Validation failure - occurs when data validation fails
class ValidationFailure extends Failure {
  final Map<String, String>? errors;

  const ValidationFailure({required super.message, this.errors, super.error});

  @override
  List<Object?> get props => [message, errors, error];
}

/// Unauthorized failure - occurs when user is not authenticated
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = 'Unauthorized', super.error});
}

/// Not found failure - occurs when requested resource is not found
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Resource not found', super.error});
}

/// Unknown failure - occurs for unexpected errors
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred',
    super.error,
  });
}
