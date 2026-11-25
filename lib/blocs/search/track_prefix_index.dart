import 'dart:async';

import 'package:fermata/core/models/exported.dart';
import 'package:fermata/services/db/dao/track_dao.dart';
import 'package:flutter/foundation.dart';

/// In-memory search over domain tracks, independent of persistence details.
abstract class TrackSearchIndex extends ChangeNotifier {
  Future<void> initialize();

  Future<List<Track>> search(String query, {int limit = 50});
}

/// A prefix index loaded from the complete track library at startup.
///
/// The DAO watcher invalidates the index whenever persisted tracks change.
class TrackPrefixIndex extends TrackSearchIndex {
  TrackPrefixIndex(this._dao);

  final TrackDAO _dao;
  final Completer<void> _ready = Completer<void>();
  final RegExp _whitespace = RegExp(r'\s+');

  StreamSubscription<void>? _watcher;
  Map<String, Track> _tracksById = const {};
  Map<String, List<String>> _prefixIndex = const {};
  Object? _watchError;
  Object? _loadError;
  int _revision = 0;
  bool _initializing = false;
  bool _disposed = false;

  @override
  Future<void> initialize() {
    if (!_initializing && !_ready.isCompleted) {
      _initializing = true;
      unawaited(_start());
    }
    return _ready.future;
  }

  Future<void> _start() async {
    _invalidate();
    try {
      final changes = await _dao.watchTracks();
      if (_disposed) return;
      _watcher = changes.listen(
        (_) => unawaited(_refresh()),
        onError: (Object error) {
          _watchError = error;
          _invalidate();
        },
      );
    } catch (error) {
      _watchError = error;
    }
    if (!_disposed) await _refresh();
  }

  Future<void> _refresh() async {
    final revision = ++_revision;
    _invalidate();
    try {
      final tracks = await _dao.getAllTracks();
      if (_disposed || revision != _revision) return;
      _replace(tracks);
      notifyListeners();
    } catch (error) {
      if (_disposed || revision != _revision) return;
      _loadError = error;
      notifyListeners();
    } finally {
      if (!_disposed &&
          revision == _revision &&
          _initializing &&
          !_ready.isCompleted) {
        _initializing = false;
        _ready.complete();
      }
    }
  }

  void _invalidate() {
    if (_disposed) return;
    _tracksById = const {};
    _prefixIndex = const {};
    _loadError = null;
    notifyListeners();
  }

  void _replace(Iterable<Track> tracks) {
    final ordered = List<Track>.unmodifiable(tracks);
    _tracksById = Map<String, Track>.unmodifiable({
      for (final track in ordered) track.id: track,
    });
    _prefixIndex = _buildPrefixIndex(ordered);
  }

  Map<String, List<String>> _buildPrefixIndex(List<Track> tracks) {
    final prefixes = <String, List<String>>{};
    for (final track in tracks) {
      final indexed = <String>{};
      final fields = <String>[
        track.title,
        ...track.artists.map((artist) => artist.name),
        if (track.album case final album?) album.title,
      ];
      for (final field in fields) {
        final normalized = _normalize(field);
        if (normalized.isEmpty) continue;
        _addPrefixes(normalized, track.id, indexed, prefixes);
        for (final token in normalized.split(' ')) {
          _addPrefixes(token, track.id, indexed, prefixes);
        }
      }
    }
    return prefixes;
  }

  void _addPrefixes(
    String value,
    String trackId,
    Set<String> indexed,
    Map<String, List<String>> prefixes,
  ) {
    for (var length = 1; length <= value.length; length++) {
      final prefix = value.substring(0, length);
      if (!indexed.add(prefix)) continue;
      prefixes.putIfAbsent(prefix, () => <String>[]).add(trackId);
    }
  }

  String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(_whitespace, ' ');

  @override
  Future<List<Track>> search(String query, {int limit = 50}) async {
    await initialize();
    final normalized = _normalize(query);
    if (normalized.isEmpty || limit <= 0) return const [];

    final watchError = _watchError;
    if (watchError != null) {
      throw StateError('Library search watcher failed: $watchError');
    }
    final loadError = _loadError;
    if (loadError != null) {
      throw StateError('Library search index failed to load: $loadError');
    }

    final matches = _prefixIndex[normalized];
    if (matches == null || matches.isEmpty) return const [];
    final count = matches.length < limit ? matches.length : limit;
    return List<Track>.unmodifiable([
      for (var index = 0; index < count; index++) _tracksById[matches[index]]!,
    ]);
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    final watcher = _watcher;
    _watcher = null;
    unawaited(watcher?.cancel() ?? Future<void>.value());
    if (!_ready.isCompleted) _ready.complete();
    super.dispose();
  }
}
