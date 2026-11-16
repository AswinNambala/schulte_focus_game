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
  static const String pendingBoxName = 'pending_sync_box';

  Box? _cacheBox;
  Box? _pendingBox;

  ReportRepositoryImpl({required this.firestore});

  Future<Box> _getCacheBox() async {
    if (_cacheBox != null && _cacheBox!.isOpen) return _cacheBox!;
    _cacheBox = await Hive.openBox(cacheBoxName);
    return _cacheBox!;
  }

  Future<Box> _getPendingBox() async {
    if (_pendingBox != null && _pendingBox!.isOpen) return _pendingBox!;
    _pendingBox = await Hive.openBox(pendingBoxName);
    return _pendingBox!;
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

      // Auto-sync any pending sessions now that connection succeeded
      syncPendingSessions(userId);

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
      // 1. Always cache locally in Hive
      final cacheBox = await _getCacheBox();
      await cacheBox.put(session.id, session.toMap());

      // 2. If user is authenticated, attempt upload to Firestore
      if (session.userId.isNotEmpty) {
        try {
          await firestore
              .collection(AppConstants.usersCollection)
              .doc(session.userId)
              .collection(AppConstants.sessionsSubCollection)
              .doc(session.id)
              .set(session.toMap());

          // If was in pending queue, remove it
          final pendingBox = await _getPendingBox();
          if (pendingBox.containsKey(session.id)) {
            await pendingBox.delete(session.id);
          }
        } catch (_) {
          // Network failure: queue in pending sync box
          final pendingBox = await _getPendingBox();
          await pendingBox.put(session.id, session.userId);
        }
      }

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> syncPendingSessions(String userId) async {
    if (userId.isEmpty) return const Right(0);

    try {
      final pendingBox = await _getPendingBox();
      final cacheBox = await _getCacheBox();
      final pendingKeys = List<dynamic>.from(pendingBox.keys);
      int syncedCount = 0;

      for (final key in pendingKeys) {
        final targetUserId = pendingBox.get(key) as String?;
        if (targetUserId == userId) {
          final cachedData = cacheBox.get(key);
          if (cachedData != null) {
            final sessionMap = Map<String, dynamic>.from(cachedData as Map);
            await firestore
                .collection(AppConstants.usersCollection)
                .doc(userId)
                .collection(AppConstants.sessionsSubCollection)
                .doc(key.toString())
                .set(sessionMap);

            await pendingBox.delete(key);
            syncedCount++;
          }
        }
      }

      return Right(syncedCount);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<int> getPendingSyncCount() async {
    final pendingBox = await _getPendingBox();
    return pendingBox.length;
  }
}
