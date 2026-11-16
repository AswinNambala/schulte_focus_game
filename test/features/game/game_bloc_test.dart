import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schulte_focus/features/game/domain/entities/game_cell.dart';
import 'package:schulte_focus/features/game/domain/entities/game_config.dart';
import 'package:schulte_focus/features/game/presentation/bloc/game_bloc.dart';
import 'package:schulte_focus/features/game/presentation/bloc/game_event.dart';
import 'package:schulte_focus/features/game/presentation/bloc/game_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GameBloc gameBloc;
  const testConfig = GameConfig(
    gridSize: 3,
    totalCells: 9,
    mode: GameMode.classic,
    tableType: TableType.number,
  );

  setUp(() {
    gameBloc = GameBloc(userId: 'user_123');
  });

  tearDown(() {
    gameBloc.close();
  });

  group('GameBloc Tests', () {
    test('initial state is initial status', () {
      expect(gameBloc.state.status, GameStatus.initial);
    });

    blocTest<GameBloc, GameState>(
      'emits ready state with 9 cells on GameInitRequested',
      build: () => gameBloc,
      act: (bloc) => bloc.add(const GameInitRequested(testConfig)),
      verify: (bloc) {
        expect(bloc.state.status, GameStatus.ready);
        expect(bloc.state.cells.length, 9);
        expect(bloc.state.nextTargetValue, 1);
        expect(bloc.state.errors, 0);
      },
    );

    blocTest<GameBloc, GameState>(
      'starts game on GameStartRequested when in ready state',
      build: () => gameBloc,
      seed: () => GameState(
        status: GameStatus.ready,
        config: testConfig,
        cells: List.generate(
          9,
          (i) => GameCell(
            id: 'c_$i',
            value: i + 1,
            displayText: '${i + 1}',
            color: const Color(0xFF000000),
          ),
        ),
      ),
      act: (bloc) => bloc.add(GameStartRequested()),
      verify: (bloc) {
        expect(bloc.state.status, GameStatus.running);
      },
    );

    blocTest<GameBloc, GameState>(
      'increments errors on wrong cell tap',
      build: () => gameBloc,
      seed: () => GameState(
        status: GameStatus.running,
        config: testConfig,
        nextTargetValue: 1,
        errors: 0,
        cells: List.generate(
          9,
          (i) => GameCell(
            id: 'c_$i',
            value: i + 1,
            displayText: '${i + 1}',
            color: const Color(0xFF000000),
          ),
        ),
      ),
      act: (bloc) => bloc.add(
        GameCellTapped(
          bloc.state.cells.firstWhere((c) => c.value == 5),
        ),
      ),
      verify: (bloc) {
        expect(bloc.state.errors, 1);
        expect(bloc.state.hasWrongTapFlash, true);
        expect(bloc.state.nextTargetValue, 1);
      },
    );

    blocTest<GameBloc, GameState>(
      'advances nextTargetValue on correct cell tap',
      build: () => gameBloc,
      seed: () => GameState(
        status: GameStatus.running,
        config: testConfig,
        nextTargetValue: 1,
        errors: 0,
        cells: List.generate(
          9,
          (i) => GameCell(
            id: 'c_$i',
            value: i + 1,
            displayText: '${i + 1}',
            color: const Color(0xFF000000),
          ),
        ),
      ),
      act: (bloc) => bloc.add(
        GameCellTapped(
          bloc.state.cells.firstWhere((c) => c.value == 1),
        ),
      ),
      verify: (bloc) {
        expect(bloc.state.errors, 0);
        expect(bloc.state.nextTargetValue, 2);
        expect(bloc.state.perTapTimesMs.length, 1);
      },
    );

    blocTest<GameBloc, GameState>(
      'pauses and resumes game cleanly',
      build: () => gameBloc,
      seed: () => const GameState(status: GameStatus.running),
      act: (bloc) {
        bloc.add(GamePauseRequested());
        bloc.add(GameResumeRequested());
      },
      expect: () => [
        const GameState(status: GameStatus.paused),
        const GameState(status: GameStatus.running),
      ],
    );

    blocTest<GameBloc, GameState>(
      'ends game with timeUp status when timer exceeds targetTimeSeconds',
      build: () => gameBloc,
      seed: () => const GameState(
        status: GameStatus.running,
        config: GameConfig(targetTimeSeconds: 10),
      ),
      act: (bloc) => bloc.add(const GameTimerTicked(10000)),
      verify: (bloc) {
        expect(bloc.state.status, GameStatus.timeUp);
        expect(bloc.state.stars, 0);
        expect(bloc.state.isFinished, true);
        expect(bloc.state.isCleared, false);
      },
    );
  });
}
