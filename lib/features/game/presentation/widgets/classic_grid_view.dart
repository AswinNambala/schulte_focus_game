import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/game_cell.dart';

class ClassicGridView extends StatelessWidget {
  final int gridSize;
  final List<GameCell> cells;
  final ValueChanged<GameCell> onCellTapped;

  const ClassicGridView({
    super.key,
    required this.gridSize,
    required this.cells,
    required this.onCellTapped,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final gridDimension = availableSize - 16;

        return RepaintBoundary(
          child: Center(
            child: SizedBox(
              width: gridDimension,
              height: gridDimension,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cells.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final cell = cells[index];
                  return _ClassicCellWidget(
                    key: ValueKey(cell.id),
                    cell: cell,
                    onTap: () => onCellTapped(cell),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ClassicCellWidget extends StatelessWidget {
  final GameCell cell;
  final VoidCallback onTap;

  const _ClassicCellWidget({
    super.key,
    required this.cell,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (cell.isCompleted) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
      );
    }

    final textColor = ThemeData.estimateBrightnessForColor(cell.color) == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: cell.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: cell.color.withValues(alpha: 0.35),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Transform.rotate(
              angle: cell.distractorAngle,
              child: Text(
                cell.displayText,
                style: TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().scale(duration: 150.ms, curve: Curves.easeOut);
  }
}
