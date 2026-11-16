import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../game/domain/entities/game_session.dart';
import '../../domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final FirebaseFirestore firestore;
  static const String cacheBoxName = 'sessions_cache_box';
  Box? _box;

  ReportRepositoryImpl({required this.firestore});

  Future<Box> _getCacheBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox(cacheBoxName);
    return _box!;
  }

  @override
  Future<Either<Failure, List<GameSession>>> getSessions(String userId) async {
    if (userId.isEmpty) {
      final box = await _getCacheBox();
      final localData = box.values.map((item) {
        return GameSession.fromMap(
          Map<String, dynamic>.from(item as Map),
          item['id'] as String? ?? 'id',
        );
      }).toList();
      return Right(localData);
    }

    try {
      final snapshot = await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.sessionsSubCollection)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      final sessions = snapshot.docs.map((doc) {
        return GameSession.fromMap(doc.data(), doc.id);
      }).toList();

      final box = await _getCacheBox();
      for (final s in sessions) {
        await box.put(s.id, s.toMap());
      }

      return Right(sessions);
    } catch (_) {
      try {
        final box = await _getCacheBox();
        final localData = box.values.map((item) {
          return GameSession.fromMap(
            Map<String, dynamic>.from(item as Map),
            item['id'] as String? ?? 'id',
          );
        }).toList();
        return Right(localData);
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, Unit>> saveSession(GameSession session) async {
    try {
      final box = await _getCacheBox();
      await box.put(session.id, session.toMap());

      if (session.userId.isNotEmpty) {
        await firestore
            .collection(AppConstants.usersCollection)
            .doc(session.userId)
            .collection(AppConstants.sessionsSubCollection)
            .doc(session.id)
            .set(session.toMap());
      }

      return const Right(unit);
    } catch (e) {
      return const Right(unit);
    }
  }
}
