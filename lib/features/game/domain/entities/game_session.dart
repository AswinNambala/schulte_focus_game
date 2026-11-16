import 'package:equatable/equatable.dart';
import 'game_config.dart';

class GameSession extends Equatable {
  final String id;
  final String userId;
  final TableType tableType;
  final GameMode mode;
  final int level;
  final int gridSize;
  final int ringCount;
  final int totalCells;
  final int completionTimeMs;
  final int errors;
  final List<int> perTapTimesMs;
  final DateTime createdAt;

  const GameSession({
    required this.id,
    required this.userId,
    required this.tableType,
    required this.mode,
    required this.level,
    required this.gridSize,
    required this.ringCount,
    required this.totalCells,
    required this.completionTimeMs,
    required this.errors,
    required this.perTapTimesMs,
    required this.createdAt,
  });

  double get averageTapTimeMs {
    if (perTapTimesMs.isEmpty) return 0.0;
    final sum = perTapTimesMs.reduce((a, b) => a + b);
    return sum / perTapTimesMs.length;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'tableType': tableType.name,
      'mode': mode.name,
      'level': level,
      'gridSize': gridSize,
      'ringCount': ringCount,
      'totalCells': totalCells,
      'completionTimeMs': completionTimeMs,
      'errors': errors,
      'perTapTimesMs': perTapTimesMs,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GameSession.fromMap(Map<String, dynamic> map, String id) {
    return GameSession(
      id: id,
      userId: map['userId'] as String? ?? '',
      tableType: map['tableType'] == 'letter' ? TableType.letter : TableType.number,
      mode: map['mode'] == 'circular3d' ? GameMode.circular3d : GameMode.classic,
      level: (map['level'] as num?)?.toInt() ?? 1,
      gridSize: (map['gridSize'] as num?)?.toInt() ?? 5,
      ringCount: (map['ringCount'] as num?)?.toInt() ?? 2,
      totalCells: (map['totalCells'] as num?)?.toInt() ?? 25,
      completionTimeMs: (map['completionTimeMs'] as num?)?.toInt() ?? 0,
      errors: (map['errors'] as num?)?.toInt() ?? 0,
      perTapTimesMs: (map['perTapTimesMs'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        tableType,
        mode,
        level,
        gridSize,
        ringCount,
        totalCells,
        completionTimeMs,
        errors,
        perTapTimesMs,
        createdAt,
      ];
}
