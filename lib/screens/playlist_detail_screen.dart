// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:fermata/blocs/player/player_cubit.dart';
import 'package:fermata/blocs/playlists/playlists_cubit.dart';
import 'package:fermata/core/models/exported.dart';
import 'package:fermata/screens/widgets/add_to_playlist_sheet.dart';
import 'package:fermata/screens/widgets/artwork_thumbnail.dart';
import 'package:fermata/screens/widgets/track_tile.dart';
import 'package:flutter/material.dart';

class PlaylistDetailScreen extends StatefulWidget {
  const PlaylistDetailScreen({
    super.key,
    required this.cubit,
    required this.player,
    required this.playlistId,
  });

  final PlaylistsCubit cubit;
  final PlayerCubit player;
  final int playlistId;

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(widget.cubit.openPlaylist(widget.playlistId));
  }

  @override
  void dispose() {
    widget.cubit.closePlaylist();
    super.dispose();
  }

  Future<void> _addToPlaylist(BuildContext context, Track track) async {
    final id = await showAddToPlaylistSheet(
      context,
      playlists: widget.cubit,
      track: track,
    );
    if (id == null || id == widget.playlistId || !context.mounted) return;
    await widget.cubit.addTrack(id, track);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to playlist')),
    );
  }

  Future<void> _deletePlaylist(BuildContext context, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "$title"?'),
        content: const Text('The playlist will be removed. Your tracks stay.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (confirmed == true) {
      await widget.cubit.deletePlaylist(widget.playlistId);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlaylistsState>(
      stream: widget.cubit.stream,
      initialData: widget.cubit.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? widget.cubit.state;
        final playlist = state.selected;
        final tracks = playlist?.tracks ?? const <Track>[];
        return Scaffold(
          appBar: AppBar(
            title: Text(playlist?.title ?? 'Playlist'),
            actions: [
              IconButton(
                tooltip: 'Add current queue',
                onPressed: widget.player.state.tracks.isEmpty
                    ? null
                    : () => unawaited(
                          widget.cubit.addTracks(
                            widget.playlistId,
                            widget.player.state.tracks,
                          ),
                        ),
                icon: const Icon(Icons.playlist_add),
              ),
              IconButton(
                tooltip: 'Delete playlist',
                onPressed: playlist == null
                    ? null
                    : () => unawaited(
                          _deletePlaylist(context, playlist.title),
                        ),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          floatingActionButton: tracks.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => unawaited(widget.player.playResults(tracks)),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Play all'),
                ),
          body: state.loading && playlist == null
              ? const Center(child: CircularProgressIndicator())
              : tracks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ArtworkThumbnail(
                            artwork: playlist?.thumbnail,
                            size: 72,
                            borderRadius: 18,
                          ),
                          const SizedBox(height: 12),
                          const Text('This playlist is empty.'),
                          const SizedBox(height: 4),
                          const Text(
                            'Use a track’s menu to add it here.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.only(bottom: 96),
                      itemCount: tracks.length,
                      onReorder: (oldIndex, newIndex) {
                        final target =
                            oldIndex < newIndex ? newIndex - 1 : newIndex;
                        unawaited(
                          widget.cubit.reorderTrack(
                            widget.playlistId,
                            oldIndex,
                            target,
                          ),
                        );
                      },
                      itemBuilder: (context, index) {
                        final track = tracks[index];
                        return TrackTile(
                          key: ValueKey(
                            'playlist-${widget.playlistId}-${track.id}',
                          ),
                          track: track,
                          selected: widget.player.state.current?.id == track.id,
                          onTap: () => unawaited(widget.player.play(track)),
                          onPlayNext: () => widget.player.playNext(track),
                          onAddToPlaylist: () => unawaited(
                            _addToPlaylist(context, track),
                          ),
                          onRemove: () => unawaited(
                            widget.cubit.removeTrack(
                              widget.playlistId,
                              track.id,
                            ),
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }
}
