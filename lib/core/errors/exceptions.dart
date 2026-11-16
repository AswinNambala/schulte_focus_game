class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server exception occurred']);

  @override
  String toString() => 'ServerException: $message';
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Auth exception occurred']);

  @override
  String toString() => 'AuthException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache exception occurred']);

  @override
  String toString() => 'CacheException: $message';
}
