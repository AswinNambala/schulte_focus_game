import 'package:equatable/equatable.dart';
import '../../../game/domain/entities/game_session.dart';

abstract class LevelEvent extends Equatable {
  const LevelEvent();

  @override
  List<Object?> get props => [];
}

class LoadLevelsEvent extends LevelEvent {}

class LevelCompletedEvent extends LevelEvent {
  final GameSession session;
  final int targetTimeSeconds;

  const LevelCompletedEvent({
    required this.session,
    required this.targetTimeSeconds,
  });

  @override
  List<Object?> get props => [session, targetTimeSeconds];
}
