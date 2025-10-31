import 'package:equatable/equatable.dart';

/// Base class for failures in the application
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Failure when network is unavailable
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message =
        'Network connection error. Please check your internet connection.',
  ]);
}

/// Failure during authentication
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

/// Failure when accessing cache
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to access local cache.']);
}

/// Failure from server/API
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred.']);
}

/// Failure during validation
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed.']);
}
