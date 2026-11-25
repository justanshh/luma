import 'dart:async';
import 'dart:io';

import 'package:fermata/blocs/home/home_cubit.dart';
import 'package:fermata/blocs/layout/layout_cubit.dart';
import 'package:fermata/blocs/player/player_cubit.dart';
import 'package:fermata/blocs/playlists/playlists_cubit.dart';
import 'package:fermata/blocs/settings/settings_cubit.dart';
import 'package:fermata/core/di/service_locator.dart';
import 'package:fermata/core/models/exported.dart';
import 'package:fermata/screens/home_screen.dart';
import 'package:fermata/screens/library_screen.dart';
import 'package:fermata/screens/playlists_screen.dart';
import 'package:fermata/screens/plugin_manager_screen.dart';
import 'package:fermata/screens/settings_screen.dart';
import 'package:fermata/screens/widgets/now_playing_bar.dart';
import 'package:fermata/screens/widgets/pane_splitter.dart';
import 'package:fermata/services/desktop/linux_window.dart';
import 'package:fermata/services/desktop/tray_service.dart';
import 'package:flutter/foundation.dart';
// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  static const _closeToTraySetting = 'desktop.close_to_tray';

  DesktopTrayService? _tray;
  bool _handlingClose = false;
  bool _checkingForUpdates = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LinuxWindow().show();
    });
    if (Platform.isLinux) {
      _tray = ServiceLocator.tray;
      _tray?.closeRequestedHandler = _handleCloseRequested;
    }
  }

  @override
  void dispose() {
    _tray?.closeRequestedHandler = null;
    super.dispose();
  }

  Future<void> _handleCloseRequested() async {
    if (_handlingClose) return;
    _handlingClose = true;
    try {
      final closeToTray =
          await ServiceLocator.settingsDao?.getSettingBool(_closeToTraySetting);
      if (!mounted) return;
      if (closeToTray == true) {
        await _tray?.hideWindow();
        return;
      }
      if (closeToTray == false) {
        await _quit();
        return;
      }

      final result = await _showClosePrompt();
      if (!mounted || result == null) return;
      switch (result.choice) {
        case _CloseChoice.cancel:
          return;
        case _CloseChoice.quit:
          await ServiceLocator.settingsDao
              ?.putSettingBool(_closeToTraySetting, false);
          await _quit();
        case _CloseChoice.hide:
          await ServiceLocator.settingsDao
              ?.putSettingBool(_closeToTraySetting, result.remember);
          await _tray?.hideWindow();
      }
    } finally {
      _handlingClose = false;
    }
  }

  Future<_ClosePromptResult?> _showClosePrompt() {
    var remember = false;
    return showDialog<_ClosePromptResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Close to tray?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Keep Luma running in the system tray and continue '
                'playback while the window is closed.',
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: remember,
                onChanged: (value) => setState(() => remember = value ?? false),
                title: const Text('Always close to the tray'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(
                const _ClosePromptResult(_CloseChoice.cancel, false),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(
                const _ClosePromptResult(_CloseChoice.quit, false),
              ),
              child: const Text('Quit'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(
                _ClosePromptResult(_CloseChoice.hide, remember),
              ),
              child: const Text('Hide window'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _quit() async {
    final tray = _tray;
    if (tray != null) {
      await tray.quit();
    } else {
      exit(0);
    }
  }

  Future<void> _checkForUpdates() async {
    if (_checkingForUpdates) return;
    setState(() => _checkingForUpdates = true);
    try {
      final path = await ServiceLocator.updateService.downloadUpdate();
      if (!mounted) return;
      if (path == null) {
        _showMessage('Luma is up to date.');
        return;
      }

      final install = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Update available'),
          content: const Text(
            'Install the downloaded update? You may be asked for your password.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Install'),
            ),
          ],
        ),
      );
      if (install != true || !mounted) return;

      final installed = await ServiceLocator.updateService.installUpdate(path);
      if (!mounted) return;
      if (!installed) {
        _showMessage('Update failed. Please try again.');
        return;
      }

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Update installed'),
          content: const Text('Luma will now close.'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
      if (mounted) await _quit();
    } catch (error) {
      if (mounted) _showMessage('Update failed: $error');
    } finally {
      if (mounted) setState(() => _checkingForUpdates = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final layout = context.watch<LayoutCubit>();
    final player = context.watch<PlayerCubit>();
    final home = context.watch<HomeCubit>();
    final playlists = context.watch<PlaylistsCubit>();
    final settings = context.watch<SettingsCubit>();
    final layoutState = layout.state;
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final available = constraints.maxWidth;
          final sidebarWidth = layoutState.sidebarWidth
              .clamp(160.0, (available - 500).clamp(160.0, 420.0))
              .toDouble();
          final queueWidth = layoutState.queueVisible
              ? layoutState.queueWidth
                  .clamp(200.0,
                      (available - sidebarWidth - 280).clamp(200.0, 520.0))
                  .toDouble()
              : 0.0;
          return Row(
            children: [
              SizedBox(
                width: sidebarWidth,
                child: _Sidebar(
                  layout: layout,
                  home: home,
                  playlists: playlists,
                  player: player,
                  settings: settings,
                  onCheckForUpdates: _checkForUpdates,
                  checkingForUpdates: _checkingForUpdates,
                ),
              ),
              PaneSplitter(
                onDelta: layout.setSidebarWidth,
                onReset: layout.resetSidebar,
              ),
              const Expanded(child: LibraryScreen()),
              if (layoutState.queueVisible) ...[
                PaneSplitter(
                  onDelta: (delta) => layout.setQueueWidth(queueWidth - delta),
                  onReset: layout.resetQueue,
                ),
                SizedBox(
                  width: queueWidth,
                  child: StreamBuilder<PlayerState>(
                    stream: player.stream.distinct(_sameQueueState),
                    initialData: player.state,
                    builder: (context, snapshot) {
                      final state = snapshot.data ?? player.state;
                      return _QueuePanel(
                        tracks: state.tracks,
                        currentIndex: state.currentIndex,
                        onClose: layout.toggleQueue,
                        onReorder: player.move,
                        onRemove: player.removeAt,
                        onClear: player.clearQueue,
                      );
                    },
                  ),
                ),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: const NowPlayingBar(),
    );
  }
}

enum _CloseChoice { cancel, quit, hide }

class _ClosePromptResult {
  const _ClosePromptResult(this.choice, this.remember);

  final _CloseChoice choice;
  final bool remember;
}

bool _sameQueueState(PlayerState previous, PlayerState next) {
  return previous.currentIndex == next.currentIndex &&
      listEquals(previous.tracks, next.tracks);
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.layout,
    required this.home,
    required this.playlists,
    required this.player,
    required this.settings,
    required this.onCheckForUpdates,
    required this.checkingForUpdates,
  });

  final LayoutCubit layout;
  final HomeCubit home;
  final PlaylistsCubit playlists;
  final PlayerCubit player;
  final SettingsCubit settings;
  final VoidCallback onCheckForUpdates;
  final bool checkingForUpdates;

  void _openScreen(BuildContext context, Widget screen) {
    unawaited(Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => screen),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Luma',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () => _openScreen(
              context,
              HomeScreen(
                home: home,
                playlists: playlists,
                player: player,
                onOpenPlaylists: () => _openScreen(
                    context, PlaylistsScreen(cubit: playlists, player: player)),
                onOpenSettings: () =>
                    _openScreen(context, SettingsScreen(cubit: settings)),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.library_music),
            title: const Text('Library'),
            selected: true,
            onTap: () => _openScreen(context, const LibraryScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.playlist_play),
            title: const Text('Playlists'),
            onTap: () => _openScreen(
                context, PlaylistsScreen(cubit: playlists, player: player)),
          ),
          ListTile(
            leading: const Icon(Icons.extension),
            title: const Text('Sources'),
            onTap: () => _openScreen(context, const PluginManagerScreen()),
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () => _openScreen(context, SettingsScreen(cubit: settings)),
          ),
          ListTile(
            leading: checkingForUpdates
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.system_update_alt),
            title: const Text('Check for updates'),
            onTap: checkingForUpdates ? null : onCheckForUpdates,
          ),
          ListTile(
            leading: Icon(
                layout.state.queueVisible ? Icons.queue_music : Icons.queue),
            title: const Text('Queue'),
            onTap: layout.toggleQueue,
          ),
        ],
      ),
    );
  }
}

