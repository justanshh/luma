// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:fermata/blocs/player/player_cubit.dart';
import 'package:fermata/blocs/playlists/playlists_cubit.dart';
import 'package:fermata/core/models/media_playlist_model.dart';
import 'package:fermata/screens/playlist_detail_screen.dart';
import 'package:fermata/screens/widgets/artwork_thumbnail.dart';
import 'package:flutter/material.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({
    super.key,
    required this.cubit,
    required this.player,
  });

  final PlaylistsCubit cubit;
  final PlayerCubit player;

  Future<void> _create(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
          decoration: const InputDecoration(
            labelText: 'Playlist name',
            prefixIcon: Icon(Icons.playlist_add),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty || !context.mounted) return;
    final id = await cubit.createPlaylist(name);
    if (!context.mounted || id == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlaylistDetailScreen(
          cubit: cubit,
          player: player,
          playlistId: id,
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, Playlist playlist) async {
    final id = playlist.id;
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "${playlist.title}"?'),
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
    if (confirmed == true) await cubit.deletePlaylist(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists'),
        actions: [
          IconButton(
            tooltip: 'Refresh playlists',
            onPressed: cubit.load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => unawaited(_create(context)),
        icon: const Icon(Icons.add),
        label: const Text('New playlist'),
      ),
      body: StreamBuilder<PlaylistsState>(
        stream: cubit.stream,
        initialData: cubit.state,
        builder: (context, snapshot) {
          final state = snapshot.data ?? cubit.state;
          if (state.loading && state.playlists.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(state.error!, textAlign: TextAlign.center),
              ),
            );
          }
          if (state.playlists.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.playlist_play, size: 40),
                  SizedBox(height: 12),
                  Text('Create a playlist for your favorite mixes.'),
                ],
              ),
            );
          }
          return ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: state.playlists.length,
            onReorder: (oldIndex, newIndex) {
              final ids = state.playlists
                  .map((playlist) => playlist.id)
                  .whereType<int>()
                  .toList();
              final moved = ids.removeAt(oldIndex);
              final target = oldIndex < newIndex ? newIndex - 1 : newIndex;
              ids.insert(target, moved);
              unawaited(cubit.reorderPlaylists(ids));
            },
            itemBuilder: (context, index) {
              final playlist = state.playlists[index];
              return ListTile(
                key: ValueKey('playlist-${playlist.id}'),
                leading: ArtworkThumbnail(
                  artwork: playlist.thumbnail,
                  size: 48,
                ),
                title: Text(playlist.title),
                subtitle: Text(
                  playlist.isPinned ? 'Pinned playlist' : 'Playlist',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: playlist.isPinned ? 'Unpin' : 'Pin',
                      onPressed: playlist.id == null
                          ? null
                          : () => unawaited(
                                cubit.setPinned(
                                    playlist.id!, !playlist.isPinned),
                              ),
                      icon: Icon(
                        playlist.isPinned
                            ? Icons.push_pin
                            : Icons.push_pin_outlined,
                        size: 20,
                      ),
                    ),
                    PopupMenuButton<_PlaylistMenuAction>(
                      tooltip: 'Playlist actions',
                      onSelected: (action) {
                        if (action == _PlaylistMenuAction.delete) {
                          unawaited(_delete(context, playlist));
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: _PlaylistMenuAction.delete,
                          child: ListTile(
                            leading: Icon(Icons.delete_outline),
                            title: Text('Delete playlist'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.drag_handle),
                  ],
                ),
                onTap: playlist.id == null
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PlaylistDetailScreen(
                              cubit: cubit,
                              player: player,
                              playlistId: playlist.id!,
                            ),
                          ),
                        ),
                onLongPress: () => unawaited(_delete(context, playlist)),
              );
            },
          );
        },
      ),
    );
  }
}

enum _PlaylistMenuAction { delete }
