import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/haptic_feedback_helper.dart';
import '../../../levels/domain/services/adaptive_difficulty_service.dart';
import '../../domain/entities/game_cell.dart';
import '../../domain/entities/game_config.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/services/table_generator_service.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  Timer? _timer;
  final String userId;

  GameBloc({this.userId = ''}) : super(const GameState()) {
    on<GameInitRequested>(_onGameInitRequested);
    on<GameStartRequested>(_onGameStartRequested);
    on<GameCellTapped>(_onGameCellTapped);
    on<GameTimerTicked>(_onGameTimerTicked);
    on<GamePauseRequested>(_onGamePauseRequested);
    on<GameResumeRequested>(_onGameResumeRequested);
    on<GameRestartRequested>(_onGameRestartRequested);
  }

  void _onGameInitRequested(
    GameInitRequested event,
    Emitter<GameState> emit,
  ) {
    _timer?.cancel();
    final cells = TableGeneratorService.generateCells(event.config);
    emit(
      GameState(
        status: GameStatus.ready,
        config: event.config,
        cells: cells,
        nextTargetValue: 1,
        errors: 0,
        elapsedMs: 0,
        perTapTimesMs: const [],
        lastTapTimestampMs: 0,
        hasWrongTapFlash: false,
      ),
    );
  }

  void _onGameStartRequested(
    GameStartRequested event,
    Emitter<GameState> emit,
  ) {
    if (state.status != GameStatus.ready) return;
    _startTimer();
    emit(state.copyWith(status: GameStatus.running));
  }

  void _onGameCellTapped(
    GameCellTapped event,
    Emitter<GameState> emit,
  ) {
    if (state.status != GameStatus.running) return;
    final tapped = event.cell;

    if (tapped.value == state.nextTargetValue) {
      HapticFeedbackHelper.lightImpact();

      final currentElapsed = state.elapsedMs;
      final reactionTime = currentElapsed - state.lastTapTimestampMs;
      final updatedReactionTimes = List<int>.from(state.perTapTimesMs)..add(reactionTime);

      final nextTarget = state.nextTargetValue + 1;
      final isFinished = nextTarget > state.config.totalCells;

      if (isFinished) {
        _timer?.cancel();
        final targetSeconds = state.config.targetTimeSeconds;
        final stars = targetSeconds > 0
            ? AdaptiveDifficultyService.calculateStars(
                completionTimeMs: currentElapsed,
                errors: state.errors,
                targetTimeSeconds: targetSeconds,
              )
            : 1;

        final session = GameSession(
          id: 'session_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          tableType: state.config.tableType,
          mode: state.config.mode,
          level: state.config.level,
          gridSize: state.config.gridSize,
          ringCount: state.config.ringCount,
          totalCells: state.config.totalCells,
          completionTimeMs: currentElapsed,
          errors: state.errors,
          perTapTimesMs: updatedReactionTimes,
          createdAt: DateTime.now(),
        );

        emit(
          state.copyWith(
            status: stars > 0 ? GameStatus.completed : GameStatus.timeUp,
            perTapTimesMs: updatedReactionTimes,
            completedSession: session,
            stars: stars,
            hasWrongTapFlash: false,
          ),
        );
      } else {
        List<GameCell> updatedCells;

        if (state.config.mode == GameMode.classic) {
          final markedCells = state.cells.map((c) {
            if (c.id == tapped.id) {
              return c.copyWith(isCompleted: true);
            }
            return c;
          }).toList();
          updatedCells = TableGeneratorService.shuffleRemaining(markedCells);
        } else {
          updatedCells = state.cells.map((c) {
            if (c.id == tapped.id) {
              return c.copyWith(isCompleted: true);
            }
            return c;
          }).toList();
        }

        emit(
          state.copyWith(
            cells: updatedCells,
            nextTargetValue: nextTarget,
            perTapTimesMs: updatedReactionTimes,
            lastTapTimestampMs: currentElapsed,
            hasWrongTapFlash: false,
          ),
        );
      }
    } else {
      HapticFeedbackHelper.errorImpact();
      emit(
        state.copyWith(
          errors: state.errors + 1,
          hasWrongTapFlash: true,
        ),
      );
    }
  }

  void _onGameTimerTicked(
    GameTimerTicked event,
    Emitter<GameState> emit,
  ) {
    if (state.status == GameStatus.running) {
      final targetSeconds = state.config.targetTimeSeconds;
      final targetMs = targetSeconds * 1000;

      // Strict time limit: When time runs out, game ends immediately
      if (targetSeconds > 0 && event.elapsedMs >= targetMs) {
        _timer?.cancel();
        HapticFeedbackHelper.errorImpact();

        final session = GameSession(
          id: 'session_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          tableType: state.config.tableType,
          mode: state.config.mode,
          level: state.config.level,
          gridSize: state.config.gridSize,
          ringCount: state.config.ringCount,
          totalCells: state.config.totalCells,
          completionTimeMs: targetMs,
          errors: state.errors,
          perTapTimesMs: state.perTapTimesMs,
          createdAt: DateTime.now(),
        );

        emit(
          state.copyWith(
            status: GameStatus.timeUp,
            elapsedMs: targetMs,
            completedSession: session,
            stars: 0,
            hasWrongTapFlash: true,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          elapsedMs: event.elapsedMs,
          hasWrongTapFlash: false,
        ),
      );
    }
  }

  void _onGamePauseRequested(
    GamePauseRequested event,
    Emitter<GameState> emit,
  ) {
    if (state.status == GameStatus.running) {
      _timer?.cancel();
      emit(state.copyWith(status: GameStatus.paused));
    }
  }

  void _onGameResumeRequested(
    GameResumeRequested event,
    Emitter<GameState> emit,
  ) {
    if (state.status == GameStatus.paused) {
      _startTimer();
      emit(state.copyWith(status: GameStatus.running));
    }
  }

  void _onGameRestartRequested(
    GameRestartRequested event,
    Emitter<GameState> emit,
  ) {
    _timer?.cancel();
    add(GameInitRequested(state.config));
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      add(GameTimerTicked(state.elapsedMs + 100));
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
