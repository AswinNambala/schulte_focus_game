import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../game/domain/entities/game_config.dart';
import '../../domain/entities/level_info.dart';
import '../bloc/level_bloc.dart';
import '../bloc/level_event.dart';
import '../bloc/level_state.dart';

class LevelsPage extends StatefulWidget {
  const LevelsPage({super.key});

  @override
  State<LevelsPage> createState() => _LevelsPageState();
}

class _LevelsPageState extends State<LevelsPage> {
  GameMode _selectedMode = GameMode.classic;
  TableType _selectedTableType = TableType.number;

  @override
  void initState() {
    super.initState();
    context.read<LevelBloc>().add(LoadLevelsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Levels (1 - 20)'),
      ),
      body: BlocBuilder<LevelBloc, LevelState>(
        builder: (context, state) {
          if (state.status == LevelStatus.loading && state.levels.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Mode & Type Selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    // Mode Toggle (Classic / 3D Circle)
                    Expanded(
                      child: SegmentedButton<GameMode>(
                        segments: const [
                          ButtonSegment(
                            value: GameMode.classic,
                            label: Text('Classic'),
                            icon: Icon(Icons.grid_on_rounded, size: 16),
                          ),
                          ButtonSegment(
                            value: GameMode.circular3d,
                            label: Text('3D Ring'),
                            icon: Icon(Icons.blur_circular_rounded, size: 16),
                          ),
                        ],
                        selected: {_selectedMode},
                        onSelectionChanged: (set) {
                          setState(() {
                            _selectedMode = set.first;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Table Type Toggle (Number / Letter)
                    SegmentedButton<TableType>(
                      segments: const [
                        ButtonSegment(
                          value: TableType.number,
                          label: Text('123'),
                        ),
                        ButtonSegment(
                          value: TableType.letter,
                          label: Text('ABC'),
                        ),
                      ],
                      selected: {_selectedTableType},
                      onSelectionChanged: (set) {
                        setState(() {
                          _selectedTableType = set.first;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Level Cards Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.88,
                  ),
                  itemCount: state.levels.length,
                  itemBuilder: (context, index) {
                    final level = state.levels[index];
                    return _LevelCard(
                      level: level,
                      isDark: isDark,
                      onTap: () {
                        if (level.isUnlocked) {
                          final config = level.toGameConfig(
                            mode: _selectedMode,
                            tableType: _selectedTableType,
                          );
                          context.push(AppRoutes.game, extra: config);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Level ${level.levelNumber} is locked! Complete Level ${level.levelNumber - 1} to unlock.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final LevelInfo level;
  final bool isDark;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = level.isUnlocked;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: isUnlocked
                ? (isDark ? AppColors.darkSurface : AppColors.lightSurface)
                : (isDark ? Colors.grey[900] : Colors.grey[200]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isUnlocked
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isUnlocked) ...[
                Text(
                  'LVL ${level.levelNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${level.gridSize}x${level.gridSize} • ${level.targetTimeSeconds}s',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 6),
                // Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (starIdx) {
                    final earned = starIdx < level.stars;
                    return Icon(
                      earned ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: earned ? Colors.amber : Colors.grey[400],
                      size: 16,
                    );
                  }),
                ),
              ] else ...[
                Icon(
                  Icons.lock_rounded,
                  color: Colors.grey[500],
                  size: 28,
                ),
                const SizedBox(height: 6),
                Text(
                  'Lvl ${level.levelNumber}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().scale(duration: 200.ms);
  }
}
