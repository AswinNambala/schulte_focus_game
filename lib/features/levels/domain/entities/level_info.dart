import 'package:equatable/equatable.dart';
import '../../../game/domain/entities/game_config.dart';

enum LevelOutcome {
  levelUp,
  sameLevel,
  levelDown,
}

class LevelInfo extends Equatable {
  final int levelNumber;
  final int gridSize;
  final int ringCount;
  final int targetTimeSeconds;
  final bool hasDistractors;
  final double rotationSpeed;
  final bool isUnlocked;
  final int stars;
  final int? bestTimeMs;

  const LevelInfo({
    required this.levelNumber,
    required this.gridSize,
    required this.ringCount,
    required this.targetTimeSeconds,
    this.hasDistractors = false,
    this.rotationSpeed = 0.2,
    this.isUnlocked = false,
    this.stars = 0,
    this.bestTimeMs,
  });

  GameConfig toGameConfig({
    TableType tableType = TableType.number,
    GameMode mode = GameMode.classic,
    bool colorCells = true,
    bool colorblindPalette = false,
    bool autoRotation = false,
  }) {
    return GameConfig(
      tableType: tableType,
      mode: mode,
      gridSize: gridSize,
      ringCount: ringCount,
      level: levelNumber,
      targetTimeSeconds: targetTimeSeconds,
      colorCells: colorCells,
      colorblindPalette: colorblindPalette,
      distractorRotations: hasDistractors,
      autoRotation: autoRotation,
      rotationSpeed: rotationSpeed,
    );
  }

  LevelInfo copyWith({
    int? levelNumber,
    int? gridSize,
    int? ringCount,
    int? targetTimeSeconds,
    bool? hasDistractors,
    double? rotationSpeed,
    bool? isUnlocked,
    int? stars,
    int? bestTimeMs,
  }) {
    return LevelInfo(
      levelNumber: levelNumber ?? this.levelNumber,
      gridSize: gridSize ?? this.gridSize,
      ringCount: ringCount ?? this.ringCount,
      targetTimeSeconds: targetTimeSeconds ?? this.targetTimeSeconds,
      hasDistractors: hasDistractors ?? this.hasDistractors,
      rotationSpeed: rotationSpeed ?? this.rotationSpeed,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      stars: stars ?? this.stars,
      bestTimeMs: bestTimeMs ?? this.bestTimeMs,
    );
  }

  @override
  List<Object?> get props => [
        levelNumber,
        gridSize,
        ringCount,
        targetTimeSeconds,
        hasDistractors,
        rotationSpeed,
        isUnlocked,
        stars,
        bestTimeMs,
      ];
}
