import 'package:equatable/equatable.dart';
import '../../../game/domain/entities/game_session.dart';

class ReportMetrics extends Equatable {
  final int totalSessions;
  final int totalPlayTimeMs;
  final int bestTimeMs;
  final double averageTimeMs;
  final double averageReactionTimeMs;
  final List<GameSession> recentSessions;
  final Map<DateTime, int> dailyPlayTimeMs;

  const ReportMetrics({
    this.totalSessions = 0,
    this.totalPlayTimeMs = 0,
    this.bestTimeMs = 0,
    this.averageTimeMs = 0.0,
    this.averageReactionTimeMs = 0.0,
    this.recentSessions = const [],
    this.dailyPlayTimeMs = const {},
  });

  factory ReportMetrics.fromSessions(List<GameSession> sessions) {
    if (sessions.isEmpty) {
      return const ReportMetrics();
    }

    int totalTime = 0;
    int best = sessions.first.completionTimeMs;
    int totalTaps = 0;
    int totalTapTime = 0;
    final Map<DateTime, int> daily = {};

    for (final s in sessions) {
      totalTime += s.completionTimeMs;
      if (s.completionTimeMs < best && s.completionTimeMs > 0) {
        best = s.completionTimeMs;
      }

      for (final t in s.perTapTimesMs) {
        totalTapTime += t;
        totalTaps++;
      }

      final dateOnly = DateTime(s.createdAt.year, s.createdAt.month, s.createdAt.day);
      daily[dateOnly] = (daily[dateOnly] ?? 0) + s.completionTimeMs;
    }

    final avgTime = totalTime / sessions.length;
    final avgReaction = totalTaps > 0 ? (totalTapTime / totalTaps) : 0.0;

    final sorted = List<GameSession>.from(sessions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ReportMetrics(
      totalSessions: sessions.length,
      totalPlayTimeMs: totalTime,
      bestTimeMs: best,
      averageTimeMs: avgTime,
      averageReactionTimeMs: avgReaction,
      recentSessions: sorted,
      dailyPlayTimeMs: daily,
    );
  }

  @override
  List<Object?> get props => [
        totalSessions,
        totalPlayTimeMs,
        bestTimeMs,
        averageTimeMs,
        averageReactionTimeMs,
        recentSessions,
        dailyPlayTimeMs,
      ];
}
