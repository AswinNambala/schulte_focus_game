import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:schulte_focus/core/errors/failures.dart';
import 'package:schulte_focus/features/game/domain/entities/game_config.dart';
import 'package:schulte_focus/features/game/domain/entities/game_session.dart';
import 'package:schulte_focus/features/reports/domain/usecases/report_usecases.dart';
import 'package:schulte_focus/features/reports/presentation/bloc/report_bloc.dart';
import 'package:schulte_focus/features/reports/presentation/bloc/report_event.dart';
import 'package:schulte_focus/features/reports/presentation/bloc/report_state.dart';

class MockGetReportsUseCase extends Mock implements GetReportsUseCase {}
class MockSaveSessionUseCase extends Mock implements SaveSessionUseCase {}
class FakeGameSession extends Fake implements GameSession {}

void main() {
  late MockGetReportsUseCase mockGetReportsUseCase;
  late MockSaveSessionUseCase mockSaveSessionUseCase;
  late ReportBloc reportBloc;

  setUpAll(() {
    registerFallbackValue(FakeGameSession());
  });

  final testSession = GameSession(
    id: 's1',
    userId: 'u1',
    tableType: TableType.number,
    mode: GameMode.classic,
    level: 1,
    gridSize: 5,
    ringCount: 2,
    totalCells: 25,
    completionTimeMs: 32000,
    errors: 1,
    perTapTimesMs: const [1200, 1100],
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockGetReportsUseCase = MockGetReportsUseCase();
    mockSaveSessionUseCase = MockSaveSessionUseCase();
    reportBloc = ReportBloc(
      getReportsUseCase: mockGetReportsUseCase,
      saveSessionUseCase: mockSaveSessionUseCase,
    );
  });

  tearDown(() {
    reportBloc.close();
  });

  group('ReportBloc Tests', () {
    test('initial state has initial status', () {
      expect(reportBloc.state.status, ReportStatus.initial);
    });

    blocTest<ReportBloc, ReportState>(
      'loads sessions and computes metrics on LoadReportEvent success',
      build: () {
        when(() => mockGetReportsUseCase('u1'))
            .thenAnswer((_) async => Right([testSession]));
        return reportBloc;
      },
      act: (bloc) => bloc.add(const LoadReportEvent('u1')),
      expect: () => [
        const ReportState(status: ReportStatus.loading),
        isA<ReportState>()
            .having((s) => s.status, 'status', ReportStatus.loaded)
            .having((s) => s.allSessions.length, 'allSessions', 1)
            .having((s) => s.metrics.totalSessions, 'totalSessions', 1)
            .having((s) => s.metrics.bestTimeMs, 'bestTime', 32000),
      ],
    );

    blocTest<ReportBloc, ReportState>(
      'emits error state on LoadReportEvent failure',
      build: () {
        when(() => mockGetReportsUseCase('u1'))
            .thenAnswer((_) async => const Left(ServerFailure('Firestore error')));
        return reportBloc;
      },
      act: (bloc) => bloc.add(const LoadReportEvent('u1')),
      expect: () => [
        const ReportState(status: ReportStatus.loading),
        const ReportState(
          status: ReportStatus.error,
          errorMessage: 'Firestore error',
        ),
      ],
    );

    blocTest<ReportBloc, ReportState>(
      'records new session and updates metrics on RecordSessionEvent',
      build: () {
        when(() => mockSaveSessionUseCase(any()))
            .thenAnswer((_) async => const Right(unit));
        return reportBloc;
      },
      act: (bloc) => bloc.add(RecordSessionEvent(testSession)),
      verify: (bloc) {
        expect(bloc.state.allSessions.length, 1);
        expect(bloc.state.metrics.totalSessions, 1);
        verify(() => mockSaveSessionUseCase(any())).called(1);
      },
    );

    blocTest<ReportBloc, ReportState>(
      'changes days filter range to 30 on DaysFilterChangedEvent',
      build: () => reportBloc,
      act: (bloc) => bloc.add(const DaysFilterChangedEvent(30)),
      expect: () => [
        const ReportState(daysRange: 30),
      ],
    );
  });
}
