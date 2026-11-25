import 'package:fermata/core/models/exported.dart';
import 'package:fermata/core/models/media_playlist_model.dart';
import 'package:fermata/services/db/dao/track_dao.dart';
import 'package:fermata/services/db/global_db.dart';
import 'package:fermata/services/db/mappers/media_item_mapper.dart';
import 'package:fermata/services/db/mappers/playlist_mapper.dart';
import 'package:isar/isar.dart';

/// CRUD for user playlists. Isar entities never leave this DAO.
class PlaylistDAO {
  PlaylistDAO(this._db, [TrackDAO? tracks]) : _tracks = tracks ?? TrackDAO(_db);

  final Future<Isar> _db;
  final TrackDAO _tracks;

  Future<List<Playlist>> getPlaylists() async {
    final isar = await _db;
    final rows = await isar.playlistDBs
        .filter()
        .typeIndexEqualTo(PlaylistTypeDB.userPlaylist.index)
        .findAll();
    rows.sort((left, right) {
      if (left.isPinned != right.isPinned) return left.isPinned ? -1 : 1;
      final order = left.sortOrder.compareTo(right.sortOrder);
      return order != 0 ? order : right.updatedAt.compareTo(left.updatedAt);
    });
    return rows.map(playlistDBToPlaylist).toList(growable: false);
  }

  Future<Playlist?> getPlaylist(int playlistId) async {
    final isar = await _db;
    final row = await isar.playlistDBs.get(playlistId);
    if (row == null) return null;
    final tracks = await _getTracks(playlistId);
    return playlistDBToPlaylist(row).copyWith(tracks: tracks);
  }

  Future<int?> createPlaylist(String name, {String? description}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;
    final isar = await _db;
    return isar.writeTxnSync(() {
      final existing = isar.playlistDBs
          .filter()
          .nameEqualTo(trimmed, caseSensitive: false)
          .findFirstSync();
      if (existing != null) return existing.id;
      return isar.playlistDBs.putSync(PlaylistDB(
        name: trimmed,
        description: description?.trim(),
        type: PlaylistTypeDB.userPlaylist,
      ));
    });
  }

  Future<void> deletePlaylist(int playlistId) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.playlistEntryDBs
          .filter()
          .playlistIdEqualTo(playlistId)
          .deleteAll();
      await isar.playlistDBs.delete(playlistId);
    });
  }

  Future<void> addTracks(int playlistId, List<Track> tracks) async {
    if (tracks.isEmpty) return;
    final isar = await _db;
    isar.writeTxnSync(() {
      final playlist = isar.playlistDBs.getSync(playlistId);
      if (playlist == null) return;
      final entries = isar.playlistEntryDBs
          .where()
          .playlistIdEqualToAnyPosition(playlistId)
          .findAllSync();
      final seen = <int>{};
      var position = 0;
      for (final entry in entries) {
        entry.track.loadSync();
        final track = entry.track.value;
        if (track != null) seen.add(track.id);
        if (entry.position >= position) position = entry.position + 1;
      }

      var changed = false;
      for (final track in tracks) {
        final trackId = _tracks.upsertTrackInTransaction(isar, track);
        if (!seen.add(trackId)) continue;
        final entry =
            PlaylistEntryDB(playlistId: playlistId, position: position++)
              ..playlist.value = playlist
              ..track.value = isar.trackDBs.getSync(trackId);
        isar.playlistEntryDBs.putSync(entry);
        entry.playlist.saveSync();
        entry.track.saveSync();
        changed = true;
      }
      if (changed) {
        playlist.updatedAt = DateTime.now();
        isar.playlistDBs.putSync(playlist);
      }
    });
  }

  Future<void> addTrack(int playlistId, Track track) =>
      addTracks(playlistId, [track]);

  Future<void> removeTrack(int playlistId, String mediaId) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      final entries = await isar.playlistEntryDBs
          .where()
          .playlistIdEqualToAnyPosition(playlistId)
          .findAll();
      for (final entry in entries) {
        await entry.track.load();
        if (entry.track.value?.mediaId != mediaId) continue;
        await isar.playlistEntryDBs.delete(entry.id);
        final playlist = await isar.playlistDBs.get(playlistId);
        if (playlist != null) {
          playlist.updatedAt = DateTime.now();
          await isar.playlistDBs.put(playlist);
        }
        return;
      }
    });
  }

  Future<void> reorderTrack(
    int playlistId,
    int oldIndex,
    int newIndex,
  ) async {
    if (oldIndex == newIndex) return;
    final isar = await _db;
    await isar.writeTxn(() async {
      final entries = await isar.playlistEntryDBs
          .where()
          .playlistIdEqualToAnyPosition(playlistId)
          .sortByPosition()
          .findAll();
      if (oldIndex < 0 ||
          newIndex < 0 ||
          oldIndex >= entries.length ||
          newIndex >= entries.length) {
        return;
      }
      final moved = entries.removeAt(oldIndex);
      entries.insert(newIndex, moved);
      for (var index = 0; index < entries.length; index++) {
        entries[index].position = index;
      }
      await isar.playlistEntryDBs.putAll(entries);
      final playlist = await isar.playlistDBs.get(playlistId);
      if (playlist != null) {
        playlist.updatedAt = DateTime.now();
        await isar.playlistDBs.put(playlist);
      }
    });
  }

  Future<void> setPinned(int playlistId, bool pinned) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      final playlist = await isar.playlistDBs.get(playlistId);
      if (playlist == null) return;
      playlist.isPinned = pinned;
      await isar.playlistDBs.put(playlist);
    });
  }

  Future<void> reorderPlaylists(List<int> orderedIds) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      for (var index = 0; index < orderedIds.length; index++) {
        final playlist = await isar.playlistDBs.get(orderedIds[index]);
        if (playlist == null) continue;
        playlist.sortOrder = index;
        await isar.playlistDBs.put(playlist);
      }
    });
  }

  Future<List<Track>> _getTracks(int playlistId) async {
    final isar = await _db;
    final entries = await isar.playlistEntryDBs
        .where()
        .playlistIdEqualToAnyPosition(playlistId)
        .sortByPosition()
        .findAll();
    await Future.wait(entries.map((entry) => entry.track.load()));
    return entries
        .map((entry) => entry.track.value)
        .whereType<TrackDB>()
        .map(trackDBToTrack)
        .toList(growable: false);
  }

  Future<Stream<void>> watchPlaylists() async {
    final isar = await _db;
    return isar.playlistDBs.watchLazy(fireImmediately: true);
  }

  Future<Stream<void>> watchPlaylistTracks(int playlistId) async {
    final isar = await _db;
    return isar.playlistEntryDBs
        .filter()
        .playlistIdEqualTo(playlistId)
        .watchLazy(fireImmediately: true);
  }
}
