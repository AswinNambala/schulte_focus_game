import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../game/domain/entities/game_session.dart';
import '../repositories/report_repository.dart';

class GetReportsUseCase {
  final ReportRepository repository;
  GetReportsUseCase(this.repository);

  Future<Either<Failure, List<GameSession>>> call(String userId) {
    return repository.getSessions(userId);
  }
}

class SaveSessionUseCase {
  final ReportRepository repository;
  SaveSessionUseCase(this.repository);

  Future<Either<Failure, Unit>> call(GameSession session) {
    return repository.saveSession(session);
  }
}
