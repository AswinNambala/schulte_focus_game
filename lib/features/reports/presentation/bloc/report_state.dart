import 'package:equatable/equatable.dart';
import '../../../game/domain/entities/game_config.dart';
import '../../../game/domain/entities/game_session.dart';
import '../../domain/entities/report_metrics.dart';

enum ReportStatus { initial, loading, loaded, error }

class ReportState extends Equatable {
  final ReportStatus status;
  final List<GameSession> allSessions;
  final ReportMetrics metrics;
  final int daysRange; // 7 or 30 days for bar chart
  final GameMode selectedChartMode;
  final TableType selectedChartTableType;
  final String? errorMessage;

  const ReportState({
    this.status = ReportStatus.initial,
    this.allSessions = const [],
    this.metrics = const ReportMetrics(),
    this.daysRange = 7,
    this.selectedChartMode = GameMode.classic,
    this.selectedChartTableType = TableType.number,
    this.errorMessage,
  });

  /// Filtered sessions for the progress line chart
  List<GameSession> get filteredProgressSessions {
    return allSessions.where((s) {
      return s.mode == selectedChartMode && s.tableType == selectedChartTableType;
    }).toList();
  }

  ReportState copyWith({
    ReportStatus? status,
    List<GameSession>? allSessions,
    ReportMetrics? metrics,
    int? daysRange,
    GameMode? selectedChartMode,
    TableType? selectedChartTableType,
    String? errorMessage,
  }) {
    return ReportState(
      status: status ?? this.status,
      allSessions: allSessions ?? this.allSessions,
      metrics: metrics ?? this.metrics,
      daysRange: daysRange ?? this.daysRange,
      selectedChartMode: selectedChartMode ?? this.selectedChartMode,
      selectedChartTableType: selectedChartTableType ?? this.selectedChartTableType,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allSessions,
        metrics,
        daysRange,
        selectedChartMode,
        selectedChartTableType,
        errorMessage,
      ];
}