class _QueuePanel extends StatelessWidget {
  const _QueuePanel({
    required this.tracks,
    required this.currentIndex,
    required this.onClose,
    required this.onReorder,
    required this.onRemove,
    required this.onClear,
  });

  final List<Track> tracks;
  final int currentIndex;
  final VoidCallback onClose;
  final ReorderCallback onReorder;
  final Future<void> Function(int index) onRemove;
  final Future<void> Function() onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Text('Queue', style: Theme.of(context).textTheme.titleMedium),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed:
                          tracks.isEmpty ? null : () => unawaited(onClear()),
                      child: const Text('Clear Queue'),
                    ),
                    IconButton(
                      tooltip: 'Hide queue',
                      onPressed: onClose,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: tracks.isEmpty
                ? const Center(child: Text('Queue is empty'))
                : ReorderableListView.builder(
                    itemCount: tracks.length,
                    onReorderItem: onReorder,
                    itemBuilder: (context, index) {
                      final track = tracks[index];
                      return ListTile(
                        key: ValueKey('queue-${track.id}'),
                        selected: index == currentIndex,
                        title: Text(track.title),
                        subtitle: Text(
                          track.artists.map((artist) => artist.name).join(', '),
                        ),
                        trailing: IconButton(
                          tooltip: 'Remove from queue',
                          onPressed: () => onRemove(index),
                          icon: const Icon(Icons.close),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
