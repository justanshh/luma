import 'package:fermata/core/models/exported.dart';
import 'package:fermata/services/db/global_db.dart';
import 'package:fermata/services/db/mappers/media_item_mapper.dart';

/// Playlist display names differ from the stored key for saved albums,
/// artists, and remote collections.
String playlistDBDisplayName(PlaylistDB playlist) {
  final artists = playlist.artists;
  final albumName = playlist.album?.name.trim() ?? '';
  final remoteName = playlist.remotePlaylist?.name.trim() ?? '';
  return switch (playlist.type) {
    PlaylistTypeDB.artist => artists != null &&
            artists.isNotEmpty &&
            (artists.first.name?.isNotEmpty ?? false)
        ? artists.first.name!.trim()
        : playlist.name,
    PlaylistTypeDB.album => albumName.isNotEmpty ? albumName : playlist.name,
    PlaylistTypeDB.remotePlaylist =>
      remoteName.isNotEmpty ? remoteName : playlist.name,
    PlaylistTypeDB.userPlaylist => playlist.name,
  };
}

RemotePlaylistSummaryDB playlistSummaryToRemotePlaylistSummaryDB(
  PlaylistSummary summary,
) {
  return RemotePlaylistSummaryDB()
    ..mediaId = summary.id
    ..name = summary.title
    ..thumbnail = artworkToArtworkDB(summary.thumbnail)
    ..artists = summary.owner == null
        ? null
        : [
            ArtistSummaryDB()
              ..name = summary.owner
              ..mediaId = '',
          ]
    ..url = summary.url;
}
