import 'package:fermata/core/models/media_playlist_model.dart';
import 'package:fermata/services/db/global_db.dart';
import 'package:fermata/services/db/mappers/collection_mapper.dart';
import 'package:fermata/services/db/mappers/media_item_mapper.dart';

Playlist playlistDBToPlaylist(PlaylistDB row) {
  return Playlist(
    id: row.id,
    tracks: const [],
    title: playlistDBDisplayName(row),
    thumbnail:
        row.thumbnail == null ? null : artworkDBToArtwork(row.thumbnail!),
    subtitle: row.subtitle,
    description: row.description,
    type: playlistTypeDBToPlaylistType(row.type),
    artists: row.artists?.map(artistSummaryDBToArtistSummary).toList(),
    album: row.album == null ? null : albumSummaryDBToAlbumSummary(row.album!),
    remotePlaylist: row.remotePlaylist == null
        ? null
        : playlistSummaryDBToPlaylistSummary(row.remotePlaylist!),
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    isPinned: row.isPinned,
    sortOrder: row.sortOrder,
  );
}

PlaylistDB playlistToPlaylistDB(Playlist playlist) {
  return PlaylistDB(
    name: playlist.title,
    subtitle: playlist.subtitle,
    description: playlist.description,
    thumbnail: playlist.thumbnail == null
        ? null
        : artworkToArtworkDB(playlist.thumbnail!),
    artists: playlist.artists?.map(artistSummaryToArtistSummaryDB).toList(),
    album: playlist.album == null
        ? null
        : albumSummaryToAlbumSummaryDB(playlist.album!),
    remotePlaylist: playlist.remotePlaylist == null
        ? null
        : playlistSummaryToRemotePlaylistSummaryDB(playlist.remotePlaylist!),
    type: playlistTypeToPlaylistTypeDB(playlist.type),
    createdat: playlist.createdAt,
    updatedat: playlist.updatedAt ?? DateTime.now(),
    isPinned: playlist.isPinned,
    sortOrder: playlist.sortOrder,
  );
}

PlaylistType playlistTypeDBToPlaylistType(PlaylistTypeDB type) {
  return switch (type) {
    PlaylistTypeDB.userPlaylist => PlaylistType.userPlaylist,
    PlaylistTypeDB.album => PlaylistType.album,
    PlaylistTypeDB.artist => PlaylistType.artist,
    PlaylistTypeDB.remotePlaylist => PlaylistType.remotePlaylist,
  };
}

PlaylistTypeDB playlistTypeToPlaylistTypeDB(PlaylistType type) {
  return switch (type) {
    PlaylistType.userPlaylist => PlaylistTypeDB.userPlaylist,
    PlaylistType.album => PlaylistTypeDB.album,
    PlaylistType.artist => PlaylistTypeDB.artist,
    PlaylistType.remotePlaylist => PlaylistTypeDB.remotePlaylist,
  };
}
