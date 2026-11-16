import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:schulte_focus/core/errors/failures.dart';
import 'package:schulte_focus/features/auth/domain/repositories/auth_repository.dart';
import 'package:schulte_focus/features/auth/domain/usecases/auth_usecases.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late DeleteAccountUseCase deleteAccountUseCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    deleteAccountUseCase = DeleteAccountUseCase(mockRepository);
  });

  group('DeleteAccountUseCase Tests', () {
    test('calls repository.deleteAccount and returns unit on success', () async {
      when(() => mockRepository.deleteAccount(password: 'mySecretPass'))
          .thenAnswer((_) async => const Right(unit));

      final result = await deleteAccountUseCase(password: 'mySecretPass');

      expect(result, const Right(unit));
      verify(() => mockRepository.deleteAccount(password: 'mySecretPass')).called(1);
    });

    test('returns AuthFailure when repository fails', () async {
      when(() => mockRepository.deleteAccount(password: any(named: 'password')))
          .thenAnswer((_) async => const Left(AuthFailure('Invalid password')));

      final result = await deleteAccountUseCase(password: 'wrongPass');

      expect(result, const Left(AuthFailure('Invalid password')));
      verify(() => mockRepository.deleteAccount(password: 'wrongPass')).called(1);
    });
  });
}
