/// Exception thrown when server returns an error
class ServerException implements Exception {
  final String message;

  const ServerException([this.message = 'Server error occurred']);

  @override
  String toString() => 'ServerException: $message';
}

/// Exception thrown when cache operation fails
class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Cache operation failed']);

  @override
  String toString() => 'CacheException: $message';
}

/// Exception thrown when network is unavailable
class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'Network unavailable']);

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown during authentication
class AuthException implements Exception {
  final String message;

  const AuthException([this.message = 'Authentication failed']);

  @override
  String toString() => 'AuthException: $message';
}
