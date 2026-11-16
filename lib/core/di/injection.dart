import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/levels/data/repositories/level_repository_impl.dart';
import '../../features/levels/domain/repositories/level_repository.dart';
import '../../features/levels/presentation/bloc/level_bloc.dart';
import '../../features/reports/data/repositories/report_repository_impl.dart';
import '../../features/reports/domain/repositories/report_repository.dart';
import '../../features/reports/domain/usecases/report_usecases.dart';
import '../../features/reports/presentation/bloc/report_bloc.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/presentation/bloc/settings_cubit.dart';
import '../theme/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External Firebase Services
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Theme Cubit
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());

  // Auth Feature
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      googleSignIn: sl(),
      firestore: sl(),
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Auth Use Cases
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => SignUpWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => SendPasswordResetUseCase(sl()));
  sl.registerLazySingleton(() => LogOutUseCase(sl()));

  // Auth Bloc
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      getCurrentUserUseCase: sl(),
      loginWithEmailUseCase: sl(),
      signUpWithEmailUseCase: sl(),
      signInWithGoogleUseCase: sl(),
      sendPasswordResetUseCase: sl(),
      logOutUseCase: sl(),
    ),
  );

  // Levels Feature
  sl.registerLazySingleton<LevelRepository>(() => LevelRepositoryImpl());
  sl.registerFactory<LevelBloc>(() => LevelBloc(repository: sl()));

  // Reports Feature
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(firestore: sl()),
  );
  sl.registerLazySingleton(() => GetReportsUseCase(sl()));
  sl.registerLazySingleton(() => SaveSessionUseCase(sl()));
  sl.registerFactory<ReportBloc>(
    () => ReportBloc(
      getReportsUseCase: sl(),
      saveSessionUseCase: sl(),
    ),
  );

  // Settings Feature
  sl.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl());
  sl.registerFactory<SettingsCubit>(() => SettingsCubit(repository: sl()));
}
