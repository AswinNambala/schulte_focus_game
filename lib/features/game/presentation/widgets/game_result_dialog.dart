import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/game_session.dart';

class GameResultDialog extends StatelessWidget {
  final GameSession session;
  final int stars;
  final VoidCallback onPlayAgain;
  final VoidCallback onContinue;
  final VoidCallback? onNextLevel;

  const GameResultDialog({
    super.key,
    required this.session,
    required this.stars,
    required this.onPlayAgain,
    required this.onContinue,
    this.onNextLevel,
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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stars Animation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final earned = index < stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    earned ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: earned ? Colors.amber : Colors.grey[600],
                    size: 48,
                  )
                      .animate(delay: (200 * index).ms)
                      .scale(duration: 400.ms, curve: Curves.easeOutBack),
                );
              }),
            ),
            const SizedBox(height: 12),

            Text(
              stars == 3
                  ? 'Excellent Focus!'
                  : (stars == 2 ? 'Great Job!' : 'Completed!'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Level ${session.level} Cleared ($stars/3 Stars)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),

            // Metrics Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildMetricRow('Time', _formatTime(session.completionTimeMs)),
                  const Divider(height: 16),
                  _buildMetricRow('Errors', session.errors.toString()),
                  const Divider(height: 16),
                  _buildMetricRow(
                    'Avg. Tap Time',
                    '${(session.averageTapTimeMs / 1000).toStringAsFixed(2)}s',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Next Level Button (Primary)
            if (onNextLevel != null) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(
                    'Play Level ${session.level + 1}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: onNextLevel,
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Secondary Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: onPlayAgain,
                    child: const Text('Replay'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: onContinue,
                    child: const Text('All Levels'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
