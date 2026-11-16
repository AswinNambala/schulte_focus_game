import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../levels/domain/services/adaptive_difficulty_service.dart';
import '../../../levels/presentation/bloc/level_bloc.dart';
import '../../../levels/presentation/bloc/level_event.dart';
import '../../../reports/presentation/bloc/report_bloc.dart';
import '../../../reports/presentation/bloc/report_event.dart';
import '../../../settings/presentation/bloc/settings_cubit.dart';
import '../../domain/entities/game_config.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../widgets/classic_grid_view.dart';
import '../widgets/game_hud.dart';
import '../widgets/game_pause_dialog.dart';
import '../widgets/game_result_dialog.dart';

class GamePage extends StatelessWidget {
  final GameConfig config;

  const GamePage({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthBloc>().state.user?.uid ?? '';
    final settings = context.read<SettingsCubit>().state;
    final effectiveConfig = config.copyWith(
      colorCells: settings.colorCells,
      colorblindPalette: settings.colorblindPalette,
      mode: GameMode.classic,
    );

    return BlocProvider<GameBloc>(
      create: (_) => GameBloc(userId: userId)..add(GameInitRequested(effectiveConfig)),
      child: const _GameView(),
    );
  }
}

class _GameView extends StatefulWidget {
  const _GameView();

  @override
  State<_GameView> createState() => _GameViewState();
}

class _GameViewState extends State<_GameView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<GameBloc>().add(GameStartRequested());
      }
    });
  }

  void _showPauseDialog() {
    final bloc = context.read<GameBloc>();
    bloc.add(GamePauseRequested());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return GamePauseDialog(
          onResume: () {
            Navigator.of(dialogContext).pop();
            bloc.add(GameResumeRequested());
          },
          onRestart: () {
            Navigator.of(dialogContext).pop();
            bloc.add(GameRestartRequested());
            bloc.add(GameStartRequested());
          },
          onQuit: () {
            Navigator.of(dialogContext).pop();
            context.go(AppRoutes.home);
          },
        );
      },
    );
  }

  void _showResultDialog(GameState state) {
    final session = state.completedSession;
    if (session == null) return;

    VoidCallback? nextLevelAction;
    if (session.level < 20 && state.stars >= 1) {
      nextLevelAction = () {
        Navigator.of(context).pop();
        final defaultLevels = AdaptiveDifficultyService.getDefaultLevels();
        final nextLevel = defaultLevels.firstWhere(
          (l) => l.levelNumber == session.level + 1,
          orElse: () => defaultLevels.first,
        );
        final nextConfig = nextLevel.toGameConfig(tableType: session.tableType);
        context.pushReplacement(AppRoutes.game, extra: nextConfig);
      };
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return GameResultDialog(
          session: session,
          stars: state.stars,
          onNextLevel: nextLevelAction,
          onPlayAgain: () {
            Navigator.of(dialogContext).pop();
            context.read<GameBloc>().add(GameRestartRequested());
            context.read<GameBloc>().add(GameStartRequested());
          },
          onContinue: () {
            Navigator.of(dialogContext).pop();
            context.go(AppRoutes.levels);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == GameStatus.completed || state.status == GameStatus.timeUp) {
          final session = state.completedSession;
          if (session != null) {
            // 1. Only store progress and update streak if level was cleared (stars >= 1 and level > 0)
            if (state.stars >= 1 && session.level > 0) {
              context.read<LevelBloc>().add(
                    LevelCompletedEvent(
                      session: session,
                      targetTimeSeconds: state.config.targetTimeSeconds,
                    ),
                  );
              context.read<SettingsCubit>().recordGamePlayed();
            }
            // 2. Always record session in ReportBloc for analytics
            context.read<ReportBloc>().add(RecordSessionEvent(session));
          }
          _showResultDialog(state);
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            _showPauseDialog();
          },
          child: Scaffold(
            body: Stack(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      children: [
                        GameHud(
                          nextTarget: state.nextTargetText,
                          elapsedMs: state.elapsedMs,
                          targetTimeSeconds: state.config.targetTimeSeconds,
                          errors: state.errors,
                          onPause: _showPauseDialog,
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: Center(
                            child: ClassicGridView(
                              gridSize: state.config.gridSize,
                              cells: state.cells,
                              onCellTapped: (cell) {
                                context.read<GameBloc>().add(GameCellTapped(cell));
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Wrong Tap Red Flash Overlay
                if (state.hasWrongTapFlash)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: AppColors.error.withValues(alpha: 0.25),
                      )
                          .animate()
                          .fadeIn(duration: 80.ms)
                          .fadeOut(duration: 200.ms),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
