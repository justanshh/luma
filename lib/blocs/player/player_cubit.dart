import 'dart:async';
import 'dart:io';

import 'package:fermata/core/models/exported.dart';
import 'package:fermata/services/db/dao/track_dao.dart';
import 'package:fermata/services/player/media_resolver_service.dart';
import 'package:fermata/services/player/player_engine.dart';
import 'package:fermata/src/rust/api/local_music.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

abstract class Cubit<S> extends ChangeNotifier {
  Cubit(this.state);

  S state;
  final StreamController<S> _controller = StreamController<S>.broadcast();

  Stream<S> get stream => _controller.stream;

  void emit(S next) {
    state = next;
    notifyListeners();
    _controller.add(next);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}

class CubitProvider<T extends Cubit<dynamic>> extends StatefulWidget {
  const CubitProvider({super.key, required this.create, required this.child});

  final T Function() create;
  final Widget child;

  @override
  State<CubitProvider<T>> createState() => _CubitProviderState<T>();
}

class _CubitProviderState<T extends Cubit<dynamic>>
    extends State<CubitProvider<T>> {
  late final T cubit = widget.create();

  @override
  void dispose() {
    cubit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _CubitScope<T>(
        cubit: cubit,
        child: widget.child,
      );
}

class _CubitScope<T extends Cubit<dynamic>> extends InheritedWidget {
  const _CubitScope({required this.cubit, required super.child});

  final T cubit;

  @override
  bool updateShouldNotify(_CubitScope<T> oldWidget) => false;
}

extension CubitContext on BuildContext {
  T watch<T extends Cubit<dynamic>>() {
    final scope = dependOnInheritedWidgetOfExactType<_CubitScope<T>>();
    if (scope == null) throw StateError('Missing CubitProvider<$T>');
    return scope.cubit;
  }
}

class PlayerService extends ChangeNotifier {
  PlayerService({
    PlayerEngine? playerEngine,
    MediaResolverService? resolver,
    Future<ResolvedMediaSource> Function(Track track)? resolve,
  })  : engine = playerEngine ?? PlayerEngine(),
        _resolver = resolver,
        _resolveOverride = resolve {
    _subscriptions.addAll([
      engine.positionStream.listen((_) => notifyListeners()),
      engine.playingStream.listen((_) => notifyListeners()),
      engine.durationStream.listen((_) => notifyListeners()),
      engine.volumeStream.listen((_) => notifyListeners()),
      engine.errorStream.listen((error) {
        this.error = error;
        _streamUnavailable = true;
        _recoveryPosition = engine.recoveryPosition;
        notifyListeners();
        unawaited(_recover(error));
      }),
      engine.completionStream.listen((_) => unawaited(next())),
    ]);
  }

  final PlayerEngine engine;
  final List<Track> queue = [];
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final MediaResolverService? _resolver;
  final Future<ResolvedMediaSource> Function(Track track)? _resolveOverride;
  int currentIndex = -1;
  String? error;
  bool reconnecting = false;

  int _recoveryAttempts = 0;
  bool _recovering = false;
  bool _manualPause = false;
  bool _streamUnavailable = false;
  Duration? _recoveryPosition;
  int _generation = 0;

  Track? get current => currentIndex >= 0 && currentIndex < queue.length
      ? queue[currentIndex]
      : null;
  Duration get position => engine.position;
  Duration get duration => engine.duration;
  bool get playing => engine.playing;
  double get volume => engine.volume;
  bool get _isRemote =>
      current != null &&
      current!.id.contains('::') &&
      !current!.id.startsWith('local::');

  void setQueue(List<Track> tracks) {
    _cancelRecovery();
    queue
      ..clear()
      ..addAll(tracks);
    currentIndex = tracks.isEmpty ? -1 : 0;
    _recoveryAttempts = 0;
    _manualPause = false;
    _streamUnavailable = false;
    _recoveryPosition = null;
    error = null;
    notifyListeners();
  }

  void move(int from, int to) {
    if (from < 0 || from >= queue.length || to < 0 || to >= queue.length) {
      return;
    }
    final currentId = current?.id;
    final track = queue.removeAt(from);
    queue.insert(to.clamp(0, queue.length), track);
    if (currentId != null) {
      currentIndex = queue.indexWhere((item) => item.id == currentId);
    }
    notifyListeners();
  }

  Future<void> removeAt(int index) async {
    if (index < 0 || index >= queue.length) return;
    final removingCurrent = index == currentIndex;
    queue.removeAt(index);
    if (index < currentIndex) currentIndex--;
    if (removingCurrent) {
      if (queue.isEmpty) {
        currentIndex = -1;
        await engine.stop();
      } else {
        currentIndex = currentIndex.clamp(0, queue.length - 1);
        await _openCurrent();
      }
    }
    notifyListeners();
  }

  void playNext(Track track) {
    final currentId = current?.id;
    queue.removeWhere((item) => item.id == track.id);
    if (currentId != null && currentId != track.id) {
      currentIndex = queue.indexWhere((item) => item.id == currentId);
    }
    final insertAt = currentIndex < 0 ? queue.length : currentIndex + 1;
    queue.insert(insertAt.clamp(0, queue.length), track);
    if (currentId != null) {
      currentIndex = queue.indexWhere((item) => item.id == currentId);
    }
    notifyListeners();
  }

  void insertAfter(String anchorId, Track track) {
    final anchor = queue.indexWhere((item) => item.id == anchorId);
    if (anchor < 0 || anchorId == track.id) return;
    final currentId = current?.id;
    queue.removeWhere((item) => item.id == track.id);
    final adjustedAnchor = queue.indexWhere((item) => item.id == anchorId);
    if (adjustedAnchor < 0) return;
    queue.insert((adjustedAnchor + 1).clamp(0, queue.length), track);
    if (currentId != null) {
      currentIndex = queue.indexWhere((item) => item.id == currentId);
    }
    notifyListeners();
  }

  Future<void> play(Track track) async {
    _cancelRecovery();
    final index = queue.indexWhere((item) => item.id == track.id);
    currentIndex = index >= 0 ? index : queue.length;
    if (index < 0) queue.add(track);
    _recoveryAttempts = 0;
    _manualPause = false;
    _streamUnavailable = false;
    _recoveryPosition = null;
    await _openCurrent();
  }

  Future<void> resume() async {
    if (current == null) return;
    _manualPause = false;
    if (_streamUnavailable || engine.state == EngineState.idle) {
      if (_isRemote) {
        await _recover('manual resume');
      } else {
        await _openCurrent();
      }
      return;
    }
    await engine.play();
  }

  Future<void> pause() async {
    _manualPause = true;
    _cancelRecovery();
    await engine.pause();
  }

  Future<void> stop() async {
    _manualPause = true;
    _cancelRecovery();
    _streamUnavailable = true;
    error = null;
    await engine.stop();
    notifyListeners();
  }

  Future<void> clearQueue() async {
    _cancelRecovery();
    queue.clear();
    currentIndex = -1;
    _recoveryAttempts = 0;
    _manualPause = true;
    _streamUnavailable = false;
    _recoveryPosition = null;
    error = null;
    await engine.stop();
    notifyListeners();
  }

  Future<void> next() async {
    _cancelRecovery();
    _recoveryAttempts = 0;
    _manualPause = false;
    _streamUnavailable = false;
    _recoveryPosition = null;
    if (currentIndex + 1 >= queue.length) {
      await engine.stop();
      currentIndex = -1;
      notifyListeners();
      return;
    }
    currentIndex++;
    await _openCurrent();
  }

  Future<void> prev() async {
    _cancelRecovery();
    _recoveryAttempts = 0;
    _manualPause = false;
    _streamUnavailable = false;
    _recoveryPosition = null;
    if (currentIndex <= 0) {
      await seek(Duration.zero);
      return;
    }
    currentIndex--;
    await _openCurrent();
  }

  Future<void> toggle() async {
    if (current == null) return;
    if (playing) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> seek(Duration position) => engine.seek(position);
  Future<void> setVolume(double value) => engine.setVolume(value);

  Future<void> _openCurrent() async {
    final track = current;
    if (track == null) return;
    final generation = ++_generation;
    error = null;
    reconnecting = false;
    notifyListeners();
    try {
      final source = await _resolve(track);
      if (generation != _generation || _manualPause) return;
      final result =
          await engine.openDirect(source.uri, httpHeaders: source.headers);
      if (generation != _generation || _manualPause) return;
      if (result is EngineFailure) {
        error = result.error.toString();
        _streamUnavailable = true;
        notifyListeners();
        unawaited(_recover('load failed'));
      } else {
        _streamUnavailable = false;
        _recoveryPosition = null;
        error = null;
        notifyListeners();
      }
    } catch (failure) {
      if (generation != _generation || _manualPause) return;
      error = failure.toString();
      _streamUnavailable = true;
      notifyListeners();
      unawaited(_recover('resolve failed'));
    }
  }

  Future<ResolvedMediaSource> _resolve(Track track, {bool fresh = false}) {
    final override = _resolveOverride;
    if (override != null) return override(track);
    final resolver = _resolver;
    if (resolver == null) {
      throw StateError('MediaResolverService is not registered');
    }
    return fresh ? resolver.resolveFresh(track) : resolver.resolve(track);
  }

  Future<void> _recover(String reason) async {
    final track = current;
    if (_recovering || _manualPause || track == null || !_isRemote) return;
    if (_recoveryAttempts >= 3) {
      _streamUnavailable = true;
      error = 'Stream recovery failed after 3 attempts: $reason';
      notifyListeners();
      return;
    }
    _recovering = true;
    reconnecting = true;
    error = null;
    notifyListeners();
    final generation = ++_generation;
    final resumeAt = _recoveryPosition ?? engine.recoveryPosition;
    try {
      while (_recoveryAttempts < 3) {
        if (generation != _generation || _manualPause) return;
        final attempt = _recoveryAttempts;
        _recoveryAttempts++;
        if (attempt > 0) {
          await Future<void>.delayed(
              Duration(milliseconds: 300 * (attempt + 1)));
        }
        if (generation != _generation || _manualPause) return;
        try {
          final source = await _resolve(track, fresh: true);
          if (generation != _generation || _manualPause) return;
          final result = await engine.openDirect(
            source.uri,
            httpHeaders: source.headers,
            initialPosition: resumeAt,
          );
          if (generation != _generation || _manualPause) return;
          if (result is EngineSuccess) {
            _streamUnavailable = false;
            _recoveryPosition = null;
            error = null;
            return;
          }
          if (result case EngineFailure(:final error)) {
            this.error = error.toString();
          }
        } catch (failure) {
          if (generation != _generation || _manualPause) return;
          error = failure.toString();
        }
      }
      _streamUnavailable = true;
      error = 'Stream recovery failed after 3 attempts: $reason';
    } finally {
      if (generation == _generation) {
        _recovering = false;
        reconnecting = false;
        notifyListeners();
      }
    }
  }

  void _cancelRecovery() {
    _generation++;
    _recovering = false;
    reconnecting = false;
  }

  @override
  Future<void> dispose() async {
    _cancelRecovery();
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await engine.dispose();
    super.dispose();
  }
}

class PlayerState {
  const PlayerState({
    required this.tracks,
    required this.currentIndex,
    required this.position,
    required this.duration,
    required this.playing,
    required this.volume,
    required this.error,
    required this.reconnecting,
  });

  final List<Track> tracks;
  final int currentIndex;
  final Duration position;
  final Duration duration;
  final bool playing;
  final double volume;
  final String? error;
  final bool reconnecting;

  Track? get current => currentIndex >= 0 && currentIndex < tracks.length
      ? tracks[currentIndex]
      : null;
}

class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit(this._player, this._dao)
      : super(PlayerState(
          tracks: const [],
          currentIndex: -1,
          position: Duration.zero,
          duration: Duration.zero,
          playing: false,
          volume: _player.volume,
          error: null,
          reconnecting: false,
        )) {
    _player.addListener(_publish);
  }

  final PlayerService _player;
  final TrackDAO _dao;

  Future<void> loadLibrary() async {
    _player.setQueue(await _dao.getAllTracks());
    _publish();
  }

  Future<void> importFolder(String path) async {
    final support = await getApplicationSupportDirectory();
    final coverDir = Directory('${support.path}/covers');
    await coverDir.create(recursive: true);
    final metadata = await scanAudioFiles(
      directories: [path],
      coverCacheDir: coverDir.path,
    );
    const extensions = {'.mp3', '.flac', '.ogg', '.m4a'};
    final tracks = metadata
        .where((item) => extensions.contains(
              File(item.filePath).path.toLowerCase().substring(
                    File(item.filePath).path.toLowerCase().lastIndexOf('.'),
                  ),
            ))
        .map((item) => Track(
              id: 'local::${item.filePath}',
              title: item.title ?? File(item.filePath).uri.pathSegments.last,
              artists: item.artists
                  .map((name) => ArtistSummary(id: '', name: name))
                  .toList(growable: false),
              album: item.album == null
                  ? null
                  : AlbumSummary(
                      id: '',
                      title: item.album!,
                      artists: const [],
                      year: item.year,
                    ),
              thumbnail: Artwork(
                url: item.coverArtPath ?? '',
                layout: ImageLayout.square,
              ),
              durationMs: item.durationMs,
              url: item.filePath,
              isExplicit: false,
            ))
        .toList(growable: true)
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    await _dao.upsertTracks(tracks);
    await loadLibrary();
  }

  void move(int from, int to) => _player.move(from, to);
  Future<void> removeAt(int index) => _player.removeAt(index);
  void playNext(Track track) => _player.playNext(track);
  void insertAfter(String anchorId, Track track) =>
      _player.insertAfter(anchorId, track);

  Future<void> play(Track track) => _player.play(track);

  Future<void> playResults(List<Track> tracks) async {
    _player.setQueue(tracks);
    _publish();
    if (tracks.isNotEmpty) await _player.play(tracks.first);
  }

  Future<void> next() => _player.next();
  Future<void> prev() => _player.prev();
  Future<void> seek(Duration position) => _player.seek(position);
  Future<void> setVolume(double value) => _player.setVolume(value);
  Future<void> clearQueue() => _player.clearQueue();
  Future<void> toggle() => _player.toggle();

  void _publish() {
    emit(PlayerState(
      tracks: List.unmodifiable(_player.queue),
      currentIndex: _player.currentIndex,
      position: _player.position,
      duration: _player.duration,
      playing: _player.playing,
      volume: _player.volume,
      error: _player.error,
      reconnecting: _player.reconnecting,
    ));
  }

  @override
  void dispose() {
    _player.removeListener(_publish);
    super.dispose();
  }
}

String formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
