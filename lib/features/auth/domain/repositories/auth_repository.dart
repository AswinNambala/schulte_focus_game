import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  });
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email);
  Future<Either<Failure, Unit>> logOut();
}
