import '../entities/level_info.dart';

abstract class LevelRepository {
  Future<List<LevelInfo>> getLevels();
  Future<void> updateLevelProgress({
    required int levelNumber,
    required int stars,
    required int completionTimeMs,
  });
  Future<int> getHighestUnlockedLevel();
}
