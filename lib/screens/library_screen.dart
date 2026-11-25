// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:fermata/blocs/home/home_cubit.dart';
import 'package:fermata/blocs/player/player_cubit.dart';
import 'package:fermata/blocs/playlists/playlists_cubit.dart';
import 'package:fermata/blocs/search/search_cubit.dart';
import 'package:fermata/blocs/settings/settings_cubit.dart';
import 'package:fermata/core/di/service_locator.dart';
import 'package:fermata/core/models/exported.dart';
import 'package:fermata/core/theme/luma_theme.dart';
import 'package:fermata/screens/home_screen.dart';
import 'package:fermata/screens/playlists_screen.dart';
import 'package:fermata/screens/plugin_manager_screen.dart';
import 'package:fermata/screens/settings_screen.dart';
import 'package:fermata/screens/widgets/add_to_playlist_sheet.dart';
import 'package:fermata/screens/widgets/track_tile.dart';
import 'package:flutter/material.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  SearchCubit? _search;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final search = context.watch<SearchCubit>();
    if (!identical(search, _search)) {
      _search?.removeListener(_onSearchChanged);
      _search = search..addListener(_onSearchChanged);
    }
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _addFolder(BuildContext context) async {
    final cubit = context.watch<PlayerCubit>();
    try {
      final path = await ServiceLocator.nativePicker.pickMusicFolder();
      if (path != null && path.isNotEmpty) {
        await cubit.importFolder(path);
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  Future<void> _addTrackToPlaylist(BuildContext context, Track track) async {
    final playlists = context.watch<PlaylistsCubit>();
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

  void _openPlaylists() {
    final playlists = context.watch<PlaylistsCubit>();
    final player = context.watch<PlayerCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlaylistsScreen(cubit: playlists, player: player),
      ),
    );
  }

  void _openSettings() {
    final settings = context.watch<SettingsCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(cubit: settings),
      ),
    );
  }

  @override
  void dispose() {
    _search?.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerCubit>();
    final home = context.watch<HomeCubit>();
    final playlists = context.watch<PlaylistsCubit>();
    final settingsCubit = context.watch<SettingsCubit>();
    final search = context.watch<SearchCubit>();
    final searchState = search.state;
    return StreamBuilder<SettingsState>(
      stream: settingsCubit.stream,
      initialData: settingsCubit.state,
      builder: (context, settingsSnapshot) {
        final settings = settingsSnapshot.data ?? settingsCubit.state;
        return Theme(
          data: lumaTheme(
            settings.themePreset,
            brightness: Theme.of(context).brightness,
          ),
          child: Scaffold(
            appBar: AppBar(
              title: TextField(
                key: const Key('library-search-field'),
                controller: _searchController,
                onChanged: search.queryChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search local and online music',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchState.query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            search.clear();
                          },
                          icon: const Icon(Icons.clear),
                        ),
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'Add folder',
                  onPressed: () => unawaited(_addFolder(context)),
                  icon: const Icon(Icons.folder_open),
                ),
                IconButton(
                  tooltip: 'Playlists',
                  onPressed: _openPlaylists,
                  icon: const Icon(Icons.playlist_play),
                ),
                IconButton(
                  tooltip: 'Settings',
                  onPressed: _openSettings,
                  icon: const Icon(Icons.settings_outlined),
                ),
                IconButton(
                  tooltip: 'Plugins',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const PluginManagerScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.extension),
                ),
              ],
            ),
            body: searchState.isActive
                ? _buildSearchResults(context, player, searchState)
                : HomeScreen(
                    home: home,
                    playlists: playlists,
                    player: player,
                    onOpenPlaylists: _openPlaylists,
                    onOpenSettings: _openSettings,
                  ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    PlayerCubit player,
    SearchState searchState,
  ) {
    final tracks = searchState.results;
    if (searchState.isSearching && tracks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Searching online…'),
          ],
        ),
      );
    }
    if (searchState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Search failed: ${searchState.error}',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (tracks.isEmpty) {
      return Center(
        child: Text('No results for "${searchState.query.trim()}"'),
      );
    }
    return ListView.builder(
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final Track track = tracks[index];
        return TrackTile(
          track: track,
          onTap: () => unawaited(player.play(track)),
          onPlayNext: () => player.playNext(track),
          onAddToPlaylist: () => unawaited(_addTrackToPlaylist(context, track)),
        );
      },
    );
  }
}
