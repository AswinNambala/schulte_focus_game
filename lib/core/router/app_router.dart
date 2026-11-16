import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/privacy_policy_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/game/domain/entities/game_config.dart';
import '../../features/game/domain/entities/game_session.dart';
import '../../features/game/presentation/pages/game_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/levels/domain/entities/level_info.dart';
import '../../features/levels/presentation/pages/level_result_page.dart';
import '../../features/levels/presentation/pages/levels_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String levels = '/levels';
  static const String reports = '/reports';
  static const String profile = '/profile';
  static const String game = '/game';
  static const String levelResult = '/level-result';
  static const String privacyPolicy = '/privacy-policy';
}

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.splash,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.signup,
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(
          path: AppRoutes.privacyPolicy,
          builder: (context, state) => const PrivacyPolicyPage(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return Scaffold(
              body: navigationShell,
              bottomNavigationBar: NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: (index) => navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                ),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.grid_view_outlined),
                    selectedIcon: Icon(Icons.grid_view_rounded),
                    label: 'Levels',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bar_chart_outlined),
                    selectedIcon: Icon(Icons.bar_chart_rounded),
                    label: 'Report',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            );
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.home,
                  builder: (context, state) => const HomePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.levels,
                  builder: (context, state) => const LevelsPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.reports,
                  builder: (context, state) => const ReportsPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.profile,
                  builder: (context, state) => const SettingsPage(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.game,
          builder: (context, state) {
            final config = state.extra is GameConfig
                ? state.extra as GameConfig
                : const GameConfig();
            return GamePage(config: config);
          },
        ),
        GoRoute(
          path: AppRoutes.levelResult,
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>? ?? {};
            final session = args['session'] as GameSession? ??
                GameSession(
                  id: 'session_dummy',
                  userId: '',
                  tableType: TableType.number,
                  mode: GameMode.classic,
                  level: 1,
                  gridSize: 5,
                  ringCount: 2,
                  totalCells: 25,
                  completionTimeMs: 45000,
                  errors: 0,
                  perTapTimesMs: const [],
                  createdAt: DateTime.now(),
                );
            final outcome = args['outcome'] as LevelOutcome? ?? LevelOutcome.levelUp;
            final stars = args['stars'] as int? ?? 3;
            final targetSeconds = args['targetTimeSeconds'] as int? ?? 60;

            return LevelResultPage(
              session: session,
              outcome: outcome,
              stars: stars,
              targetTimeSeconds: targetSeconds,
            );
          },
        ),
      ],
    );
  }
}
