import 'package:flutter_test/flutter_test.dart';
import 'package:schulte_focus/features/auth/domain/entities/user_entity.dart';
import 'package:schulte_focus/features/auth/domain/usecases/auth_usecases.dart';
import 'package:schulte_focus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:schulte_focus/core/di/injection.dart' as di;
import 'package:schulte_focus/core/theme/theme_cubit.dart';
import 'package:schulte_focus/main.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}
class MockLoginWithEmailUseCase extends Mock implements LoginWithEmailUseCase {}
class MockSignUpWithEmailUseCase extends Mock implements SignUpWithEmailUseCase {}
class MockSignInWithGoogleUseCase extends Mock implements SignInWithGoogleUseCase {}
class MockSendPasswordResetUseCase extends Mock implements SendPasswordResetUseCase {}
class MockLogOutUseCase extends Mock implements LogOutUseCase {}

void main() {
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;

  setUp(() {
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    final mockLogin = MockLoginWithEmailUseCase();
    final mockSignUp = MockSignUpWithEmailUseCase();
    final mockGoogle = MockSignInWithGoogleUseCase();
    final mockReset = MockSendPasswordResetUseCase();
    final mockLogout = MockLogOutUseCase();

    when(() => mockGetCurrentUserUseCase()).thenAnswer(
      (_) async => Right(
        UserEntity(
          uid: 'uid1',
          email: 'test@example.com',
          displayName: 'Player',
          createdAt: DateTime(2026, 1, 1),
        ),
      ),
    );

    di.sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
    di.sl.registerFactory<AuthBloc>(
      () => AuthBloc(
        getCurrentUserUseCase: mockGetCurrentUserUseCase,
        loginWithEmailUseCase: mockLogin,
        signUpWithEmailUseCase: mockSignUp,
        signInWithGoogleUseCase: mockGoogle,
        sendPasswordResetUseCase: mockReset,
        logOutUseCase: mockLogout,
      ),
    );
  });

  tearDown(() async {
    await di.sl.reset();
  });

  testWidgets('App renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const SchulteFocusApp());
    await tester.pumpAndSettle();
    expect(find.byType(SchulteFocusApp), findsOneWidget);
  });
}
