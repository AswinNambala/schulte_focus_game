import '../entities/level_info.dart';

class AdaptiveDifficultyService {
  /// Generates the standard definitions for levels 1 to 20
  static List<LevelInfo> getDefaultLevels() {
    return List.generate(20, (index) {
      final level = index + 1;
      int gridSize;
      int ringCount;
      int targetSeconds;
      bool distractors = level >= 6;
      double speed = 0.15 + (level * 0.015);

      if (level <= 3) {
        gridSize = 3; // 9 cells
        ringCount = 1; // 8 cells
        targetSeconds = 12 + (level * 2);
      } else if (level <= 7) {
        gridSize = 4; // 16 cells
        ringCount = 2; // 18 cells
        targetSeconds = 25 + (level * 3);
      } else if (level <= 12) {
        gridSize = 5; // 25 cells
        ringCount = 2; // 18 cells
        targetSeconds = 45 + (level * 2);
      } else if (level <= 17) {
        gridSize = 6; // 36 cells
        ringCount = 3; // 27 cells
        targetSeconds = 75 + (level * 2);
      } else {
        gridSize = 7; // 49 cells
        ringCount = 3; // 27 cells
        targetSeconds = 110 + (level * 2);
      }

      return LevelInfo(
        levelNumber: level,
        gridSize: gridSize,
        ringCount: ringCount,
        targetTimeSeconds: targetSeconds,
        hasDistractors: distractors,
        rotationSpeed: speed,
        isUnlocked: level == 1, // Level 1 is unlocked initially
        stars: 0,
      );
    });
  }

  /// Adaptive Logic:
  /// - Under target time with <= 1 error: level up
  /// - Over target time limit OR 3+ errors: level down / fail
  /// - Otherwise: stay at same level
  static LevelOutcome evaluateOutcome({
    required int completionTimeMs,
    required int errors,
    required int targetTimeSeconds,
    required int currentLevel,
  }) {
    final targetTimeMs = targetTimeSeconds * 1000;

    if (completionTimeMs > targetTimeMs || errors >= 3) {
      return currentLevel > 1 ? LevelOutcome.levelDown : LevelOutcome.sameLevel;
    } else if (completionTimeMs <= targetTimeMs && errors <= 1) {
      return currentLevel < 20 ? LevelOutcome.levelUp : LevelOutcome.sameLevel;
    } else {
      return LevelOutcome.sameLevel;
    }
  }

  /// Calculates stars earned (0 to 3):
  /// - Exceeded target time limit: 0 stars (Level Failed / Not Cleared)
  /// - Completed in <= 75% of target time with <= 1 error: 3 stars
  /// - Completed in <= 90% of target time with <= 2 errors: 2 stars
  /// - Completed within 100% of target time: 1 star
  static int calculateStars({
    required int completionTimeMs,
    required int errors,
    required int targetTimeSeconds,
  }) {
    final targetTimeMs = targetTimeSeconds * 1000;

    // Strict time limit: Exceeding time limit results in 0 stars (Level Failed)
    if (completionTimeMs > targetTimeMs) {
      return 0;
    }

    if (completionTimeMs <= (targetTimeMs * 0.75) && errors <= 1) {
      return 3;
    } else if (completionTimeMs <= (targetTimeMs * 0.90) && errors <= 2) {
      return 2;
    } else {
      return 1;
    }
  }
}
