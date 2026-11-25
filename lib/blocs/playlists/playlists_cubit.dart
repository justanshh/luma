import 'dart:async';

import 'package:fermata/blocs/player/player_cubit.dart';
import 'package:fermata/core/models/exported.dart';
import 'package:fermata/core/models/media_playlist_model.dart';
import 'package:fermata/services/db/dao/playlist_dao.dart';

class PlaylistsState {
  const PlaylistsState({
    this.playlists = const [],
    this.selected,
    this.loading = false,
    this.error,
  });

  final List<Playlist> playlists;
  final Playlist? selected;
  final bool loading;
  final String? error;

  PlaylistsState copyWith({
    List<Playlist>? playlists,
    Playlist? selected,
    bool? loading,
    String? error,
    bool clearError = false,
    bool clearSelection = false,
  }) {
    return PlaylistsState(
      playlists: playlists ?? this.playlists,
      selected: clearSelection ? null : (selected ?? this.selected),
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PlaylistsCubit extends Cubit<PlaylistsState> {
  PlaylistsCubit(this._dao) : super(const PlaylistsState()) {
    unawaited(load());
    unawaited(_watchPlaylists());
  }

  final PlaylistDAO _dao;
  StreamSubscription<void>? _playlistsSubscription;
  StreamSubscription<void>? _entriesSubscription;
  int? _selectedId;
  bool _disposed = false;

  Future<void> load() async {
    if (_disposed) return;
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final playlists = await _dao.getPlaylists();
      if (_disposed) return;
      emit(state.copyWith(playlists: playlists, loading: false));
    } catch (error) {
      if (_disposed) return;
      emit(state.copyWith(loading: false, error: error.toString()));
    }
  }

  Future<int?> createPlaylist(String name, {String? description}) async {
    try {
      final id = await _dao.createPlaylist(name, description: description);
      await load();
      return id;
    } catch (error) {
      if (!_disposed) emit(state.copyWith(error: error.toString()));
      return null;
    }
  }

  Future<void> openPlaylist(int playlistId) async {
    await _entriesSubscription?.cancel();
    _selectedId = playlistId;
    emit(state.copyWith(
      loading: true,
      clearError: true,
      clearSelection: true,
    ));
    try {
      final playlist = await _dao.getPlaylist(playlistId);
      if (_disposed) return;
      emit(state.copyWith(selected: playlist, loading: false));
      final stream = await _dao.watchPlaylistTracks(playlistId);
      if (_disposed) return;
      _entriesSubscription = stream.listen((_) => unawaited(_reloadSelected()));
    } catch (error) {
      if (!_disposed) {
        emit(state.copyWith(loading: false, error: error.toString()));
      }
    }
  }

  Future<void> _reloadSelected() async {
    final id = _selectedId;
    if (id == null || _disposed) return;
    try {
      final playlist = await _dao.getPlaylist(id);
      if (!_disposed) {
        emit(state.copyWith(selected: playlist, clearError: true));
      }
    } catch (error) {
      if (!_disposed) emit(state.copyWith(error: error.toString()));
    }
  }

  void closePlaylist() {
    _selectedId = null;
    unawaited(_entriesSubscription?.cancel());
    _entriesSubscription = null;
    emit(state.copyWith(clearSelection: true));
  }

  Future<void> addTrack(int playlistId, Track track) =>
      addTracks(playlistId, [track]);

  Future<void> addTracks(int playlistId, List<Track> tracks) async {
    try {
      await _dao.addTracks(playlistId, tracks);
      await load();
      if (_selectedId == playlistId) await _reloadSelected();
    } catch (error) {
      if (!_disposed) emit(state.copyWith(error: error.toString()));
    }
  }

  Future<void> removeTrack(int playlistId, String mediaId) async {
    try {
      await _dao.removeTrack(playlistId, mediaId);
      await _reloadSelected();
    } catch (error) {
      if (!_disposed) emit(state.copyWith(error: error.toString()));
    }
  }

  Future<void> reorderTrack(int playlistId, int oldIndex, int newIndex) async {
    try {
      await _dao.reorderTrack(playlistId, oldIndex, newIndex);
      await _reloadSelected();
    } catch (error) {
      if (!_disposed) emit(state.copyWith(error: error.toString()));
    }
  }

  Future<void> deletePlaylist(int playlistId) async {
    try {
      await _dao.deletePlaylist(playlistId);
      if (_selectedId == playlistId) closePlaylist();
      await load();
    } catch (error) {
      if (!_disposed) emit(state.copyWith(error: error.toString()));
    }
  }

  Future<void> setPinned(int playlistId, bool pinned) async {
    try {
      await _dao.setPinned(playlistId, pinned);
      await load();
    } catch (error) {
      if (!_disposed) emit(state.copyWith(error: error.toString()));
    }
  }

  Future<void> reorderPlaylists(List<int> orderedIds) async {
    try {
      await _dao.reorderPlaylists(orderedIds);
      await load();
    } catch (error) {
      if (!_disposed) emit(state.copyWith(error: error.toString()));
    }
  }

  Future<void> _watchPlaylists() async {
    try {
      final stream = await _dao.watchPlaylists();
      if (_disposed) return;
      _playlistsSubscription = stream.listen((_) => unawaited(load()));
    } catch (error) {
      if (!_disposed) emit(state.copyWith(error: error.toString()));
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _selectedId = null;
    unawaited(_playlistsSubscription?.cancel());
    unawaited(_entriesSubscription?.cancel());
    super.dispose();
  }
}
