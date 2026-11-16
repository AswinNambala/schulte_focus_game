import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/report_metrics.dart';
import '../../domain/usecases/report_usecases.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final GetReportsUseCase getReportsUseCase;
  final SaveSessionUseCase saveSessionUseCase;
  final SyncPendingSessionsUseCase? syncPendingSessionsUseCase;

  ReportBloc({
    required this.getReportsUseCase,
    required this.saveSessionUseCase,
    this.syncPendingSessionsUseCase,
  }) : super(const ReportState()) {
    on<LoadReportEvent>(_onLoadReport);
    on<RecordSessionEvent>(_onRecordSession);
    on<DaysFilterChangedEvent>(_onDaysFilterChanged);
    on<ChartModeFilterChangedEvent>(_onChartModeFilterChanged);
    on<ChartTableTypeFilterChangedEvent>(_onChartTableTypeFilterChanged);
    on<SyncPendingSessionsEvent>(_onSyncPendingSessions);
  }

  Future<void> _onLoadReport(
    LoadReportEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(status: ReportStatus.loading));
    final result = await getReportsUseCase(event.userId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ReportStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (sessions) {
        final metrics = ReportMetrics.fromSessions(sessions);
        emit(
          state.copyWith(
            status: ReportStatus.loaded,
            allSessions: sessions,
            metrics: metrics,
          ),
        );
      },
    );
  }

  Future<void> _onRecordSession(
    RecordSessionEvent event,
    Emitter<ReportState> emit,
  ) async {
    await saveSessionUseCase(event.session);
    final updated = List.of(state.allSessions)..insert(0, event.session);
    final metrics = ReportMetrics.fromSessions(updated);
    emit(state.copyWith(allSessions: updated, metrics: metrics));
  }

  void _onDaysFilterChanged(
    DaysFilterChangedEvent event,
    Emitter<ReportState> emit,
  ) {
    emit(state.copyWith(daysRange: event.days));
  }

  void _onChartModeFilterChanged(
    ChartModeFilterChangedEvent event,
    Emitter<ReportState> emit,
  ) {
    emit(state.copyWith(selectedChartMode: event.mode));
  }

  void _onChartTableTypeFilterChanged(
    ChartTableTypeFilterChangedEvent event,
    Emitter<ReportState> emit,
  ) {
    emit(state.copyWith(selectedChartTableType: event.tableType));
  }

  Future<void> _onSyncPendingSessions(
    SyncPendingSessionsEvent event,
    Emitter<ReportState> emit,
  ) async {
    if (syncPendingSessionsUseCase != null) {
      await syncPendingSessionsUseCase!(event.userId);
      add(LoadReportEvent(event.userId));
    }
  }
}
