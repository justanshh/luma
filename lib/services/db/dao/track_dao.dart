import 'package:fermata/services/db/global_db.dart';
import 'package:fermata/services/db/mappers/media_item_mapper.dart';
import 'package:fermata/src/rust/api/plugin/models.dart';
import 'package:isar/isar.dart';

/// Track persistence. Callers receive domain [Track] values only.
class TrackDAO {
  final Future<Isar> _db;

  const TrackDAO(this._db);

  int upsertTrackInTransaction(Isar isar, Track track) {
    final row = trackToTrackDB(track);
    final existing =
        isar.trackDBs.filter().mediaIdEqualTo(track.id).findFirstSync();
    if (existing != null) row.id = existing.id;
    return isar.trackDBs.putSync(row);
  }

  Future<List<int>> upsertTracks(List<Track> tracks) async {
    if (tracks.isEmpty) return [];
    final isar = await _db;
    return isar.writeTxnSync(() {
      final ids = <int>[];
      for (final track in tracks) {
        ids.add(upsertTrackInTransaction(isar, track));
      }
      return ids;
    });
  }

  Future<Track?> getTrackByMediaId(String mediaId) async {
    final isar = await _db;
    final row =
        await isar.trackDBs.filter().mediaIdEqualTo(mediaId).findFirst();
    return row == null ? null : trackDBToTrack(row);
  }

  Future<List<Track>> getAllTracks() async {
    final isar = await _db;
    final rows = await isar.trackDBs.where().findAll();
    return rows.map(trackDBToTrack).toList(growable: false);
  }

  Future<List<Track>> searchTracks(String query, {int limit = 50}) async {
    if (query.trim().isEmpty) return [];
    final isar = await _db;
    final rows = await isar.trackDBs
        .filter()
        .titleContains(query, caseSensitive: false)
        .limit(limit)
        .findAll();
    return rows.map(trackDBToTrack).toList(growable: false);
  }

  Future<Stream<void>> watchTracks() async {
    final isar = await _db;
    return isar.trackDBs.watchLazy(fireImmediately: false);
  }
}
