import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:schulte_focus/core/errors/failures.dart';
import 'package:schulte_focus/features/auth/domain/entities/user_entity.dart';
import 'package:schulte_focus/features/auth/domain/usecases/auth_usecases.dart';
import 'package:schulte_focus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:schulte_focus/features/auth/presentation/bloc/auth_event.dart';
import 'package:schulte_focus/features/auth/presentation/bloc/auth_state.dart';

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}
class MockLoginWithEmailUseCase extends Mock implements LoginWithEmailUseCase {}
class MockSignUpWithEmailUseCase extends Mock implements SignUpWithEmailUseCase {}
class MockSignInWithGoogleUseCase extends Mock implements SignInWithGoogleUseCase {}
class MockSendPasswordResetUseCase extends Mock implements SendPasswordResetUseCase {}
class MockLogOutUseCase extends Mock implements LogOutUseCase {}

void main() {
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockLoginWithEmailUseCase mockLoginWithEmailUseCase;
  late MockSignUpWithEmailUseCase mockSignUpWithEmailUseCase;
  late MockSignInWithGoogleUseCase mockSignInWithGoogleUseCase;
  late MockSendPasswordResetUseCase mockSendPasswordResetUseCase;
  late MockLogOutUseCase mockLogOutUseCase;
  late AuthBloc authBloc;

  final testUser = UserEntity(
    uid: 'test_uid_123',
    email: 'test@example.com',
    displayName: 'Test Player',
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockLoginWithEmailUseCase = MockLoginWithEmailUseCase();
    mockSignUpWithEmailUseCase = MockSignUpWithEmailUseCase();
    mockSignInWithGoogleUseCase = MockSignInWithGoogleUseCase();
    mockSendPasswordResetUseCase = MockSendPasswordResetUseCase();
    mockLogOutUseCase = MockLogOutUseCase();

    authBloc = AuthBloc(
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
      loginWithEmailUseCase: mockLoginWithEmailUseCase,
      signUpWithEmailUseCase: mockSignUpWithEmailUseCase,
      signInWithGoogleUseCase: mockSignInWithGoogleUseCase,
      sendPasswordResetUseCase: mockSendPasswordResetUseCase,
      logOutUseCase: mockLogOutUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc Tests', () {
    test('initial state should be AuthState with initial status', () {
      expect(authBloc.state, const AuthState(status: AuthStatus.initial));
    });

    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] when AuthCheckRequested finds user',
      build: () {
        when(() => mockGetCurrentUserUseCase())
            .thenAnswer((_) async => Right(testUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        AuthState(status: AuthStatus.authenticated, user: testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, unauthenticated] when AuthCheckRequested finds no user',
      build: () {
        when(() => mockGetCurrentUserUseCase())
            .thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(status: AuthStatus.unauthenticated),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] on successful login with email',
      build: () {
        when(() => mockLoginWithEmailUseCase(
              email: 'test@example.com',
              password: 'password123',
            )).thenAnswer((_) async => Right(testUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(
          email: 'test@example.com',
          password: 'password123',
        ),
      ),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        AuthState(status: AuthStatus.authenticated, user: testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, error] on failed login with email',
      build: () {
        when(() => mockLoginWithEmailUseCase(
              email: 'test@example.com',
              password: 'wrongpassword',
            )).thenAnswer(
          (_) async => const Left(AuthFailure('Invalid credentials')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(
          email: 'test@example.com',
          password: 'wrongpassword',
        ),
      ),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(
          status: AuthStatus.error,
          errorMessage: 'Invalid credentials',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] on successful Google sign in',
      build: () {
        when(() => mockSignInWithGoogleUseCase())
            .thenAnswer((_) async => Right(testUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthGoogleSignInRequested()),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        AuthState(status: AuthStatus.authenticated, user: testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, passwordResetSent] on successful password reset request',
      build: () {
        when(() => mockSendPasswordResetUseCase('test@example.com'))
            .thenAnswer((_) async => const Right(unit));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthPasswordResetRequested('test@example.com')),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(
          status: AuthStatus.passwordResetSent,
          successMessage: 'Password reset link sent to test@example.com.',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, unauthenticated] on log out',
      build: () {
        when(() => mockLogOutUseCase())
            .thenAnswer((_) async => const Right(unit));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLogOutRequested()),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(status: AuthStatus.unauthenticated),
      ],
    );
  });
}
