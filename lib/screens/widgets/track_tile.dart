// ignore_for_file: deprecated_member_use

import 'package:fermata/blocs/player/player_cubit.dart';
import 'package:fermata/core/models/exported.dart';
import 'package:fermata/screens/widgets/artwork_thumbnail.dart';
import 'package:flutter/material.dart';

class TrackTile extends StatelessWidget {
  const TrackTile({
    super.key,
    required this.track,
    required this.onTap,
    this.onPlayNext,
    this.onAddToPlaylist,
    this.selected = false,
    this.subtitleOverride,
    this.onRemove,
  });

  final Track track;
  final VoidCallback onTap;
  final VoidCallback? onPlayNext;
  final VoidCallback? onAddToPlaylist;
  final VoidCallback? onRemove;
  final bool selected;
  final String? subtitleOverride;

  @override
  Widget build(BuildContext context) {
    final artists = track.artists.map((artist) => artist.name).join(', ');
    final duration = track.durationMs;
    final hasMenu =
        onPlayNext != null || onAddToPlaylist != null || onRemove != null;
    return ListTile(
      selected: selected,
      leading: ArtworkThumbnail(artwork: track.thumbnail, size: 44),
      title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        subtitleOverride ??
            (artists.isEmpty
                ? (track.album?.title ?? 'Unknown artist')
                : artists),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (duration != null)
            Text(
              formatDuration(Duration(milliseconds: duration.toInt())),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          if (hasMenu)
            PopupMenuButton<_TrackMenuAction>(
              tooltip: 'Track actions',
              icon: const Icon(Icons.more_horiz),
              onSelected: (action) {
                switch (action) {
                  case _TrackMenuAction.playNext:
                    onPlayNext?.call();
                  case _TrackMenuAction.addToPlaylist:
                    onAddToPlaylist?.call();
                  case _TrackMenuAction.remove:
                    onRemove?.call();
                }
              },
              itemBuilder: (context) => [
                if (onPlayNext != null)
                  const PopupMenuItem(
                    value: _TrackMenuAction.playNext,
                    child: ListTile(
                      leading: Icon(Icons.playlist_play),
                      title: Text('Play next'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                if (onAddToPlaylist != null)
                  const PopupMenuItem(
                    value: _TrackMenuAction.addToPlaylist,
                    child: ListTile(
                      leading: Icon(Icons.playlist_add),
                      title: Text('Add to playlist'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                if (onRemove != null)
                  const PopupMenuItem(
                    value: _TrackMenuAction.remove,
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Remove from playlist'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
              ],
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}

enum _TrackMenuAction { playNext, addToPlaylist, remove }
