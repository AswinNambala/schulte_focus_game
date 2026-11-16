import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:schulte_focus/core/utils/haptic_feedback_helper.dart';
import 'package:schulte_focus/features/settings/domain/entities/app_settings.dart';
import 'package:schulte_focus/features/settings/domain/repositories/settings_repository.dart';
import 'package:schulte_focus/features/settings/presentation/bloc/settings_cubit.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

class FakeAppSettings extends Fake implements AppSettings {}

void main() {
  late MockSettingsRepository mockRepository;
  late SettingsCubit cubit;

  setUpAll(() {
    registerFallbackValue(FakeAppSettings());
  });

  setUp(() {
    mockRepository = MockSettingsRepository();
    when(() => mockRepository.saveSettings(any())).thenAnswer((_) async {});
    cubit = SettingsCubit(repository: mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('SettingsCubit Tests', () {
    test('initial state has default AppSettings', () {
      expect(cubit.state, const AppSettings());
      expect(cubit.state.themeMode, ThemeMode.dark);
      expect(cubit.state.soundEnabled, true);
      expect(cubit.state.hapticsEnabled, true);
    });

    test('loadSettings updates state from repository', () async {
      const savedSettings = AppSettings(
        themeMode: ThemeMode.dark,
        soundEnabled: false,
        hapticsEnabled: false,
        colorCells: false,
        colorblindPalette: true,
        autoRotation: true,
        currentStreak: 5,
        lastPlayedDateStr: '2026-11-15',
      );
      when(() => mockRepository.getSettings()).thenAnswer((_) async => savedSettings);

      await cubit.loadSettings();

      expect(cubit.state, savedSettings);
      expect(HapticFeedbackHelper.enabled, false);
      verify(() => mockRepository.getSettings()).called(1);
    });

    test('setThemeMode updates theme and persists', () async {
      await cubit.setThemeMode(ThemeMode.dark);

      expect(cubit.state.themeMode, ThemeMode.dark);
      verify(() => mockRepository.saveSettings(any(that: isA<AppSettings>().having(
            (s) => s.themeMode,
            'themeMode',
            ThemeMode.dark,
          )))).called(1);
    });

    test('toggleSound updates soundEnabled and persists', () async {
      await cubit.toggleSound(false);

      expect(cubit.state.soundEnabled, false);
      verify(() => mockRepository.saveSettings(any(that: isA<AppSettings>().having(
            (s) => s.soundEnabled,
            'soundEnabled',
            false,
          )))).called(1);
    });

    test('toggleHaptics updates hapticsEnabled and sets HapticFeedbackHelper', () async {
      await cubit.toggleHaptics(false);

      expect(cubit.state.hapticsEnabled, false);
      expect(HapticFeedbackHelper.enabled, false);
      verify(() => mockRepository.saveSettings(any(that: isA<AppSettings>().having(
            (s) => s.hapticsEnabled,
            'hapticsEnabled',
            false,
          )))).called(1);
    });

    test('toggleColorCells updates colorCells and persists', () async {
      await cubit.toggleColorCells(false);

      expect(cubit.state.colorCells, false);
      verify(() => mockRepository.saveSettings(any(that: isA<AppSettings>().having(
            (s) => s.colorCells,
            'colorCells',
            false,
          )))).called(1);
    });

    test('toggleColorblind updates colorblindPalette and persists', () async {
      await cubit.toggleColorblind(true);

      expect(cubit.state.colorblindPalette, true);
      verify(() => mockRepository.saveSettings(any(that: isA<AppSettings>().having(
            (s) => s.colorblindPalette,
            'colorblindPalette',
            true,
          )))).called(1);
    });

    test('toggleAutoRotation updates autoRotation and persists', () async {
      await cubit.toggleAutoRotation(true);

      expect(cubit.state.autoRotation, true);
      verify(() => mockRepository.saveSettings(any(that: isA<AppSettings>().having(
            (s) => s.autoRotation,
            'autoRotation',
            true,
          )))).called(1);
    });

    group('Streak Calculation', () {
      test('first game played initializes streak to 1', () async {
        final date = DateTime(2026, 11, 16);
        await cubit.recordGamePlayed(customDate: date);

        expect(cubit.state.currentStreak, 1);
        expect(cubit.state.lastPlayedDateStr, '2026-11-16');
      });

      test('second game played on same day maintains current streak', () async {
        final date = DateTime(2026, 11, 16);
        await cubit.recordGamePlayed(customDate: date);
        expect(cubit.state.currentStreak, 1);

        await cubit.recordGamePlayed(customDate: date);
        expect(cubit.state.currentStreak, 1);
      });

      test('game played on consecutive day increments streak', () async {
        final day1 = DateTime(2026, 11, 16);
        await cubit.recordGamePlayed(customDate: day1);
        expect(cubit.state.currentStreak, 1);

        final day2 = DateTime(2026, 11, 17);
        await cubit.recordGamePlayed(customDate: day2);
        expect(cubit.state.currentStreak, 2);
        expect(cubit.state.lastPlayedDateStr, '2026-11-17');
      });

      test('game played after gap resets streak to 1', () async {
        final day1 = DateTime(2026, 11, 16);
        await cubit.recordGamePlayed(customDate: day1);
        expect(cubit.state.currentStreak, 1);

        final day3 = DateTime(2026, 11, 19); // 3 days later
        await cubit.recordGamePlayed(customDate: day3);
        expect(cubit.state.currentStreak, 1);
        expect(cubit.state.lastPlayedDateStr, '2026-11-19');
      });
    });
  });
}
