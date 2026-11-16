import 'package:hive/hive.dart';
import '../../domain/entities/level_info.dart';
import '../../domain/repositories/level_repository.dart';
import '../../domain/services/adaptive_difficulty_service.dart';

class LevelRepositoryImpl implements LevelRepository {
  static const String boxName = 'levels_progress_box';
  Box? _box;

  Future<Box> _getBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox(boxName);
    return _box!;
  }

  @override
  Future<List<LevelInfo>> getLevels() async {
    final box = await _getBox();
    final int highestUnlocked = (box.get('highest_unlocked', defaultValue: 1) as num).toInt();
    final defaultLevels = AdaptiveDifficultyService.getDefaultLevels();

    return defaultLevels.map((lvl) {
      final isUnlocked = lvl.levelNumber <= highestUnlocked;
      final stars = (box.get('level_${lvl.levelNumber}_stars', defaultValue: 0) as num).toInt();
      final bestTime = box.get('level_${lvl.levelNumber}_best_time') as int?;

      return lvl.copyWith(
        isUnlocked: isUnlocked,
        stars: stars,
        bestTimeMs: bestTime,
      );
    }).toList();
  }

  @override
  Future<void> updateLevelProgress({
    required int levelNumber,
    required int stars,
    required int completionTimeMs,
  }) async {
    final box = await _getBox();

    final currentStars = (box.get('level_${levelNumber}_stars', defaultValue: 0) as num).toInt();
    if (stars > currentStars) {
      await box.put('level_${levelNumber}_stars', stars);
    }

    final currentBest = box.get('level_${levelNumber}_best_time') as int?;
    if (currentBest == null || completionTimeMs < currentBest) {
      await box.put('level_${levelNumber}_best_time', completionTimeMs);
    }

    final highestUnlocked = (box.get('highest_unlocked', defaultValue: 1) as num).toInt();
    if (levelNumber >= highestUnlocked && stars >= 1 && levelNumber < 20) {
      await box.put('highest_unlocked', levelNumber + 1);
    }
  }

  @override
  Future<int> getHighestUnlockedLevel() async {
    final box = await _getBox();
    return (box.get('highest_unlocked', defaultValue: 1) as num).toInt();
  }
}
