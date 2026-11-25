import 'dart:async';

import 'package:fermata/blocs/player/player_cubit.dart';
import 'package:fermata/blocs/search/track_prefix_index.dart';
import 'package:fermata/core/models/exported.dart';
import 'package:rxdart/rxdart.dart';
import 'package:fermata/services/plugin/plugin_service.dart';
import 'package:fermata/src/rust/api/plugin/types.dart';

class SearchState {
  const SearchState({
    this.query = '',
    this.results = const [],
    this.isSearching = false,
    this.error,
  });

  final String query;
  final List<Track> results;
  final bool isSearching;
  final String? error;

  bool get isActive => query.trim().isNotEmpty;
}

class _SearchRequest {
  const _SearchRequest(this.query, this.generation);

  final String query;
  final int generation;
}

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._index, [this._plugins]) : super(const SearchState()) {
    _index.addListener(_onIndexChanged);
    _requestSubscription = _requests.stream
        .debounceTime(const Duration(milliseconds: 120))
        .listen(_onDebouncedRequest);
    unawaited(_index.initialize());
  }

  final TrackSearchIndex _index;
  final PluginService? _plugins;
  String? _resolverId;
  final StreamController<_SearchRequest> _requests = StreamController();
  late final StreamSubscription<_SearchRequest> _requestSubscription;
  int _generation = 0;
  bool _disposed = false;

  void queryChanged(String query) {
    final generation = ++_generation;
    emit(
      query.trim().isEmpty
          ? const SearchState()
          : SearchState(query: query, isSearching: true),
    );
    _requests.add(_SearchRequest(query, generation));
  }

  void clear() => queryChanged('');

  void _onDebouncedRequest(_SearchRequest request) {
    if (_disposed || request.generation != _generation) return;
    unawaited(_execute(request.query, request.generation));
  }

  void _onIndexChanged() {
    if (_disposed || !state.isActive) return;
    final generation = ++_generation;
    emit(SearchState(query: state.query, isSearching: true));
    unawaited(_execute(state.query, generation));
  }

  Future<void> _execute(String query, int generation) async {
    if (_disposed || generation != _generation) return;
    if (query.trim().isEmpty) {
      emit(const SearchState());
      return;
    }
    final plugins = _plugins;
    final onlineFuture = plugins == null
        ? Future<List<Track>>.value(const [])
        : _searchOnline(query);
    List<Track> local;
    try {
      local = await _index.search(query);
    } catch (error) {
      if (_disposed || generation != _generation) return;
      emit(SearchState(query: query, error: error.toString()));
      return;
    }
    if (_disposed || generation != _generation) return;
    emit(SearchState(
      query: query,
      results: List<Track>.unmodifiable(local),
      isSearching: plugins != null,
    ));
    final online = await onlineFuture;
    if (_disposed || generation != _generation) return;
    final merged = <String, Track>{
      for (final track in local) track.id: track,
      for (final track in online) track.id: track,
    };
    emit(SearchState(
      query: query,
      results: List<Track>.unmodifiable(merged.values),
    ));
  }

  Future<List<Track>> _searchOnline(String query) async {
    final plugins = _plugins;
    if (plugins == null) return const [];
    try {
      final resolverId = await _resolver(plugins);
      if (resolverId == null) return const [];
      return await plugins.search(resolverId, query);
    } catch (_) {
      return const [];
    }
  }

  Future<String?> _resolver(PluginService plugins) async {
    final cached = _resolverId;
    if (cached != null) return cached;
    final resolver = (await plugins.available()).where(
      (plugin) => plugin.pluginType == PluginType.contentResolver,
    );
    if (resolver.isEmpty) return null;
    return _resolverId = resolver.first.manifest.id;
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _generation++;
    _index.removeListener(_onIndexChanged);
    unawaited(_requestSubscription.cancel());
    unawaited(_requests.close());
    _index.dispose();
    super.dispose();
  }
}
