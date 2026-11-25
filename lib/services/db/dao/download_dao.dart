import 'dart:io';

import 'package:fermata/core/models/cached_media.dart';
import 'package:fermata/core/models/exported.dart';
import 'package:fermata/services/db/dao/track_dao.dart';
import 'package:fermata/services/db/global_db.dart';
import 'package:isar/isar.dart';

class DownloadDAO {
  const DownloadDAO(this._db, this._tracks);

  final Future<Isar> _db;
  final TrackDAO _tracks;

  Future<void> putDownload({
    required String fileName,
    required String filePath,
    required Track track,
    DateTime? lastDownloaded,
  }) async {
    final isar = await _db;
    isar.writeTxnSync(() {
      _tracks.upsertTrackInTransaction(isar, track);
      final existing =
          isar.downloadDBs.filter().mediaIdEqualTo(track.id).findFirstSync();
      final row = DownloadDB(
        fileName: fileName,
        filePath: filePath,
        lastDownloaded: lastDownloaded ?? DateTime.now(),
        mediaId: track.id,
      );
      if (existing != null) row.id = existing.id;
      isar.downloadDBs.putSync(row);
    });
  }

  Future<CachedMedia?> getDownload(String mediaId) async {
    final isar = await _db;
    final row =
        await isar.downloadDBs.filter().mediaIdEqualTo(mediaId).findFirst();
    if (row == null) return null;
    final file = File('${row.filePath}/${row.fileName}');
    if (!await file.exists()) return null;
    return _map(row);
  }

  Future<List<CachedMedia>> getAllDownloads() async {
    final isar = await _db;
    final rows = await isar.downloadDBs.where().findAll();
    final result = <CachedMedia>[];
    for (final row in rows) {
      if (await File('${row.filePath}/${row.fileName}').exists()) {
        result.add(_map(row));
      }
    }
    return result;
  }

  Future<void> touch(String mediaId) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      final row =
          await isar.downloadDBs.filter().mediaIdEqualTo(mediaId).findFirst();
      if (row != null) {
        row.lastDownloaded = DateTime.now();
        await isar.downloadDBs.put(row);
      }
    });
  }

  Future<void> remove(String mediaId, {bool deleteFile = true}) async {
    final isar = await _db;
    final row =
        await isar.downloadDBs.filter().mediaIdEqualTo(mediaId).findFirst();
    if (row == null) return;
    await isar.writeTxn(() => isar.downloadDBs.delete(row.id));
    if (deleteFile) {
      final file = File('${row.filePath}/${row.fileName}');
      if (await file.exists()) await file.delete();
    }
  }

  Future<Stream<void>> watchDownloads() async {
    final isar = await _db;
    return isar.downloadDBs.watchLazy(fireImmediately: false);
  }

  CachedMedia _map(DownloadDB row) => CachedMedia(
        mediaId: row.mediaId,
        filePath: row.filePath,
        fileName: row.fileName,
        lastPlayed: row.lastDownloaded,
      );
}
