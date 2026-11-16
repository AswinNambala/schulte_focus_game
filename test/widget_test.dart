import 'package:flutter_test/flutter_test.dart';
import 'package:schulte_focus/features/auth/domain/entities/user_entity.dart';
import 'package:schulte_focus/features/auth/domain/usecases/auth_usecases.dart';
import 'package:schulte_focus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:schulte_focus/features/levels/domain/entities/level_info.dart';
import 'package:schulte_focus/features/levels/domain/repositories/level_repository.dart';
import 'package:schulte_focus/features/levels/presentation/bloc/level_bloc.dart';
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
class MockLevelRepository extends Mock implements LevelRepository {}

void main() {
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockLevelRepository mockLevelRepository;

  setUp(() {
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    final mockLogin = MockLoginWithEmailUseCase();
    final mockSignUp = MockSignUpWithEmailUseCase();
    final mockGoogle = MockSignInWithGoogleUseCase();
    final mockReset = MockSendPasswordResetUseCase();
    final mockLogout = MockLogOutUseCase();
    mockLevelRepository = MockLevelRepository();

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

    when(() => mockLevelRepository.getLevels()).thenAnswer(
      (_) async => [
        const LevelInfo(
          levelNumber: 1,
          gridSize: 3,
          ringCount: 1,
          targetTimeSeconds: 20,
          isUnlocked: true,
        ),
      ],
    );
    when(() => mockLevelRepository.getHighestUnlockedLevel()).thenAnswer((_) async => 1);

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
    di.sl.registerFactory<LevelBloc>(() => LevelBloc(repository: mockLevelRepository));
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
