import 'dart:async';

import 'package:fermata/core/models/exported.dart';
import 'package:fermata/services/cache/media_cache_service.dart';
import 'package:fermata/services/plugin/plugin_service.dart';
import 'package:fermata/services/player/stream_quality_selector.dart';

class ResolvedMediaSource {
  final Uri uri;
  final Map<String, String>? headers;

  const ResolvedMediaSource({required this.uri, this.headers});
}

/// Resolves local, direct, and plugin-backed tracks into playable sources.
class MediaResolverService {
  MediaResolverService(this._plugins, {MediaCacheService? cache})
      : _cache = cache;

  final PluginService? _plugins;
  final MediaCacheService? _cache;
  final Map<String, Future<ResolvedMediaSource>> _resolutions = {};

  Future<ResolvedMediaSource> resolve(Track track) {
    final existing = _resolutions[track.id];
    if (existing != null) return existing;
    final pending = _resolve(track);
    _resolutions[track.id] = pending;
    void clear() {
      if (identical(_resolutions[track.id], pending)) {
        _resolutions.remove(track.id);
      }
    }

    unawaited(pending.then<void>(
      (_) => clear(),
      onError: (Object error, StackTrace stack) => clear(),
    ));
    return pending;
  }

  Future<ResolvedMediaSource> resolveFresh(Track track) => _resolve(track);

  Future<ResolvedMediaSource> _resolve(Track track) async {
    final cached = await _cache?.hit(track.id);
    if (cached != null) {
      return ResolvedMediaSource(
        uri: Uri.file('${cached.filePath}/${cached.fileName}'),
      );
    }
    if (track.id.startsWith('local::')) {
      return ResolvedMediaSource(
        uri: Uri.file(track.id.substring('local::'.length)),
      );
    }
    if (!track.id.contains('::')) {
      final source = track.url?.trim() ?? '';
      if (source.isNotEmpty) {
        final uri = Uri.tryParse(source);
        if (uri != null && uri.hasScheme) {
          return ResolvedMediaSource(uri: uri);
        }
        return ResolvedMediaSource(uri: Uri.file(source));
      }
    }
    final stream = await _plugins?.streams(track);
    if (stream == null || stream.url.trim().isEmpty) {
      throw StateError('No playable stream for ${track.title}');
    }
    final uri = Uri.tryParse(stream.url.trim());
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' &&
            uri.scheme != 'https' &&
            uri.scheme != 'file')) {
      throw StateError('Invalid stream URL for ${track.title}');
    }
    return ResolvedMediaSource(
      uri: uri,
      headers: streamHeadersToMap(stream.headers),
    );
  }
}
