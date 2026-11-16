import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppSettings extends Equatable {
  final ThemeMode themeMode;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool colorCells;
  final bool colorblindPalette;
  final bool autoRotation;
  final int currentStreak;
  final String? lastPlayedDateStr;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.colorCells = true,
    this.colorblindPalette = false,
    this.autoRotation = false,
    this.currentStreak = 0,
    this.lastPlayedDateStr,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? colorCells,
    bool? colorblindPalette,
    bool? autoRotation,
    int? currentStreak,
    String? lastPlayedDateStr,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      colorCells: colorCells ?? this.colorCells,
      colorblindPalette: colorblindPalette ?? this.colorblindPalette,
      autoRotation: autoRotation ?? this.autoRotation,
      currentStreak: currentStreak ?? this.currentStreak,
      lastPlayedDateStr: lastPlayedDateStr ?? this.lastPlayedDateStr,
    );
  }

  static AppSettings updateStreak(AppSettings current, {DateTime? customDate}) {
    final now = customDate ?? DateTime.now();
    final todayStr =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    if (current.lastPlayedDateStr == todayStr) {
      return current;
    }

    if (current.lastPlayedDateStr != null) {
      final lastDate = DateTime.tryParse(current.lastPlayedDateStr!);
      if (lastDate != null) {
        final lastDayNormalized = DateTime(lastDate.year, lastDate.month, lastDate.day);
        final todayNormalized = DateTime(now.year, now.month, now.day);
        final differenceInDays = todayNormalized.difference(lastDayNormalized).inDays;

        if (differenceInDays == 1) {
          return current.copyWith(
            currentStreak: current.currentStreak + 1,
            lastPlayedDateStr: todayStr,
          );
        } else if (differenceInDays > 1) {
          return current.copyWith(
            currentStreak: 1,
            lastPlayedDateStr: todayStr,
          );
        }
      }
    }

    return current.copyWith(
      currentStreak: 1,
      lastPlayedDateStr: todayStr,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        soundEnabled,
        hapticsEnabled,
        colorCells,
        colorblindPalette,
        autoRotation,
        currentStreak,
        lastPlayedDateStr,
      ];
}
