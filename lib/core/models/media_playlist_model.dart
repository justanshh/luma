import 'package:fermata/core/models/exported.dart';

enum PlaylistType { userPlaylist, album, artist, remotePlaylist }

class Playlist {
  final List<Track> tracks;
  final String title;
  final int? id;
  final bool isPinned;
  final int sortOrder;
  final Artwork? thumbnail;
  final String? permaURL;
  final List<ArtistSummary>? artists;
  final AlbumSummary? album;
  final PlaylistSummary? remotePlaylist;
  final String? subtitle;
  final String? description;
  final PlaylistType type;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Playlist({
    required this.tracks,
    required this.title,
    this.id,
    this.thumbnail,
    this.permaURL,
    this.artists,
    this.album,
    this.remotePlaylist,
    this.subtitle,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.type = PlaylistType.userPlaylist,
    this.isPinned = false,
    this.sortOrder = 0,
  });

  Playlist copyWith({
    List<Track>? tracks,
    String? title,
    int? id,
    bool? isPinned,
    int? sortOrder,
    Artwork? thumbnail,
    String? permaURL,
    List<ArtistSummary>? artists,
    AlbumSummary? album,
    PlaylistSummary? remotePlaylist,
    String? subtitle,
    String? description,
    PlaylistType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Playlist(
      tracks: tracks ?? this.tracks,
      title: title ?? this.title,
      id: id ?? this.id,
      thumbnail: thumbnail ?? this.thumbnail,
      permaURL: permaURL ?? this.permaURL,
      artists: artists ?? this.artists,
      album: album ?? this.album,
      remotePlaylist: remotePlaylist ?? this.remotePlaylist,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      isPinned: isPinned ?? this.isPinned,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
