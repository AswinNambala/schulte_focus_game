import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../game/domain/entities/game_config.dart';
import '../../../levels/presentation/bloc/level_bloc.dart';
import '../../../levels/presentation/bloc/level_state.dart';
import '../../../reports/presentation/bloc/report_bloc.dart';
import '../../../reports/presentation/bloc/report_state.dart';
import '../../../settings/presentation/bloc/settings_cubit.dart';
import '../../../settings/domain/entities/app_settings.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schulte Focus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'View Reports',
            onPressed: () => context.go(AppRoutes.reports),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.go(AppRoutes.profile),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Trigger refresh if needed
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Welcome Header
            _buildWelcomeHeader(context),
            const SizedBox(height: 16),

            // Daily Streak Banner
            _buildStreakBanner(context),
            const SizedBox(height: 20),

            // Continue Level Card
            _buildContinueLevelCard(context),
            const SizedBox(height: 24),

            // Quick Play Modes
            Text(
              'QUICK PLAY MODES',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            _buildQuickPlayGrid(context),
            const SizedBox(height: 24),

            // Performance Snapshot
            Text(
              'TRAINING SNAPSHOT',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatsSnapshot(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String name = 'Trainer';
        if (authState.status == AuthStatus.authenticated && authState.user != null) {
          final displayName = authState.user!.displayName;
          if (displayName.isNotEmpty) {
            name = displayName.split(' ').first;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $name 👋',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Expand your field of view and sharpen your mental agility.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStreakBanner(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<SettingsCubit, AppSettings>(
      builder: (context, settings) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.deepOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: BorderSide(color: Colors.deepOrange.withValues(alpha: 0.3)).toBorder(),
          ),
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${settings.currentStreak} Day Streak',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    Text(
                      settings.currentStreak > 0
                          ? 'Consistent daily practice doubles visual reaction speed!'
                          : 'Play a game today to activate your daily streak!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContinueLevelCard(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<LevelBloc, LevelState>(
      builder: (context, levelState) {
        int currentLevelNum = 1;
        int targetSeconds = 60;
        int stars = 0;

        if (levelState.status == LevelStatus.loaded) {
          currentLevelNum = levelState.highestUnlocked;
          final lvl = levelState.levels.firstWhere(
            (l) => l.levelNumber == currentLevelNum,
            orElse: () => levelState.levels.first,
          );
          targetSeconds = lvl.targetTimeSeconds;
          stars = lvl.stars;
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.tertiary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'CURRENT PROGRESS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(3, (index) {
                      return Icon(
                        index < stars ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Level $currentLevelNum',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Target time: ${targetSeconds}s • Adaptive visual scaling',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow_rounded, size: 26),
                label: const Text('Continue Training', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: theme.colorScheme.primary,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  if (levelState.status == LevelStatus.loaded) {
                    final lvl = levelState.levels.firstWhere(
                      (l) => l.levelNumber == currentLevelNum,
                      orElse: () => levelState.levels.first,
                    );
                    context.push(
                      AppRoutes.game,
                      extra: lvl.toGameConfig(),
                    );
                  } else {
                    context.push(
                      AppRoutes.game,
                      extra: const GameConfig(level: 1, gridSize: 5),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickPlayGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        _buildModeCard(
          context,
          title: 'Classic 123',
          subtitle: '5x5 Number Grid',
          icon: Icons.grid_4x4_rounded,
          color: Colors.blueAccent,
          onTap: () {
            context.push(
              AppRoutes.game,
              extra: const GameConfig(
                tableType: TableType.number,
                mode: GameMode.classic,
                gridSize: 5,
              ),
            );
          },
        ),
        _buildModeCard(
          context,
          title: 'Classic ABC',
          subtitle: '5x5 Letter Grid',
          icon: Icons.sort_by_alpha_rounded,
          color: Colors.purpleAccent,
          onTap: () {
            context.push(
              AppRoutes.game,
              extra: const GameConfig(
                tableType: TableType.letter,
                mode: GameMode.classic,
                gridSize: 5,
              ),
            );
          },
        ),
        _buildModeCard(
          context,
          title: '3D Ring 123',
          subtitle: 'Concentric Numbers',
          icon: Icons.album_outlined,
          color: Colors.teal,
          onTap: () {
            context.push(
              AppRoutes.game,
              extra: const GameConfig(
                tableType: TableType.number,
                mode: GameMode.circular3d,
                ringCount: 2,
              ),
            );
          },
        ),
        _buildModeCard(
          context,
          title: '3D Ring ABC',
          subtitle: 'Concentric Letters',
          icon: Icons.motion_photos_on_outlined,
          color: Colors.amber.shade800,
          onTap: () {
            context.push(
              AppRoutes.game,
              extra: const GameConfig(
                tableType: TableType.letter,
                mode: GameMode.circular3d,
                ringCount: 2,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color, size: 20),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSnapshot(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, reportState) {
        int totalSessions = 0;
        String bestTimeStr = '--:--';

        if (reportState.status == ReportStatus.loaded) {
          totalSessions = reportState.metrics.totalSessions;
          final bestMs = reportState.metrics.bestTimeMs;
          if (bestMs > 0) {
            final secs = (bestMs / 1000).toStringAsFixed(1);
            bestTimeStr = '${secs}s';
          }
        }

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, 'Total Games', '$totalSessions', Icons.sports_score_rounded),
                Container(
                  height: 40,
                  width: 1,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                _buildStatItem(context, 'Best Record', bestTimeStr, Icons.emoji_events_outlined),
                Container(
                  height: 40,
                  width: 1,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                TextButton(
                  onPressed: () => context.go(AppRoutes.reports),
                  child: const Text('View All >'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
extension on BorderSide {
  Border toBorder() => Border.fromBorderSide(this);
}
