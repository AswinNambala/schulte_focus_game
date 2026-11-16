import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class GameCell extends Equatable {
  final String id;
  final int value; // 1-based sequential value
  final String displayText; // e.g. "1", "2" or "A", "B"
  final Color color;
  final bool isCompleted;
  final double distractorAngle; // Angle in radians for rotated text (higher levels)
  final int ringIndex; // For 3D circular mode (0, 1, 2)
  final double polarAngle; // For 3D circular mode (theta in radians)

  const GameCell({
    required this.id,
    required this.value,
    required this.displayText,
    required this.color,
    this.isCompleted = false,
    this.distractorAngle = 0.0,
    this.ringIndex = 0,
    this.polarAngle = 0.0,
  });

  GameCell copyWith({
    String? id,
    int? value,
    String? displayText,
    Color? color,
    bool? isCompleted,
    double? distractorAngle,
    int? ringIndex,
    double? polarAngle,
  }) {
    return GameCell(
      id: id ?? this.id,
      value: value ?? this.value,
      displayText: displayText ?? this.displayText,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
      distractorAngle: distractorAngle ?? this.distractorAngle,
      ringIndex: ringIndex ?? this.ringIndex,
      polarAngle: polarAngle ?? this.polarAngle,
    );
  }

  @override
  List<Object?> get props => [
        id,
        value,
        displayText,
        color,
        isCompleted,
        distractorAngle,
        ringIndex,
        polarAngle,
      ];
}
