import 'dart:async';

import 'package:fermata/blocs/player/player_cubit.dart';
import 'package:fermata/core/models/exported.dart';
import 'package:fermata/services/cache/media_cache_service.dart';
import 'package:fermata/services/db/dao/download_dao.dart';
import 'package:fermata/services/db/dao/settings_dao.dart';
import 'package:fermata/services/download/rust_download_service.dart';
import 'package:fermata/services/plugin/plugin_service.dart';
import 'package:fermata/src/rust/api/downloader/types.dart';

class DownloaderState {
  const DownloaderState({this.tasks = const [], this.error});

  final List<DownloadTaskSnapshot> tasks;
  final String? error;
}

class DownloaderCubit extends Cubit<DownloaderState> {
  DownloaderCubit({
    required PluginService plugins,
    required SettingsDAO settings,
    required DownloadDAO downloads,
    required MediaCacheService cache,
    required RustDownloadService service,
  })  : _plugins = plugins,
        _settings = settings,
        _downloads = downloads,
        _cache = cache,
        _service = service,
        super(const DownloaderState()) {
    unawaited(_initialize());
  }

  final PluginService _plugins;
  final SettingsDAO _settings;
  final DownloadDAO _downloads;
  final MediaCacheService _cache;
  final RustDownloadService _service;
  StreamSubscription<DownloadManagerEvent>? _subscription;
  Future<void>? _initializing;

  Future<void> _initialize() {
    final inFlight = _initializing;
    if (inFlight != null) return inFlight;
    final future = _start();
    _initializing = future;
    return future.whenComplete(() => _initializing = null);
  }

  Future<void> _start() async {
    await _plugins.initialize();
    await _service.initialize(
      pluginManager: _plugins.manager,
      stateDir: '${_cache.stateDir}/download_manager',
      tempDir: '${_cache.stateDir}/download_temp',
    );
    _subscription = _service.events.listen(_onEvent);
    final restored = await _service.restoreTasks();
    emit(DownloaderState(tasks: restored));
  }

  void _onEvent(DownloadManagerEvent event) {
    switch (event) {
      case DownloadManagerEvent_TaskUpdated(:final field0):
        _upsert(field0);
      case DownloadManagerEvent_TaskCompletedPendingAck(:final field0):
        _upsert(field0);
        unawaited(_persist(field0));
      case DownloadManagerEvent_TaskRemoved(:final taskId):
        emit(DownloaderState(
          tasks: state.tasks.where((task) => task.taskId != taskId).toList(),
        ));
      case DownloadManagerEvent_RecoverySummary():
        break;
    }
  }

  void _upsert(DownloadTaskSnapshot snapshot) {
    final tasks = state.tasks.toList()
      ..removeWhere((task) => task.taskId == snapshot.taskId)
      ..insert(0, snapshot);
    emit(DownloaderState(tasks: tasks));
  }

  Future<void> _persist(DownloadTaskSnapshot snapshot) async {
    try {
      await _cache.store(
        track: snapshot.track,
        sourcePath: snapshot.targetPath,
        fileName: snapshot.fileName,
      );
      await _service.acknowledgePersisted(snapshot.taskId);
    } catch (error) {
      emit(DownloaderState(tasks: state.tasks, error: error.toString()));
    }
  }

  Future<void> download(Track track) async {
    try {
      await _initialize();
      final quality = await _settings.getSettingStr(
        'download.quality',
        defaultValue: 'High',
      );
      await _service.enqueue(
          request: EnqueueDownloadRequest(
        track: track,
        downloadDir: _cache.directory.path,
        preferredQuality: quality ?? 'High',
      ));
    } catch (error) {
      emit(DownloaderState(tasks: state.tasks, error: error.toString()));
    }
  }

  Future<void> cancel(String taskId) => _service.cancel(taskId);

  Future<void> remove(Track track) => _downloads.remove(track.id);

  Future<bool> isDownloaded(String mediaId) async =>
      (await _downloads.getDownload(mediaId)) != null;

  Future<void> refresh() async {
    final downloads = await _downloads.getAllDownloads();
    emit(DownloaderState(
      tasks: state.tasks,
      error: state.error,
    ));
    if (downloads.isNotEmpty) {
      await _cache.enforceCap(await _cache.cap());
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel() ?? Future<void>.value());
    super.dispose();
  }
}
