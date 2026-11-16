import 'package:flutter_test/flutter_test.dart';
import 'package:schulte_focus/features/levels/domain/entities/level_info.dart';
import 'package:schulte_focus/features/levels/domain/services/adaptive_difficulty_service.dart';

void main() {
  group('AdaptiveDifficultyService Tests', () {
    test('generates exactly 20 progressive levels with level 1 unlocked', () {
      final levels = AdaptiveDifficultyService.getDefaultLevels();
      expect(levels.length, 20);
      expect(levels.first.levelNumber, 1);
      expect(levels.first.isUnlocked, true);
      expect(levels.last.levelNumber, 20);
      expect(levels.last.isUnlocked, false);
    });

    test('evaluates LevelOutcome.levelUp when finish under target time with <= 1 error', () {
      final outcome = AdaptiveDifficultyService.evaluateOutcome(
        completionTimeMs: 25000,
        errors: 1,
        targetTimeSeconds: 30, // 30,000ms
        currentLevel: 5,
      );

      expect(outcome, LevelOutcome.levelUp);
    });

    test('evaluates LevelOutcome.levelDown when taking > 1.5x target time', () {
      final outcome = AdaptiveDifficultyService.evaluateOutcome(
        completionTimeMs: 46000,
        errors: 0,
        targetTimeSeconds: 30, // 1.5x is 45,000ms
        currentLevel: 5,
      );

      expect(outcome, LevelOutcome.levelDown);
    });

    test('evaluates LevelOutcome.levelDown when making 3 or more errors', () {
      final outcome = AdaptiveDifficultyService.evaluateOutcome(
        completionTimeMs: 20000,
        errors: 3,
        targetTimeSeconds: 30,
        currentLevel: 5,
      );

      expect(outcome, LevelOutcome.levelDown);
    });

    test('evaluates LevelOutcome.sameLevel when between normal and ease threshold', () {
      final outcome = AdaptiveDifficultyService.evaluateOutcome(
        completionTimeMs: 35000,
        errors: 2,
        targetTimeSeconds: 30,
        currentLevel: 5,
      );

      expect(outcome, LevelOutcome.sameLevel);
    });

    test('calculates stars accurately (3 stars, 2 stars, 1 star)', () {
      // 3 stars: under target time with <= 1 error
      final threeStars = AdaptiveDifficultyService.calculateStars(
        completionTimeMs: 28000,
        errors: 0,
        targetTimeSeconds: 30,
      );
      expect(threeStars, 3);

      // 2 stars: under 1.5x target time with <= 3 errors
      final twoStars = AdaptiveDifficultyService.calculateStars(
        completionTimeMs: 40000,
        errors: 2,
        targetTimeSeconds: 30,
      );
      expect(twoStars, 2);

      // 1 star: otherwise
      final oneStar = AdaptiveDifficultyService.calculateStars(
        completionTimeMs: 60000,
        errors: 5,
        targetTimeSeconds: 30,
      );
      expect(oneStar, 1);
    });
  });
}
