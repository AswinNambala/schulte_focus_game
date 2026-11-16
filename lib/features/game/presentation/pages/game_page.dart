import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
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

    return BlocProvider<GameBloc>(
      create: (_) => GameBloc(userId: userId)..add(GameInitRequested(config)),
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return GameResultDialog(
          session: session,
          stars: state.stars,
          onPlayAgain: () {
            Navigator.of(dialogContext).pop();
            context.read<GameBloc>().add(GameRestartRequested());
            context.read<GameBloc>().add(GameStartRequested());
          },
          onContinue: () {
            Navigator.of(dialogContext).pop();
            context.go(AppRoutes.home);
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
        if (state.status == GameStatus.completed) {
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
