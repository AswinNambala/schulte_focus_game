import 'package:equatable/equatable.dart';
import '../../../game/domain/entities/game_config.dart';
import '../../../game/domain/entities/game_session.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class LoadReportEvent extends ReportEvent {
  final String userId;
  const LoadReportEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class RecordSessionEvent extends ReportEvent {
  final GameSession session;
  const RecordSessionEvent(this.session);

  @override
  List<Object?> get props => [session];
}

class DaysFilterChangedEvent extends ReportEvent {
  final int days; // 7 or 30
  const DaysFilterChangedEvent(this.days);

  @override
  List<Object?> get props => [days];
}

class ChartModeFilterChangedEvent extends ReportEvent {
  final GameMode mode;
  const ChartModeFilterChangedEvent(this.mode);

  @override
  List<Object?> get props => [mode];
}

class ChartTableTypeFilterChangedEvent extends ReportEvent {
  final TableType tableType;
  const ChartTableTypeFilterChangedEvent(this.tableType);

  @override
  List<Object?> get props => [tableType];
}

class SyncPendingSessionsEvent extends ReportEvent {
  final String userId;
  const SyncPendingSessionsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}
