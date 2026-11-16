import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/level_repository.dart';
import '../../domain/services/adaptive_difficulty_service.dart';
import 'level_event.dart';
import 'level_state.dart';

class LevelBloc extends Bloc<LevelEvent, LevelState> {
  final LevelRepository repository;

  LevelBloc({required this.repository}) : super(const LevelState()) {
    on<LoadLevelsEvent>(_onLoadLevels);
    on<LevelCompletedEvent>(_onLevelCompleted);
  }

  Future<void> _onLoadLevels(
    LoadLevelsEvent event,
    Emitter<LevelState> emit,
  ) async {
    emit(state.copyWith(status: LevelStatus.loading));
    try {
      final levels = await repository.getLevels();
      final highest = await repository.getHighestUnlockedLevel();
      emit(
        state.copyWith(
          status: LevelStatus.loaded,
          levels: levels,
          highestUnlocked: highest,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: LevelStatus.error));
    }
  }

  Future<void> _onLevelCompleted(
    LevelCompletedEvent event,
    Emitter<LevelState> emit,
  ) async {
    final session = event.session;
    final outcome = AdaptiveDifficultyService.evaluateOutcome(
      completionTimeMs: session.completionTimeMs,
      errors: session.errors,
      targetTimeSeconds: event.targetTimeSeconds,
      currentLevel: session.level,
    );

    final stars = AdaptiveDifficultyService.calculateStars(
      completionTimeMs: session.completionTimeMs,
      errors: session.errors,
      targetTimeSeconds: event.targetTimeSeconds,
    );

    await repository.updateLevelProgress(
      levelNumber: session.level,
      stars: stars,
      completionTimeMs: session.completionTimeMs,
    );

    final levels = await repository.getLevels();
    final highest = await repository.getHighestUnlockedLevel();

    emit(
      state.copyWith(
        levels: levels,
        highestUnlocked: highest,
        lastOutcome: outcome,
        lastCompletedSession: session,
        lastEarnedStars: stars,
      ),
    );
  }
}
