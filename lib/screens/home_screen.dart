// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:fermata/blocs/home/home_cubit.dart';
import 'package:fermata/blocs/player/player_cubit.dart';
import 'package:fermata/blocs/playlists/playlists_cubit.dart';
import 'package:fermata/core/models/exported.dart';
import 'package:fermata/core/models/playback_history_entry.dart';
import 'package:fermata/screens/widgets/add_to_playlist_sheet.dart';
import 'package:fermata/screens/widgets/track_tile.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.home,
    required this.playlists,
    required this.player,
    this.onOpenPlaylists,
    this.onOpenSettings,
  });

  final HomeCubit home;
  final PlaylistsCubit playlists;
  final PlayerCubit player;
  final VoidCallback? onOpenPlaylists;
  final VoidCallback? onOpenSettings;

  Future<void> _addToPlaylist(BuildContext context, Track track) async {
    final playlistId = await showAddToPlaylistSheet(
      context,
      playlists: playlists,
      track: track,
    );
    if (playlistId == null || !context.mounted) return;
    await playlists.addTrack(playlistId, track);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to playlist')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home_outlined), text: 'Home'),
              Tab(icon: Icon(Icons.history), text: 'Recents'),
              Tab(icon: Icon(Icons.auto_awesome_outlined), text: 'Suggestions'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _HomeTab(
                  cubit: home,
                  player: player,
                  onAddToPlaylist: (track) => _addToPlaylist(context, track),
                  onOpenPlaylists: onOpenPlaylists,
                  onOpenSettings: onOpenSettings,
                ),
                _RecentsTab(
                  cubit: home,
                  player: player,
                  onAddToPlaylist: (track) => _addToPlaylist(context, track),
                ),
                _SuggestionsTab(
                  cubit: home,
                  player: player,
                  onAddToPlaylist: (track) => _addToPlaylist(context, track),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.cubit,
    required this.player,
    required this.onAddToPlaylist,
    this.onOpenPlaylists,
    this.onOpenSettings,
  });

  final HomeCubit cubit;
  final PlayerCubit player;
  final Future<void> Function(Track track) onAddToPlaylist;
  final VoidCallback? onOpenPlaylists;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<HomeState>(
      stream: cubit.stream,
      initialData: cubit.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? cubit.state;
        final recentTracks = state.recents.take(6).toList();
        final suggestions = state.suggestions.take(8).toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Welcome to Luma',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'A soft little home for your music.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (onOpenPlaylists != null)
                  ActionChip(
                    avatar: const Icon(Icons.playlist_play, size: 18),
                    label: const Text('Playlists'),
                    onPressed: onOpenPlaylists,
                  ),
                if (onOpenSettings != null)
                  ActionChip(
                    avatar: const Icon(Icons.settings_outlined, size: 18),
                    label: const Text('Settings'),
                    onPressed: onOpenSettings,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _SectionHeader(
              title: 'Recently played',
              icon: Icons.history,
              empty: recentTracks.isEmpty,
            ),
            if (recentTracks.isEmpty)
              const _EmptyHint(
                icon: Icons.history,
                text: 'Tracks you play will appear here.',
              )
            else
              ...recentTracks.map(
                (entry) => TrackTile(
                  track: entry.track,
                  subtitleOverride: _historyTime(entry.playedAt),
                  onTap: () => unawaited(player.play(entry.track)),
                  onPlayNext: () => player.playNext(entry.track),
                  onAddToPlaylist: () =>
                      unawaited(onAddToPlaylist(entry.track)),
                ),
              ),
            const SizedBox(height: 20),
            _SectionHeader(
              title: 'Suggested for you',
              icon: Icons.auto_awesome_outlined,
              empty: suggestions.isEmpty,
              loading: state.loadingSuggestions,
            ),
            if (state.loadingSuggestions && suggestions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: LinearProgressIndicator(),
              )
            else if (suggestions.isEmpty)
              _EmptyHint(
                icon: Icons.auto_awesome_outlined,
                text:
                    state.error ?? 'Play an online track to start your radio.',
              )
            else
              ...suggestions.map(
                (track) => TrackTile(
                  track: track,
                  onTap: () => unawaited(player.play(track)),
                  onPlayNext: () => player.playNext(track),
                  onAddToPlaylist: () => unawaited(onAddToPlaylist(track)),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _RecentsTab extends StatelessWidget {
  const _RecentsTab({
    required this.cubit,
    required this.player,
    required this.onAddToPlaylist,
  });

  final HomeCubit cubit;
  final PlayerCubit player;
  final Future<void> Function(Track track) onAddToPlaylist;

  Future<void> _clear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear listening history?'),
        content: const Text('This removes recent plays, not your music.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) await cubit.clearRecents();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<HomeState>(
      stream: cubit.stream,
      initialData: cubit.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? cubit.state;
        return Column(
          children: [
            ListTile(
              title: const Text('Listening history'),
              subtitle: Text('${state.recents.length} recent tracks'),
              trailing: IconButton(
                tooltip: 'Clear history',
                onPressed: state.recents.isEmpty ? null : () => _clear(context),
                icon: const Icon(Icons.delete_outline),
              ),
            ),
            Expanded(
              child: state.loading
                  ? const Center(child: CircularProgressIndicator())
                  : state.recents.isEmpty
                      ? const _EmptyHint(
                          icon: Icons.history,
                          text: 'Your listening history will appear here.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: state.recents.length,
                          itemBuilder: (context, index) {
                            final PlaybackHistoryEntry entry =
                                state.recents[index];
                            return TrackTile(
                              track: entry.track,
                              subtitleOverride: _historyTime(entry.playedAt),
                              onTap: () => unawaited(player.play(entry.track)),
                              onPlayNext: () => player.playNext(entry.track),
                              onAddToPlaylist: () =>
                                  unawaited(onAddToPlaylist(entry.track)),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
}

class _SuggestionsTab extends StatelessWidget {
  const _SuggestionsTab({
    required this.cubit,
    required this.player,
    required this.onAddToPlaylist,
  });

  final HomeCubit cubit;
  final PlayerCubit player;
  final Future<void> Function(Track track) onAddToPlaylist;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<HomeState>(
      stream: cubit.stream,
      initialData: cubit.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? cubit.state;
        return Column(
          children: [
            ListTile(
              title: const Text('Your radio'),
              subtitle: const Text('Based on your most recent track'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Refresh suggestions',
                    onPressed: state.loadingSuggestions
                        ? null
                        : () => unawaited(cubit.refreshSuggestions()),
                    icon: const Icon(Icons.refresh),
                  ),
                  IconButton(
                    tooltip: 'Play suggestions',
                    onPressed: state.suggestions.isEmpty
                        ? null
                        : () => unawaited(
                              player.playResults(state.suggestions),
                            ),
                    icon: const Icon(Icons.play_arrow_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.loadingSuggestions
                  ? const Center(child: CircularProgressIndicator())
                  : state.suggestions.isEmpty
                      ? _EmptyHint(
                          icon: Icons.auto_awesome_outlined,
                          text: state.error ??
                              'Play an online track to discover more music.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: state.suggestions.length,
                          itemBuilder: (context, index) {
                            final track = state.suggestions[index];
                            return TrackTile(
                              track: track,
                              onTap: () => unawaited(player.play(track)),
                              onPlayNext: () => player.playNext(track),
                              onAddToPlaylist: () =>
                                  unawaited(onAddToPlaylist(track)),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.empty,
    this.loading = false,
  });

  final String title;
  final IconData icon;
  final bool empty;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        if (loading)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else if (empty)
          Text(
            'Nothing yet',
            style: Theme.of(context).textTheme.labelSmall,
          ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

String _historyTime(DateTime time) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(time.year, time.month, time.day);
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  if (date == today) return 'Today, $hour:$minute';
  if (date == today.subtract(const Duration(days: 1))) {
    return 'Yesterday, $hour:$minute';
  }
  return '${time.day}/${time.month}, $hour:$minute';
}
