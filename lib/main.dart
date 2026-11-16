import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/di/injection.dart' as di;
import 'core/observer/app_bloc_observer.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/levels/presentation/bloc/level_bloc.dart';
import 'features/levels/presentation/bloc/level_event.dart';
import 'features/reports/presentation/bloc/report_bloc.dart';
import 'features/settings/domain/entities/app_settings.dart';
import 'features/settings/presentation/bloc/settings_cubit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive Flutter
  await Hive.initFlutter();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up Crashlytics error handlers
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set up Bloc Observer
  Bloc.observer = AppBlocObserver();

  // Initialize Dependency Injection
  await di.initDependencies();

  runApp(const SchulteFocusApp());
}

class SchulteFocusApp extends StatelessWidget {
  const SchulteFocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(
          create: (_) => di.sl<SettingsCubit>()..loadSettings(),
        ),
        BlocProvider<ThemeCubit>(
          create: (_) => di.sl<ThemeCubit>(),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>(),
        ),
        BlocProvider<LevelBloc>(
          create: (_) => di.sl<LevelBloc>()..add(LoadLevelsEvent()),
        ),
        BlocProvider<ReportBloc>(
          create: (_) => di.sl<ReportBloc>(),
        ),
      ],
      child: BlocBuilder<SettingsCubit, AppSettings>(
        builder: (context, settings) {
          final router = AppRouter.createRouter();
          return MaterialApp.router(
            title: 'Schulte Focus',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
