import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/haptic_feedback_helper.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsCubit extends Cubit<AppSettings> {
  final SettingsRepository repository;

  SettingsCubit({required this.repository}) : super(const AppSettings());

  Future<void> loadSettings() async {
    final settings = await repository.getSettings();
    HapticFeedbackHelper.enabled = settings.hapticsEnabled;
    emit(settings);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final updated = state.copyWith(themeMode: mode);
    await repository.saveSettings(updated);
    emit(updated);
  }

  Future<void> toggleSound(bool enabled) async {
    final updated = state.copyWith(soundEnabled: enabled);
    await repository.saveSettings(updated);
    emit(updated);
  }

  Future<void> toggleHaptics(bool enabled) async {
    HapticFeedbackHelper.enabled = enabled;
    final updated = state.copyWith(hapticsEnabled: enabled);
    await repository.saveSettings(updated);
    emit(updated);
  }

  Future<void> toggleColorCells(bool enabled) async {
    final updated = state.copyWith(colorCells: enabled);
    await repository.saveSettings(updated);
    emit(updated);
  }

  Future<void> toggleColorblind(bool enabled) async {
    final updated = state.copyWith(colorblindPalette: enabled);
    await repository.saveSettings(updated);
    emit(updated);
  }

  Future<void> toggleAutoRotation(bool enabled) async {
    final updated = state.copyWith(autoRotation: enabled);
    await repository.saveSettings(updated);
    emit(updated);
  }

  Future<void> recordGamePlayed({DateTime? customDate}) async {
    final updated = AppSettings.updateStreak(state, customDate: customDate);
    await repository.saveSettings(updated);
    emit(updated);
  }
}
