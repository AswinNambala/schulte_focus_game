import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/game_cell.dart';

class Circular3DView extends StatefulWidget {
  final List<GameCell> cells;
  final int ringCount;
  final bool autoRotation;
  final double rotationSpeed;
  final ValueChanged<GameCell> onCellTapped;

  const Circular3DView({
    super.key,
    required this.cells,
    required this.ringCount,
    this.autoRotation = false,
    this.rotationSpeed = 0.2,
    required this.onCellTapped,
  });

  @override
  State<Circular3DView> createState() => _Circular3DViewState();
}

class _Circular3DViewState extends State<Circular3DView>
    with SingleTickerProviderStateMixin {
  double _userRotation = 0.0;
  AnimationController? _autoRotationController;

  @override
  void initState() {
    super.initState();
    if (widget.autoRotation) {
      _autoRotationController = AnimationController(
        vsync: this,
        duration: Duration(seconds: (20 / widget.rotationSpeed.clamp(0.1, 2.0)).round()),
      )..repeat();
    }
  }

  @override
  void didUpdateWidget(covariant Circular3DView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoRotation != oldWidget.autoRotation) {
      if (widget.autoRotation) {
        _autoRotationController ??= AnimationController(
          vsync: this,
          duration: Duration(seconds: (20 / widget.rotationSpeed.clamp(0.1, 2.0)).round()),
        );
        _autoRotationController?.repeat();
      } else {
        _autoRotationController?.stop();
      }
    }
  }

  @override
  void dispose() {
    _autoRotationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double size = min(constraints.maxWidth, constraints.maxHeight);
        final double radiusBase = size * 0.44;

        Widget content = GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              // Map horizontal drag delta to angular rotation
              _userRotation += details.delta.dx * 0.01;
            });
          },
          child: RepaintBoundary(
            child: SizedBox(
              width: size,
              height: size,
              child: AnimatedBuilder(
                animation: _autoRotationController ?? const AlwaysStoppedAnimation(0.0),
                builder: (context, _) {
                  final double autoAngle = (_autoRotationController?.value ?? 0.0) * 2 * pi;
                  final double totalRotation = _userRotation + autoAngle;

                  // 3D Perspective Matrix (Tilts the disc along X axis for perspective depth)
                  final perspectiveTransform = Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // Perspective focal length
                    ..rotateX(0.40); // 3D tilt angle (~23 degrees)

                  return Transform(
                    transform: perspectiveTransform,
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Subtle concentric ring guides
                        ...List.generate(widget.ringCount, (r) {
                          final ringRadius = _computeRingRadius(r, widget.ringCount, radiusBase);
                          return Container(
                            width: ringRadius * 2,
                            height: ringRadius * 2,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.15),
                                width: 1.5,
                              ),
                            ),
                          );
                        }),

                        // Concentric ring cells with polar distribution
                        ...widget.cells.map((cell) {
                          if (cell.isCompleted) {
                            return const SizedBox.shrink();
                          }

                          final ringRadius = _computeRingRadius(
                            cell.ringIndex,
                            widget.ringCount,
                            radiusBase,
                          );

                          final angle = cell.polarAngle + totalRotation;
                          final double x = ringRadius * cos(angle);
                          final double y = ringRadius * sin(angle);

                          // Depth scaling and shading based on y coordinate (perspective depth)
                          final double depthFactor = (sin(angle) + 1.0) / 2.0; // 0 (far) to 1 (near)
                          final double cellScale = 0.85 + (0.25 * depthFactor);
                          final double opacity = 0.70 + (0.30 * depthFactor);

                          return Transform.translate(
                            offset: Offset(x, y),
                            child: Transform.scale(
                              scale: cellScale,
                              child: Opacity(
                                opacity: opacity,
                                child: _CircularCellItem(
                                  cell: cell,
                                  onTap: () => widget.onCellTapped(cell),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );

        return Center(child: content);
      },
    );
  }

  double _computeRingRadius(int ringIndex, int totalRings, double maxRadius) {
    if (totalRings == 1) {
      return maxRadius * 0.75;
    } else if (totalRings == 2) {
      return ringIndex == 0 ? maxRadius * 0.50 : maxRadius * 0.88;
    } else {
      if (ringIndex == 0) return maxRadius * 0.38;
      if (ringIndex == 1) return maxRadius * 0.65;
      return maxRadius * 0.92;
    }
  }
}

class _CircularCellItem extends StatelessWidget {
  final GameCell cell;
  final VoidCallback onTap;

  const _CircularCellItem({
    required this.cell,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = ThemeData.estimateBrightnessForColor(cell.color) == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: cell.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: cell.color.withValues(alpha: 0.4),
              blurRadius: 8,
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack);
  }
}
