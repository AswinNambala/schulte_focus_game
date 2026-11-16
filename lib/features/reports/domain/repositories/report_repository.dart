import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../game/domain/entities/game_session.dart';

abstract class ReportRepository {
  Future<Either<Failure, List<GameSession>>> getSessions(String userId);
  Future<Either<Failure, Unit>> saveSession(GameSession session);
  Future<Either<Failure, int>> syncPendingSessions(String userId);
  Future<int> getPendingSyncCount();
}
