import 'dart:io';

import 'package:fermata/core/models/exported.dart';
import 'package:fermata/services/db/db_provider.dart';
import 'package:fermata/services/db/dao/plugin_storage_dao.dart';
import 'package:fermata/services/plugin/plugin_event_bus.dart';
import 'package:fermata/services/plugin/plugin_storage_service.dart';
import 'package:fermata/services/player/stream_quality_selector.dart';
import 'package:fermata/src/rust/api/bridge.dart' as bridge;
import 'package:fermata/src/rust/api/plugin/commands.dart';
import 'package:fermata/src/rust/api/plugin/plugin.dart';
import 'package:fermata/src/rust/api/plugin/plugin_info.dart';
import 'package:path_provider/path_provider.dart';

class PluginService {
  PluginManager? _manager;
  PluginStorageService? _storage;

  PluginManager get manager {
    final value = _manager;
    if (value == null) throw StateError('PluginService is not initialized');
    return value;
  }

  Future<void> initialize() async {
    if (_manager != null) return;
    final support = await getApplicationSupportDirectory();
    final dir = Directory('${support.path}/plugins');
    await dir.create(recursive: true);
    _manager = await bridge.createPluginManager(pluginsDir: dir.path);
    PluginEventBus.instance.connect(manager);
    _storage = PluginStorageService(
      dao: PluginStorageDao(DBProvider.db),
      eventBus: PluginEventBus.instance,
    )..startListening();
    await _storage!.preloadAll(manager);
    for (final plugin in await available()) {
      await bridge.loadPlugin(
        manager: manager,
        pluginId: plugin.manifest.id,
        pluginType: plugin.pluginType,
      );
    }
  }

  Future<List<PluginInfo>> available() =>
      bridge.getAvailablePlugins(manager: manager);

  Future<void> install(String path) async {
    final temp = await getTemporaryDirectory();
    await bridge.installPackedPlugin(
      packedFilePath: path,
      pluginsDir: await bridge.getPluginsDir(manager: manager),
      tempDir: temp.path,
      shouldLoad: true,
      policyCountryCode: '',
      manager: manager,
    );
  }

  Future<void> delete(PluginInfo plugin) async {
    if (await bridge.isPluginLoaded(
      manager: manager,
      pluginId: plugin.manifest.id,
      pluginType: plugin.pluginType,
    )) {
      await bridge.unloadPlugin(
        manager: manager,
        pluginId: plugin.manifest.id,
        pluginType: plugin.pluginType,
      );
    }
    await Directory(plugin.pluginPath).delete(recursive: true);
    await bridge.refreshAvailablePlugins(manager: manager);
  }

  Future<List<Track>> search(String pluginId, String query) async {
    final response = await bridge.handlePluginRequest(
      manager: manager,
      pluginId: pluginId,
      request: PluginRequest.contentResolver(
        ContentResolverCommand.search(
          query: query,
          filter: ContentSearchFilter.track,
          pageToken: null,
        ),
      ),
    );
    if (response case PluginResponse_Search(:final field0)) {
      return field0.items
          .whereType<MediaItem_Track>()
          .map((item) => item.field0)
          .toList(growable: false);
    }
    return [];
  }

  Future<List<Track>> radioTracks(Track track, {int limit = 25}) async {
    final separator = track.id.indexOf('::');
    if (separator < 1 || track.id.startsWith('local::')) return const [];
    final response = await bridge.handlePluginRequest(
      manager: manager,
      pluginId: track.id.substring(0, separator),
      request: PluginRequest.contentResolver(
        ContentResolverCommand.getRadioTracks(
          id: track.id.substring(separator + 2),
        ),
      ),
    );
    if (response case PluginResponse_MoreTracks(:final field0)) {
      return field0.items.take(limit).toList(growable: false);
    }
    return const [];
  }

  Future<StreamSource?> streams(Track track) async {
    final separator = track.id.indexOf('::');
    if (separator < 1) return null;
    final response = await bridge.handlePluginRequest(
      manager: manager,
      pluginId: track.id.substring(0, separator),
      request: PluginRequest.contentResolver(
        ContentResolverCommand.getStreams(
          id: track.id.substring(separator + 2),
        ),
      ),
    );
    if (response case PluginResponse_Streams(:final field0)) {
      return StreamQualitySelector.selectPlaybackStream(
        field0,
        preference: AudioStreamQualityPreference.high,
      );
    }
    return null;
  }
}
