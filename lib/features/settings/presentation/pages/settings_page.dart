import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/app_settings.dart';
import '../bloc/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        centerTitle: false,
      ),
      body: BlocBuilder<SettingsCubit, AppSettings>(
        builder: (context, settings) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // User Profile Header
              _buildUserProfileCard(context),
              const SizedBox(height: 16),

              // Streak Card
              _buildStreakCard(context, settings),
              const SizedBox(height: 20),

              // Appearance Section
              Text(
                'APPEARANCE',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Theme Mode', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            icon: Icon(Icons.brightness_auto),
                            label: Text('System'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode),
                            label: Text('Light'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode),
                            label: Text('Dark'),
                          ),
                        ],
                        selected: {settings.themeMode},
                        onSelectionChanged: (selected) {
                          context.read<SettingsCubit>().setThemeMode(selected.first);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Gameplay Preferences
              Text(
                'GAMEPLAY PREFERENCES',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.volume_up_outlined),
                      title: const Text('Sound Effects'),
                      subtitle: const Text('Audio clicks on cell taps and completion'),
                      value: settings.soundEnabled,
                      onChanged: (val) {
                        context.read<SettingsCubit>().toggleSound(val);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.vibration_outlined),
                      title: const Text('Haptic Feedback'),
                      subtitle: const Text('Vibration pulse on cell taps and errors'),
                      value: settings.hapticsEnabled,
                      onChanged: (val) {
                        context.read<SettingsCubit>().toggleHaptics(val);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.palette_outlined),
                      title: const Text('Color Cells'),
                      subtitle: const Text('Distinct colors for each grid cell'),
                      value: settings.colorCells,
                      onChanged: (val) {
                        context.read<SettingsCubit>().toggleColorCells(val);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.color_lens_outlined),
                      title: const Text('Colorblind Palette'),
                      subtitle: const Text('High-contrast palette for enhanced visibility'),
                      value: settings.colorblindPalette,
                      onChanged: (val) {
                        context.read<SettingsCubit>().toggleColorblind(val);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.rotate_right_outlined),
                      title: const Text('3D Ring Auto-Rotation'),
                      subtitle: const Text('Slow rotational movement in 3D circular mode'),
                      value: settings.autoRotation,
                      onChanged: (val) {
                        context.read<SettingsCubit>().toggleAutoRotation(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Legal & About
              Text(
                'ABOUT & LEGAL',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push(AppRoutes.privacyPolicy);
                      },
                    ),
                    const Divider(height: 1),
                    const ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('App Version'),
                      trailing: Text(
                        '1.0.0',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sign Out Button
              OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text(
                  'Log Out',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => _confirmSignOut(context),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserProfileCard(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String displayName = 'Focus Master';
        String email = 'user@schultefocus.app';

        if (authState.status == AuthStatus.authenticated && authState.user != null) {
          displayName = authState.user!.displayName;
          email = authState.user!.email;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primaryContainer,
                theme.colorScheme.secondaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStreakCard(BuildContext context, AppSettings settings) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: Colors.deepOrange.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.deepOrange.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${settings.currentStreak} Day Training Streak',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    settings.currentStreak > 0
                        ? 'Great dedication! Keep your eyes sharp daily.'
                        : 'Play a game today to start your streak!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of Schulte Focus?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(AuthLogOutRequested());
              context.go(AppRoutes.login);
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
