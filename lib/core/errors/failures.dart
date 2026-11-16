import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred. Please try again.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed. Please verify your credentials.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'A local storage error occurred.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection detected. Working in offline mode.']);
}

class GameValidationFailure extends Failure {
  const GameValidationFailure([super.message = 'Invalid game configuration or action.']);
}
