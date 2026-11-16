import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/game_cell.dart';
import '../../domain/entities/game_config.dart';
import '../../domain/entities/game_session.dart';

enum GameStatus {
  initial,
  ready,
  running,
  paused,
  completed,
}

class GameState extends Equatable {
  final GameStatus status;
  final GameConfig config;
  final List<GameCell> cells;
  final int nextTargetValue;
  final int errors;
  final int elapsedMs;
  final List<int> perTapTimesMs;
  final int lastTapTimestampMs;
  final bool hasWrongTapFlash;
  final GameSession? completedSession;
  final int stars;

  const GameState({
    this.status = GameStatus.initial,
    this.config = const GameConfig(),
    this.cells = const [],
    this.nextTargetValue = 1,
    this.errors = 0,
    this.elapsedMs = 0,
    this.perTapTimesMs = const [],
    this.lastTapTimestampMs = 0,
    this.hasWrongTapFlash = false,
    this.completedSession,
    this.stars = 0,
  });

  String get nextTargetText {
    final targetCell = cells.firstWhere(
      (c) => c.value == nextTargetValue,
      orElse: () => GameCell(
        id: '',
        value: nextTargetValue,
        displayText: nextTargetValue.toString(),
        color: const Color(0xFF6366F1),
      ),
    );
    return targetCell.displayText;
  }

  GameState copyWith({
    GameStatus? status,
    GameConfig? config,
    List<GameCell>? cells,
    int? nextTargetValue,
    int? errors,
    int? elapsedMs,
    List<int>? perTapTimesMs,
    int? lastTapTimestampMs,
    bool? hasWrongTapFlash,
    GameSession? completedSession,
    int? stars,
  }) {
    return GameState(
      status: status ?? this.status,
      config: config ?? this.config,
      cells: cells ?? this.cells,
      nextTargetValue: nextTargetValue ?? this.nextTargetValue,
      errors: errors ?? this.errors,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      perTapTimesMs: perTapTimesMs ?? this.perTapTimesMs,
      lastTapTimestampMs: lastTapTimestampMs ?? this.lastTapTimestampMs,
      hasWrongTapFlash: hasWrongTapFlash ?? this.hasWrongTapFlash,
      completedSession: completedSession ?? this.completedSession,
      stars: stars ?? this.stars,
    );
  }

  @override
  List<Object?> get props => [
        status,
        config,
        cells,
        nextTargetValue,
        errors,
        elapsedMs,
        perTapTimesMs,
        lastTapTimestampMs,
        hasWrongTapFlash,
        completedSession,
        stars,
      ];
}
