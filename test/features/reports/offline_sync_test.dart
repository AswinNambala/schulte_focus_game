import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:schulte_focus/core/errors/failures.dart';
import 'package:schulte_focus/features/reports/domain/repositories/report_repository.dart';
import 'package:schulte_focus/features/reports/domain/usecases/report_usecases.dart';

class MockReportRepository extends Mock implements ReportRepository {}

void main() {
  late MockReportRepository mockRepository;
  late SyncPendingSessionsUseCase syncUseCase;

  setUp(() {
    mockRepository = MockReportRepository();
    syncUseCase = SyncPendingSessionsUseCase(mockRepository);
  });

  group('SyncPendingSessionsUseCase Tests', () {
    test('returns number of synced sessions on success', () async {
      when(() => mockRepository.syncPendingSessions('user_123'))
          .thenAnswer((_) async => const Right(3));

      final result = await syncUseCase('user_123');

      expect(result, const Right(3));
      verify(() => mockRepository.syncPendingSessions('user_123')).called(1);
    });

    test('returns ServerFailure when sync encounters a server failure', () async {
      when(() => mockRepository.syncPendingSessions('user_123'))
          .thenAnswer((_) async => const Left(ServerFailure('Network disconnected')));

      final result = await syncUseCase('user_123');

      expect(result, const Left(ServerFailure('Network disconnected')));
      verify(() => mockRepository.syncPendingSessions('user_123')).called(1);
    });
  });
}
