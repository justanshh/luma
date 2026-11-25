import 'dart:async';

import 'package:fermata/blocs/player/player_cubit.dart';
import 'package:fermata/core/models/exported.dart';
import 'package:fermata/core/models/playback_history_entry.dart';
import 'package:fermata/services/db/dao/history_dao.dart';
import 'package:fermata/services/plugin/plugin_service.dart';

class HomeState {
  const HomeState({
    this.recents = const [],
    this.suggestions = const [],
    this.loading = false,
    this.loadingSuggestions = false,
    this.suggestionSeedId,
    this.error,
  });

  final List<PlaybackHistoryEntry> recents;
  final List<Track> suggestions;
  final bool loading;
  final bool loadingSuggestions;
  final String? suggestionSeedId;
  final String? error;

  HomeState copyWith({
    List<PlaybackHistoryEntry>? recents,
    List<Track>? suggestions,
    bool? loading,
    bool? loadingSuggestions,
    String? suggestionSeedId,
    String? error,
    bool clearError = false,
  }) {
    return HomeState(
      recents: recents ?? this.recents,
      suggestions: suggestions ?? this.suggestions,
      loading: loading ?? this.loading,
      loadingSuggestions: loadingSuggestions ?? this.loadingSuggestions,
      suggestionSeedId: suggestionSeedId ?? this.suggestionSeedId,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(
    this._player,
    this._history,
    this._plugins,
  ) : super(const HomeState()) {
    _player.addListener(_onPlayerChanged);
    unawaited(refresh());
    _onPlayerChanged();
  }

  final PlayerCubit _player;
  final HistoryDAO _history;
  final PluginService? _plugins;
  String? _lastCurrentId;
  String? _recordingId;
  int _suggestionGeneration = 0;
  bool _disposed = false;

  Future<void> refresh() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final recents = await _history.getHistory();
      if (_disposed) return;
      emit(state.copyWith(recents: recents, loading: false));
      await refreshSuggestions();
    } catch (error) {
      if (_disposed) return;
      emit(state.copyWith(loading: false, error: error.toString()));
    }
  }

  Future<void> refreshSuggestions({Track? seed}) async {
    final generation = ++_suggestionGeneration;
    final recent = state.recents.isEmpty ? null : state.recents.first.track;
    final source = seed ?? recent ?? _player.state.current;
    if (source == null) {
      emit(state.copyWith(
        suggestions: const [],
        loadingSuggestions: false,
        suggestionSeedId: null,
        clearError: true,
      ));
      return;
    }
    emit(state.copyWith(
      loadingSuggestions: true,
      suggestionSeedId: source.id,
      clearError: true,
    ));
    final plugins = _plugins;
    if (plugins == null) {
      emit(state.copyWith(
        suggestions: const [],
        loadingSuggestions: false,
        error: 'Install a content plugin to get suggestions.',
      ));
      return;
    }
    if (source.id.startsWith('local::')) {
      emit(state.copyWith(
        suggestions: const [],
        loadingSuggestions: false,
        error: 'Play an online track to get radio suggestions.',
      ));
      return;
    }
    try {
      final tracks = await plugins.radioTracks(source);
      if (_disposed || generation != _suggestionGeneration) return;
      final seen = <String>{source.id};
      final unique = tracks.where((track) => seen.add(track.id)).toList();
      emit(state.copyWith(
        suggestions: List.unmodifiable(unique),
        loadingSuggestions: false,
      ));
    } catch (error) {
      if (_disposed || generation != _suggestionGeneration) return;
      emit(state.copyWith(
        suggestions: const [],
        loadingSuggestions: false,
        error: 'Suggestions are unavailable right now.',
      ));
    }
  }

  Future<void> clearRecents() async {
    await _history.clearHistory();
    if (_disposed) return;
    emit(state.copyWith(recents: const []));
    await refreshSuggestions();
  }

  void _onPlayerChanged() {
    final current = _player.state.current;
    if (current?.id != _lastCurrentId) {
      _lastCurrentId = current?.id;
      _recordingId = null;
    }
    if (!_player.state.playing ||
        current == null ||
        _recordingId == current.id) {
      return;
    }
    _recordingId = current.id;
    unawaited(_recordAndRefresh(current));
  }

  Future<void> _recordAndRefresh(Track track) async {
    try {
      await _history.recordPlay(track);
      if (_disposed) return;
      final recents = await _history.getHistory();
      if (_disposed) return;
      emit(state.copyWith(recents: recents));
      await refreshSuggestions(seed: track);
    } catch (error) {
      if (_disposed) return;
      emit(state.copyWith(error: error.toString()));
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _suggestionGeneration++;
    _player.removeListener(_onPlayerChanged);
    super.dispose();
  }
}
