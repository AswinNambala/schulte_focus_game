import 'package:equatable/equatable.dart';
import '../../../game/domain/entities/game_session.dart';
import '../../domain/entities/level_info.dart';

enum LevelStatus { initial, loading, loaded, error }

class LevelState extends Equatable {
  final LevelStatus status;
  final List<LevelInfo> levels;
  final int highestUnlocked;
  final LevelOutcome? lastOutcome;
  final GameSession? lastCompletedSession;
  final int lastEarnedStars;

  const LevelState({
    this.status = LevelStatus.initial,
    this.levels = const [],
    this.highestUnlocked = 1,
    this.lastOutcome,
    this.lastCompletedSession,
    this.lastEarnedStars = 0,
  });

  LevelState copyWith({
    LevelStatus? status,
    List<LevelInfo>? levels,
    int? highestUnlocked,
    LevelOutcome? lastOutcome,
    GameSession? lastCompletedSession,
    int? lastEarnedStars,
  }) {
    return LevelState(
      status: status ?? this.status,
      levels: levels ?? this.levels,
      highestUnlocked: highestUnlocked ?? this.highestUnlocked,
      lastOutcome: lastOutcome ?? this.lastOutcome,
      lastCompletedSession: lastCompletedSession ?? this.lastCompletedSession,
      lastEarnedStars: lastEarnedStars ?? this.lastEarnedStars,
    );
  }

  @override
  List<Object?> get props => [
        status,
        levels,
        highestUnlocked,
        lastOutcome,
        lastCompletedSession,
        lastEarnedStars,
      ];
}
