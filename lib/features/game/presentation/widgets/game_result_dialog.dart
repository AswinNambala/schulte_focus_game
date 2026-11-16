import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/game_session.dart';

class GameResultDialog extends StatelessWidget {
  final GameSession session;
  final int stars;
  final VoidCallback onPlayAgain;
  final VoidCallback onContinue;

  const GameResultDialog({
    super.key,
    required this.session,
    required this.stars,
    required this.onPlayAgain,
    required this.onContinue,
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
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
                    color: earned ? Colors.amber : Colors.grey[400],
                    size: 48,
                  )
                      .animate(delay: (200 * index).ms)
                      .scale(duration: 400.ms, curve: Curves.easeOutBack),
                );
              }),
            ),
            const SizedBox(height: 16),

            Text(
              stars == 3
                  ? 'Excellent Focus!'
                  : (stars == 2 ? 'Great Job!' : 'Completed!'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

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
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPlayAgain,
                    child: const Text('Play Again'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onContinue,
                    child: const Text('Continue'),
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
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
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
