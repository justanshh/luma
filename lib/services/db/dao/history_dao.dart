import 'dart:math';

import 'package:fermata/core/models/exported.dart';
import 'package:fermata/core/models/playback_history_entry.dart';
import 'package:fermata/services/db/dao/track_dao.dart';
import 'package:fermata/services/db/global_db.dart';
import 'package:fermata/services/db/mappers/media_item_mapper.dart';
import 'package:isar/isar.dart';

/// Persists playback history while exposing only domain values to callers.
class HistoryDAO {
  HistoryDAO(this._db, [TrackDAO? tracks]) : _tracks = tracks ?? TrackDAO(_db);

  final Future<Isar> _db;
  final TrackDAO _tracks;

  Future<void> recordPlay(Track track) async {
    final isar = await _db;
    isar.writeTxnSync(() {
      final trackId = _tracks.upsertTrackInTransaction(isar, track);
      final entry = PlaybackHistoryDB(playedAt: DateTime.now())
        ..track.value = isar.trackDBs.getSync(trackId);
      isar.playbackHistoryDBs.putSync(entry);
      entry.track.saveSync();
    });
  }

  /// Returns unique tracks ordered by their most recent play.
  Future<List<PlaybackHistoryEntry>> getHistory({int limit = 50}) async {
    final isar = await _db;
    final query = isar.playbackHistoryDBs.where().sortByPlayedAtDesc();
    final fetchLimit = limit > 0 ? max(limit * 4, limit) : 0;
    final rows = fetchLimit > 0
        ? await query.limit(fetchLimit).findAll()
        : await query.findAll();
    await Future.wait(rows.map((row) => row.track.load()));

    final seen = <String>{};
    final result = <PlaybackHistoryEntry>[];
    for (final row in rows) {
      final track = row.track.value;
      if (track == null || !seen.add(track.mediaId)) continue;
      result.add(PlaybackHistoryEntry(
        track: trackDBToTrack(track),
        playedAt: row.playedAt,
      ));
      if (limit > 0 && result.length >= limit) break;
    }
    return List.unmodifiable(result);
  }

  Future<void> clearHistory() async {
    final isar = await _db;
    await isar.writeTxn(() => isar.playbackHistoryDBs.clear());
  }

  Future<Stream<void>> watchHistory() async {
    final isar = await _db;
    return isar.playbackHistoryDBs.watchLazy(fireImmediately: true);
  }
}
