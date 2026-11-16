import 'package:equatable/equatable.dart';
import '../../domain/entities/game_cell.dart';
import '../../domain/entities/game_config.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class GameInitRequested extends GameEvent {
  final GameConfig config;
  const GameInitRequested(this.config);

  @override
  List<Object?> get props => [config];
}

class GameStartRequested extends GameEvent {}

class GameCellTapped extends GameEvent {
  final GameCell cell;
  const GameCellTapped(this.cell);

  @override
  List<Object?> get props => [cell];
}

class GameTimerTicked extends GameEvent {
  final int elapsedMs;
  const GameTimerTicked(this.elapsedMs);

  @override
  List<Object?> get props => [elapsedMs];
}

class GamePauseRequested extends GameEvent {}

class GameResumeRequested extends GameEvent {}

class GameRestartRequested extends GameEvent {}
