import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../game/domain/entities/game_config.dart';
import '../../../game/domain/entities/game_session.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthBloc>().state.user?.uid ?? '';
    context.read<ReportBloc>().add(LoadReportEvent(uid));
  }

  String _formatMs(int ms) {
    if (ms <= 0) return '0.0s';
    final totalSeconds = ms / 1000.0;
    if (totalSeconds < 60) {
      return '${totalSeconds.toStringAsFixed(1)}s';
    }
    final mins = (ms ~/ 60000);
    final secs = (ms % 60000) ~/ 1000;
    return '${mins}m ${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance & Analytics'),
      ),
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state.status == ReportStatus.loading && state.allSessions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final m = state.metrics;

          return RefreshIndicator(
            onRefresh: () async {
              final uid = context.read<AuthBloc>().state.user?.uid ?? '';
              context.read<ReportBloc>().add(LoadReportEvent(uid));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI Grid
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          title: 'Best Time',
                          value: _formatMs(m.bestTimeMs),
                          icon: Icons.emoji_events_rounded,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          title: 'Avg Time',
                          value: _formatMs(m.averageTimeMs.round()),
                          icon: Icons.timer_rounded,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          title: 'Total Sessions',
                          value: m.totalSessions.toString(),
                          icon: Icons.fitness_center_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          title: 'Play Time',
                          value: _formatMs(m.totalPlayTimeMs),
                          icon: Icons.access_time_filled_rounded,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MetricCard(
                    title: 'Avg Reaction Speed Per Tap',
                    value: '${(m.averageReactionTimeMs / 1000).toStringAsFixed(2)}s / tap',
                    icon: Icons.touch_app_rounded,
                    color: Colors.deepPurpleAccent,
                  ),
                  const SizedBox(height: 32),

                  // Daily Play Time Bar Chart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Time Spent Per Day',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(value: 7, label: Text('7D')),
                          ButtonSegment(value: 30, label: Text('30D')),
                        ],
                        selected: {state.daysRange},
                        onSelectionChanged: (set) {
                          context
                              .read<ReportBloc>()
                              .add(DaysFilterChangedEvent(set.first));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDailyBarChart(state, isDark),
                  const SizedBox(height: 36),

                  // Progress Line Chart
                  const Text(
                    'Completion Time Progress',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Filter Chips for Mode and Type
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Classic'),
                        selected: state.selectedChartMode == GameMode.classic,
                        onSelected: (_) => context
                            .read<ReportBloc>()
                            .add(const ChartModeFilterChangedEvent(GameMode.classic)),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('3D Ring'),
                        selected: state.selectedChartMode == GameMode.circular3d,
                        onSelected: (_) => context
                            .read<ReportBloc>()
                            .add(const ChartModeFilterChangedEvent(GameMode.circular3d)),
                      ),
                      const Spacer(),
                      ChoiceChip(
                        label: const Text('123'),
                        selected: state.selectedChartTableType == TableType.number,
                        onSelected: (_) => context
                            .read<ReportBloc>()
                            .add(const ChartTableTypeFilterChangedEvent(TableType.number)),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('ABC'),
                        selected: state.selectedChartTableType == TableType.letter,
                        onSelected: (_) => context
                            .read<ReportBloc>()
                            .add(const ChartTableTypeFilterChangedEvent(TableType.letter)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildProgressLineChart(state, isDark),
                  const SizedBox(height: 36),

                  // Recent Sessions List
                  const Text(
                    'Recent Sessions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (m.recentSessions.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No games played yet. Play a session to see stats!',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: min(m.recentSessions.length, 10),
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final session = m.recentSessions[index];
                        return _SessionListItem(session: session, isDark: isDark);
                      },
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailyBarChart(ReportState state, bool isDark) {
    final days = state.daysRange;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<BarChartGroupData> barGroups = [];
    double maxY = 1.0;

    for (int i = days - 1; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final ms = state.metrics.dailyPlayTimeMs[date] ?? 0;
      final minutes = ms / 60000.0;
      if (minutes > maxY) maxY = minutes;

      barGroups.add(
        BarChartGroupData(
          x: days - 1 - i,
          barRods: [
            BarChartRodData(
              toY: minutes,
              color: AppColors.primary,
              width: days == 7 ? 18 : 6,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY * 1.25,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toStringAsFixed(1)} min',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }

  Widget _buildProgressLineChart(ReportState state, bool isDark) {
    final filtered = state.filteredProgressSessions;

    if (filtered.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'No sessions found for this mode & type.',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    final chronological = List<GameSession>.from(filtered)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final spots = <FlSpot>[];
    for (int i = 0; i < chronological.length; i++) {
      final seconds = chronological[i].completionTimeMs / 1000.0;
      spots.add(FlSpot(i.toDouble(), seconds));
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '${spot.y.toStringAsFixed(1)}s',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.grey.withValues(alpha: 0.15),
              strokeWidth: 1,
            ),
          ),
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.secondary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.secondary.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionListItem extends StatelessWidget {
  final GameSession session;
  final bool isDark;

  const _SessionListItem({
    required this.session,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('MMM d, h:mm a').format(session.createdAt);
    final seconds = (session.completionTimeMs / 1000.0).toStringAsFixed(1);
    final modeLabel = session.mode == GameMode.classic
        ? '${session.gridSize}x${session.gridSize} Classic'
        : '3D Ring';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  session.mode == GameMode.classic
                      ? Icons.grid_on_rounded
                      : Icons.blur_circular_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lvl ${session.level} • $modeLabel',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    dateFormatted,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${seconds}s',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '${session.errors} err',
                style: TextStyle(
                  color: session.errors > 0 ? AppColors.error : Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
