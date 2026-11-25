import 'dart:io';

import 'package:fermata/core/models/cached_media.dart';
import 'package:fermata/core/models/exported.dart';
import 'package:fermata/services/db/dao/download_dao.dart';
import 'package:fermata/services/db/dao/settings_dao.dart';

class MediaCacheService {
  MediaCacheService({
    required SettingsDAO settings,
    required DownloadDAO downloads,
    required this.stateDir,
  })  : _settings = settings,
        _downloads = downloads,
        directory = Directory('$stateDir/cache') {
    directory.createSync(recursive: true);
  }

  static const capKey = 'cache.cap.bytes';
  static const defaultCap = 5 * 1024 * 1024 * 1024;

  final SettingsDAO _settings;
  final DownloadDAO _downloads;
  final String stateDir;
  final Directory directory;

  Future<CachedMedia?> hit(String mediaId) async {
    final cached = await _downloads.getDownload(mediaId);
    if (cached == null) return null;
    await _downloads.touch(mediaId);
    return cached;
  }

  Future<void> store({
    required Track track,
    required String sourcePath,
    required String fileName,
  }) async {
    final source = File(sourcePath);
    final safeName = _safeName(fileName, sourcePath);
    final target = File('${directory.path}/$safeName');
    if (source.absolute.path != target.absolute.path) {
      await source.copy(target.path);
    }
    await _downloads.putDownload(
      fileName: safeName,
      filePath: directory.path,
      track: track,
    );
    await enforceCap(await cap());
  }

  Future<int> usage() async {
    final records = await _downloads.getAllDownloads();
    var bytes = 0;
    for (final record in records) {
      final file = File('${record.filePath}/${record.fileName}');
      if (await file.exists()) bytes += await file.length();
    }
    return bytes;
  }

  Future<int> cap() async {
    final raw = await _settings.getSettingStr(capKey);
    return int.tryParse(raw ?? '') ?? defaultCap;
  }

  Future<void> setCap(int bytes) =>
      _settings.putSettingStr(capKey, bytes.toString());

  Future<void> enforceCap(int bytes) async {
    final records = await _downloads.getAllDownloads();
    records.sort((a, b) {
      final left = a.lastPlayed ?? DateTime.fromMillisecondsSinceEpoch(0);
      final right = b.lastPlayed ?? DateTime.fromMillisecondsSinceEpoch(0);
      return left.compareTo(right);
    });
    var used = await usage();
    for (final record in records) {
      if (used <= bytes) break;
      final file = File('${record.filePath}/${record.fileName}');
      final length = await file.exists() ? await file.length() : 0;
      await _downloads.remove(record.mediaId);
      used -= length;
    }
  }

  Future<void> clear() async {
    final records = await _downloads.getAllDownloads();
    for (final record in records) {
      await _downloads.remove(record.mediaId, deleteFile: false);
      final file = File('${record.filePath}/${record.fileName}');
      if (await file.exists()) await file.delete();
    }
    await for (final entry in directory.list()) {
      if (entry is File && await entry.exists()) await entry.delete();
    }
  }

  String _safeName(String fileName, String sourcePath) {
    final candidate =
        fileName.contains('/') ? sourcePath.split('/').last : fileName;
    return candidate.isEmpty ? 'audio.bin' : candidate;
  }
}
