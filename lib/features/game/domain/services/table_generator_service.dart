import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../entities/game_cell.dart';
import '../entities/game_config.dart';

class TableGeneratorService {
  static const List<String> letters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  ];

  static List<GameCell> generateCells(GameConfig config) {
    final int count = config.totalCells;
    final Random random = Random();
    final List<Color> palette = config.colorblindPalette
        ? AppColors.colorblindPalette
        : AppColors.curatedPalette;

    final List<GameCell> cells = [];

    for (int i = 1; i <= count; i++) {
      String text;
      if (config.tableType == TableType.number) {
        text = i.toString();
      } else {
        if (i <= 26) {
          text = letters[i - 1];
        } else {
          final first = letters[(i - 1) ~/ 26 - 1];
          final second = letters[(i - 1) % 26];
          text = '$first$second';
        }
      }

      final Color color = config.colorCells
          ? palette[(i - 1) % palette.length]
          : AppColors.primary;

      double distractor = 0.0;
      if (config.distractorRotations) {
        final angles = [0.0, pi / 2, pi, 3 * pi / 2];
        distractor = angles[random.nextInt(angles.length)];
      }

      cells.add(
        GameCell(
          id: 'cell_$i',
          value: i,
          displayText: text,
          color: color,
          distractorAngle: distractor,
        ),
      );
    }

    cells.shuffle(random);
    return cells;
  }

  /// Shuffles active cells in classic mode after each correct tap
  static List<GameCell> shuffleRemaining(List<GameCell> cells) {
    final random = Random();
    final remaining = cells.where((c) => !c.isCompleted).toList()..shuffle(random);
    int remainingIdx = 0;

    return cells.map((c) {
      if (c.isCompleted) return c;
      return remaining[remainingIdx++];
    }).toList();
  }
}
