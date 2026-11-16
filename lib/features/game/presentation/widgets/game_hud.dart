import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class GameHud extends StatelessWidget {
  final String nextTarget;
  final int elapsedMs;
  final int errors;
  final VoidCallback onPause;

  const GameHud({
    super.key,
    required this.nextTarget,
    required this.elapsedMs,
    required this.errors,
    required this.onPause,
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Next Target Indicator
          Row(
            children: [
              Text(
                'TARGET:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  nextTarget,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          // Elapsed Timer
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                _formatTime(elapsedMs),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Errors & Pause
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: errors > 0
                      ? AppColors.error.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 16,
                      color: errors > 0 ? AppColors.error : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      errors.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: errors > 0 ? AppColors.error : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.pause_circle_filled_rounded, size: 28),
                color: AppColors.primary,
                onPressed: onPause,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
