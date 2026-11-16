import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.splash,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Login Screen')),
          ),
        ),
        GoRoute(
          path: AppRoutes.signup,
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Sign Up Screen')),
          ),
        ),
        GoRoute(
          path: AppRoutes.privacyPolicy,
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Privacy Policy')),
          ),
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
                  builder: (context, state) => const Scaffold(
                    body: Center(child: Text('Home')),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.levels,
                  builder: (context, state) => const Scaffold(
                    body: Center(child: Text('Levels')),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.reports,
                  builder: (context, state) => const Scaffold(
                    body: Center(child: Text('Reports')),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.profile,
                  builder: (context, state) => const Scaffold(
                    body: Center(child: Text('Profile')),
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.game,
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Game Screen')),
          ),
        ),
        GoRoute(
          path: AppRoutes.levelResult,
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Level Result')),
          ),
        ),
      ],
    );
  }
}
