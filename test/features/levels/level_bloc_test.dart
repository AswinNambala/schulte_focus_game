import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:schulte_focus/features/game/domain/entities/game_config.dart';
import 'package:schulte_focus/features/game/domain/entities/game_session.dart';
import 'package:schulte_focus/features/levels/domain/entities/level_info.dart';
import 'package:schulte_focus/features/levels/domain/repositories/level_repository.dart';
import 'package:schulte_focus/features/levels/presentation/bloc/level_bloc.dart';
import 'package:schulte_focus/features/levels/presentation/bloc/level_event.dart';
import 'package:schulte_focus/features/levels/presentation/bloc/level_state.dart';

class MockLevelRepository extends Mock implements LevelRepository {}

void main() {
  late MockLevelRepository mockLevelRepository;
  late LevelBloc levelBloc;

  final sampleLevels = [
    const LevelInfo(
      levelNumber: 1,
      gridSize: 3,
      ringCount: 1,
      targetTimeSeconds: 15,
      isUnlocked: true,
      stars: 3,
    ),
    const LevelInfo(
      levelNumber: 2,
      gridSize: 3,
      ringCount: 1,
      targetTimeSeconds: 18,
      isUnlocked: true,
      stars: 0,
    ),
  ];

  setUp(() {
    mockLevelRepository = MockLevelRepository();
    levelBloc = LevelBloc(repository: mockLevelRepository);
  });

  tearDown(() {
    levelBloc.close();
  });

  group('LevelBloc Tests', () {
    test('initial state has initial status', () {
      expect(levelBloc.state.status, LevelStatus.initial);
    });

    blocTest<LevelBloc, LevelState>(
      'loads levels and highest unlocked level successfully',
      build: () {
        when(() => mockLevelRepository.getLevels())
            .thenAnswer((_) async => sampleLevels);
        when(() => mockLevelRepository.getHighestUnlockedLevel())
            .thenAnswer((_) async => 2);
        return levelBloc;
      },
      act: (bloc) => bloc.add(LoadLevelsEvent()),
      expect: () => [
        const LevelState(status: LevelStatus.loading),
        LevelState(
          status: LevelStatus.loaded,
          levels: sampleLevels,
          highestUnlocked: 2,
        ),
      ],
    );

    blocTest<LevelBloc, LevelState>(
      'updates level progress on LevelCompletedEvent',
      build: () {
        when(() => mockLevelRepository.updateLevelProgress(
              levelNumber: any(named: 'levelNumber'),
              stars: any(named: 'stars'),
              completionTimeMs: any(named: 'completionTimeMs'),
            )).thenAnswer((_) async {});
        when(() => mockLevelRepository.getLevels())
            .thenAnswer((_) async => sampleLevels);
        when(() => mockLevelRepository.getHighestUnlockedLevel())
            .thenAnswer((_) async => 2);
        return levelBloc;
      },
      act: (bloc) => bloc.add(
        LevelCompletedEvent(
          session: GameSession(
            id: 'sess_1',
            userId: 'u1',
            tableType: TableType.number,
            mode: GameMode.classic,
            level: 1,
            gridSize: 3,
            ringCount: 1,
            totalCells: 9,
            completionTimeMs: 10000,
            errors: 0,
            perTapTimesMs: const [1000, 1100],
            createdAt: DateTime.now(),
          ),
          targetTimeSeconds: 15,
        ),
      ),
      verify: (bloc) {
        expect(bloc.state.lastOutcome, LevelOutcome.levelUp);
        expect(bloc.state.lastEarnedStars, 3);
      },
    );
  });
}
