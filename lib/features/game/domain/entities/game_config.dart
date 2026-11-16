import 'package:equatable/equatable.dart';

enum TableType { number, letter }

enum GameMode { classic, circular3d }

class GameConfig extends Equatable {
  final TableType tableType;
  final GameMode mode;
  final int gridSize; // For classic (3 => 3x3, 4 => 4x4, 5 => 5x5, etc.)
  final int ringCount; // For circular 3D (1, 2, or 3)
  final int totalCells;
  final int level;
  final int targetTimeSeconds;
  final bool colorCells;
  final bool colorblindPalette;
  final bool distractorRotations;
  final bool autoRotation;
  final double rotationSpeed;

  const GameConfig({
    this.tableType = TableType.number,
    this.mode = GameMode.classic,
    this.gridSize = 5,
    this.ringCount = 2,
    int? totalCells,
    this.level = 1,
    this.targetTimeSeconds = 60,
    this.colorCells = true,
    this.colorblindPalette = false,
    this.distractorRotations = false,
    this.autoRotation = false,
    this.rotationSpeed = 0.2,
  }) : totalCells = totalCells ?? (mode == GameMode.classic ? gridSize * gridSize : (ringCount == 1 ? 8 : (ringCount == 2 ? 18 : 27)));

  GameConfig copyWith({
    TableType? tableType,
    GameMode? mode,
    int? gridSize,
    int? ringCount,
    int? totalCells,
    int? level,
    int? targetTimeSeconds,
    bool? colorCells,
    bool? colorblindPalette,
    bool? distractorRotations,
    bool? autoRotation,
    double? rotationSpeed,
  }) {
    return GameConfig(
      tableType: tableType ?? this.tableType,
      mode: mode ?? this.mode,
      gridSize: gridSize ?? this.gridSize,
      ringCount: ringCount ?? this.ringCount,
      totalCells: totalCells ?? this.totalCells,
      level: level ?? this.level,
      targetTimeSeconds: targetTimeSeconds ?? this.targetTimeSeconds,
      colorCells: colorCells ?? this.colorCells,
      colorblindPalette: colorblindPalette ?? this.colorblindPalette,
      distractorRotations: distractorRotations ?? this.distractorRotations,
      autoRotation: autoRotation ?? this.autoRotation,
      rotationSpeed: rotationSpeed ?? this.rotationSpeed,
    );
  }

  @override
  List<Object?> get props => [
        tableType,
        mode,
        gridSize,
        ringCount,
        totalCells,
        level,
        targetTimeSeconds,
        colorCells,
        colorblindPalette,
        distractorRotations,
        autoRotation,
        rotationSpeed,
      ];
}
