import 'dart:async';

import 'package:fermata/src/rust/api/bridge.dart' as bridge;
import 'package:fermata/src/rust/api/downloader.dart';
import 'package:fermata/src/rust/api/downloader/types.dart';
import 'package:fermata/src/rust/api/plugin/plugin.dart';

class RustDownloadService {
  DownloadManager? _manager;
  Future<void>? _initializing;
  StreamSubscription<DownloadManagerEvent>? _eventSubscription;
  final StreamController<DownloadManagerEvent> _events =
      StreamController<DownloadManagerEvent>.broadcast();

  bool get isInitialized => _manager != null;

  DownloadManager get manager {
    final value = _manager;
    if (value == null) {
      throw StateError('RustDownloadService is not initialized');
    }
    return value;
  }

  Stream<DownloadManagerEvent> get events => _events.stream;

  Future<void> initialize({
    required PluginManager pluginManager,
    required String stateDir,
    required String tempDir,
    int maxConcurrentTasks = 2,
  }) async {
    if (_manager != null) return;
    final inFlight = _initializing;
    if (inFlight != null) return inFlight;
    final future = _initialize(
      pluginManager: pluginManager,
      stateDir: stateDir,
      tempDir: tempDir,
      maxConcurrentTasks: maxConcurrentTasks,
    );
    _initializing = future;
    try {
      await future;
    } finally {
      if (identical(_initializing, future)) _initializing = null;
    }
  }

  Future<void> _initialize({
    required PluginManager pluginManager,
    required String stateDir,
    required String tempDir,
    required int maxConcurrentTasks,
  }) async {
    final value = await bridge.createDownloadManager(
      pluginManager: pluginManager,
      stateDir: stateDir,
      tempDir: tempDir,
      maxConcurrentTasks: maxConcurrentTasks,
    );
    _manager = value;
    _eventSubscription = bridge.initDownloadEventStream(manager: value).listen(
          _events.add,
          onError: _events.addError,
        );
  }

  Future<List<DownloadTaskSnapshot>> restoreTasks() =>
      bridge.restoreDownloadTasks(manager: manager);

  Future<List<DownloadTaskSnapshot>> getSnapshots() =>
      bridge.getDownloadTaskSnapshots(manager: manager);

  Future<String> enqueue({required EnqueueDownloadRequest request}) =>
      bridge.enqueueDownloadTask(manager: manager, request: request);

  Future<bool> pause(String taskId) =>
      bridge.pauseDownloadTask(manager: manager, taskId: taskId);

  Future<bool> resume(String taskId) =>
      bridge.resumeDownloadTask(manager: manager, taskId: taskId);

  Future<bool> cancel(String taskId, {bool deletePartial = true}) =>
      bridge.cancelDownloadTask(
        manager: manager,
        taskId: taskId,
        deletePartial: deletePartial,
      );

  Future<bool> acknowledgePersisted(String taskId) =>
      bridge.acknowledgeDownloadPersisted(manager: manager, taskId: taskId);

  Future<void> dispose() async {
    await _eventSubscription?.cancel();
    _eventSubscription = null;
    _initializing = null;
    await _events.close();
    _manager = null;
  }
}
