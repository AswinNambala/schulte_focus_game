import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const String boxName = 'settings_box';
  Box? _box;

  Future<Box> _getBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox(boxName);
    return _box!;
  }

  @override
  Future<AppSettings> getSettings() async {
    final box = await _getBox();
    final themeModeStr = box.get('theme_mode', defaultValue: 'system') as String;
    final soundEnabled = box.get('sound_enabled', defaultValue: true) as bool;
    final hapticsEnabled = box.get('haptics_enabled', defaultValue: true) as bool;
    final colorCells = box.get('color_cells', defaultValue: true) as bool;
    final colorblindPalette = box.get('colorblind_palette', defaultValue: false) as bool;
    final autoRotation = box.get('auto_rotation', defaultValue: false) as bool;
    final currentStreak = (box.get('current_streak', defaultValue: 0) as num).toInt();
    final lastPlayedDate = box.get('last_played_date') as String?;

    ThemeMode themeMode;
    switch (themeModeStr) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }

    return AppSettings(
      themeMode: themeMode,
      soundEnabled: soundEnabled,
      hapticsEnabled: hapticsEnabled,
      colorCells: colorCells,
      colorblindPalette: colorblindPalette,
      autoRotation: autoRotation,
      currentStreak: currentStreak,
      lastPlayedDateStr: lastPlayedDate,
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final box = await _getBox();
    String themeModeStr;
    switch (settings.themeMode) {
      case ThemeMode.light:
        themeModeStr = 'light';
        break;
      case ThemeMode.dark:
        themeModeStr = 'dark';
        break;
      default:
        themeModeStr = 'system';
    }

    await box.put('theme_mode', themeModeStr);
    await box.put('sound_enabled', settings.soundEnabled);
    await box.put('haptics_enabled', settings.hapticsEnabled);
    await box.put('color_cells', settings.colorCells);
    await box.put('colorblind_palette', settings.colorblindPalette);
    await box.put('auto_rotation', settings.autoRotation);
    await box.put('current_streak', settings.currentStreak);
    if (settings.lastPlayedDateStr != null) {
      await box.put('last_played_date', settings.lastPlayedDateStr);
    }
  }
}
