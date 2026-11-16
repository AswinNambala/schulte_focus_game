import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../game/domain/entities/game_config.dart';
import '../../../game/domain/entities/game_session.dart';
import '../../domain/entities/level_info.dart';

class LevelResultPage extends StatelessWidget {
  final GameSession session;
  final LevelOutcome outcome;
  final int stars;
  final int targetTimeSeconds;

  const LevelResultPage({
    super.key,
    required this.session,
    required this.outcome,
    required this.stars,
    required this.targetTimeSeconds,
  });

  String _formatTime(int ms) {
    final totalSeconds = ms ~/ 1000;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    final tenths = ((ms % 1000) ~/ 100).toString();
    return '$minutes:$seconds.$tenths';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color badgeColor = AppColors.primary;
    String badgeText = 'MAINTAINED: Consistent Focus';
    IconData badgeIcon = Icons.remove_rounded;

    switch (outcome) {
      case LevelOutcome.levelUp:
        badgeColor = AppColors.success;
        badgeText = 'LEVEL UP! Next Level Unlocked';
        badgeIcon = Icons.arrow_upward_rounded;
        break;
      case LevelOutcome.sameLevel:
        badgeColor = AppColors.primary;
        badgeText = 'MAINTAINED: Consistent Focus';
        badgeIcon = Icons.remove_rounded;
        break;
      case LevelOutcome.levelDown:
        badgeColor = AppColors.warning;
        badgeText = 'ADAPTIVE: Recommended Ease';
        badgeIcon = Icons.arrow_downward_rounded;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Level ${session.level} Result'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const Spacer(),

              // Stars Display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final earned = index < stars;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      earned ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: earned ? Colors.amber : Colors.grey[400],
                      size: 64,
                    )
                        .animate(delay: (200 * index).ms)
                        .scale(duration: 400.ms, curve: Curves.easeOutBack),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Adaptive Outcome Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: badgeColor, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, color: badgeColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().scale(),
              const SizedBox(height: 32),

              // Stats Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildStatRow('Completion Time', _formatTime(session.completionTimeMs)),
                    const Divider(height: 20),
                    _buildStatRow('Target Time', '${targetTimeSeconds}s'),
                    const Divider(height: 20),
                    _buildStatRow('Errors', session.errors.toString()),
                    const Divider(height: 20),
                    _buildStatRow(
                      'Avg. Reaction Speed',
                      '${(session.averageTapTimeMs / 1000).toStringAsFixed(2)}s / tap',
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        final config = GameConfig(
                          level: session.level,
                          tableType: session.tableType,
                          mode: session.mode,
                          gridSize: session.gridSize,
                          ringCount: session.ringCount,
                          targetTimeSeconds: targetTimeSeconds,
                        );
                        context.pushReplacement(AppRoutes.game, extra: config);
                      },
                      child: const Text('Replay Level'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.go(AppRoutes.levels),
                      child: const Text('All Levels'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
