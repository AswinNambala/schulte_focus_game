import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithEmailUseCase {
  final AuthRepository repository;
  LoginWithEmailUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) {
    return repository.loginWithEmail(email: email, password: password);
  }
}

class SignUpWithEmailUseCase {
  final AuthRepository repository;
  SignUpWithEmailUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String displayName,
  }) {
    return repository.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}

class SignInWithGoogleUseCase {
  final AuthRepository repository;
  SignInWithGoogleUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() {
    return repository.signInWithGoogle();
  }
}

class SendPasswordResetUseCase {
  final AuthRepository repository;
  SendPasswordResetUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String email) {
    return repository.sendPasswordResetEmail(email);
  }
}

class GetCurrentUserUseCase {
  final AuthRepository repository;
  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, UserEntity?>> call() {
    return repository.getCurrentUser();
  }
}

class LogOutUseCase {
  final AuthRepository repository;
  LogOutUseCase(this.repository);

  Future<Either<Failure, Unit>> call() {
    return repository.logOut();
  }
}
