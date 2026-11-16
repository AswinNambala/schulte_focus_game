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
        title: const Text('Training Levels'),
      ),
      body: BlocBuilder<LevelBloc, LevelState>(
        builder: (context, state) {
          if (state.status == LevelStatus.loading && state.levels.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Clean, Centered Table Type Selector (No overflow)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<TableType>(
                    showSelectedIcon: false,
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    segments: const [
                      ButtonSegment(
                        value: TableType.number,
                        label: Text('Numbers (123)'),
                        icon: Icon(Icons.tag_rounded, size: 16),
                      ),
                      ButtonSegment(
                        value: TableType.letter,
                        label: Text('Letters (ABC)'),
                        icon: Icon(Icons.sort_by_alpha_rounded, size: 16),
                      ),
                    ],
                    selected: {_selectedTableType},
                    onSelectionChanged: (set) {
                      setState(() {
                        _selectedTableType = set.first;
                      });
                    },
                  ),
                ),
              ),

              // Level Cards Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.95,
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
                            mode: GameMode.classic,
                            tableType: _selectedTableType,
                          );
                          context.push(AppRoutes.game, extra: config);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Level ${level.levelNumber} is locked! Complete Level ${level.levelNumber - 1} to unlock.',
                              ),
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
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: isUnlocked
                ? (isDark ? AppColors.darkSurface : AppColors.lightSurface)
                : (isDark ? Colors.grey[900] : Colors.grey[200]),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isUnlocked
                  ? AppColors.primary.withValues(alpha: 0.35)
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isUnlocked) ...[
                  Text(
                    'LVL ${level.levelNumber}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${level.gridSize}x${level.gridSize} • ${level.targetTimeSeconds}s',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[400],
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
                        color: earned ? Colors.amber : Colors.grey[600],
                        size: 16,
                      );
                    }),
                  ),
                ] else ...[
                  Icon(
                    Icons.lock_rounded,
                    color: Colors.grey[600],
                    size: 26,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lvl ${level.levelNumber}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate().scale(duration: 200.ms);
  }
}
