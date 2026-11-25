// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:fermata/blocs/settings/settings_cubit.dart';
import 'package:fermata/core/constants/luma_settings.dart';
import 'package:fermata/core/theme/luma_theme.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.cubit});

  final SettingsCubit cubit;

  Future<void> _clearCache(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear cached audio?'),
        content: const Text(
          'Downloaded cache files will be removed. Your library and playlists '
          'will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear cache'),
          ),
        ],
      ),
    );
    if (confirmed == true) await cubit.clearCache();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SettingsState>(
      stream: cubit.stream,
      initialData: cubit.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? cubit.state;
        return Theme(
          data: lumaTheme(
            state.themePreset,
            brightness: Theme.of(context).brightness,
          ),
          child: Scaffold(
            appBar: AppBar(title: const Text('Settings')),
            body: !state.loaded
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      if (state.error != null)
                        Card(
                          child: ListTile(
                            leading: Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            title: const Text('Something went wrong'),
                            subtitle: Text(state.error!),
                          ),
                        ),
                      _SettingsSection(
                        title: 'Appearance',
                        icon: Icons.palette_outlined,
                        children: [
                          DropdownButtonFormField<LumaThemePreset>(
                            initialValue: state.themePreset,
                            decoration: const InputDecoration(
                              labelText: 'Theme preset',
                              prefixIcon: Icon(Icons.color_lens_outlined),
                            ),
                            items: [
                              for (final preset in LumaThemePreset.values)
                                DropdownMenuItem(
                                  value: preset,
                                  child: Text(preset.label),
                                ),
                            ],
                            onChanged: state.loaded
                                ? (value) {
                                    if (value != null) {
                                      unawaited(cubit.setThemePreset(value));
                                    }
                                  }
                                : null,
                          ),
                        ],
                      ),
                      _SettingsSection(
                        title: 'Sound',
                        icon: Icons.graphic_eq,
                        children: [
                          DropdownButtonFormField<LumaEqualizerPreset>(
                            initialValue: state.equalizerPreset,
                            decoration: const InputDecoration(
                              labelText: 'EQ preset',
                              prefixIcon: Icon(Icons.tune),
                            ),
                            items: [
                              for (final preset in LumaEqualizerPreset.values)
                                DropdownMenuItem(
                                  value: preset,
                                  child: Text(preset.label),
                                ),
                            ],
                            onChanged: state.loaded
                                ? (value) {
                                    if (value != null) {
                                      unawaited(
                                        cubit.setEqualizerPreset(value),
                                      );
                                    }
                                  }
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Auto chooses a curve from track metadata. Other '
                            'presets apply instantly to current playback.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      _SettingsSection(
                        title: 'Desktop',
                        icon: Icons.desktop_windows_outlined,
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: state.discordEnabled,
                            onChanged: state.loaded
                                ? (value) =>
                                    unawaited(cubit.setDiscordEnabled(value))
                                : null,
                            title: const Text('Discord presence'),
                            subtitle: Text(
                              state.discordStatus ??
                                  'Show the current track in Discord.',
                            ),
                            secondary: const Icon(Icons.discord),
                          ),
                          const Divider(height: 8),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: state.closeToTray,
                            onChanged: state.loaded
                                ? (value) =>
                                    unawaited(cubit.setCloseToTray(value))
                                : null,
                            title: const Text('Close to tray'),
                            subtitle: const Text(
                              'Keep Luma running when the window is closed.',
                            ),
                            secondary: const Icon(Icons.branding_watermark),
                          ),
                        ],
                      ),
                      _SettingsSection(
                        title: 'Storage',
                        icon: Icons.storage_outlined,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.folder_outlined),
                            title: const Text('Audio cache'),
                            subtitle: Text(_formatBytes(state.cacheBytes)),
                            trailing: FilledButton.tonal(
                              onPressed: state.clearingCache
                                  ? null
                                  : () => unawaited(_clearCache(context)),
                              child: state.clearingCache
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Clear'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Luma',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'Local-first music, softly.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}
