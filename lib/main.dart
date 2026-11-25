// ignore_for_file: deprecated_member_use
import 'dart:developer';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:fermata/blocs/downloader/downloader_cubit.dart';
import 'package:fermata/blocs/home/home_cubit.dart';
import 'package:fermata/blocs/layout/layout_cubit.dart';
import 'package:fermata/blocs/player/player_cubit.dart';
import 'package:fermata/blocs/playlists/playlists_cubit.dart';
import 'package:fermata/blocs/search/search_cubit.dart';
import 'package:fermata/blocs/search/track_prefix_index.dart';
import 'package:fermata/blocs/settings/settings_cubit.dart';
import 'package:fermata/core/di/service_locator.dart';
import 'package:fermata/core/theme/luma_theme.dart';
import 'package:fermata/screens/shell_screen.dart';
import 'package:fermata/services/cache/media_cache_service.dart';
import 'package:fermata/services/db/dao/download_dao.dart';
import 'package:fermata/services/db/dao/history_dao.dart';
import 'package:fermata/services/db/dao/playlist_dao.dart';
import 'package:fermata/services/db/dao/settings_dao.dart';
import 'package:fermata/services/db/dao/track_dao.dart';
import 'package:fermata/services/db/db_provider.dart';
import 'package:fermata/services/discord/discord_presence_service.dart';
import 'package:fermata/services/desktop/desktop_activation_service.dart';
import 'package:fermata/services/desktop/discord_service.dart';
import 'package:fermata/services/desktop/native_picker.dart';
import 'package:fermata/services/desktop/tray_service.dart';
import 'package:fermata/services/desktop/update_service.dart';
import 'package:fermata/services/download/rust_download_service.dart';
import 'package:fermata/services/player/audio_handler.dart';
import 'package:fermata/services/player/audio_preset_service.dart';
import 'package:fermata/services/player/media_resolver_service.dart';
import 'package:fermata/services/plugin/plugin_service.dart';
import 'package:fermata/src/rust/frb_generated.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var showWhenReady = false;
  if (Platform.isLinux) {
    final activation = DesktopActivationService();
    if (!await activation.claim()) {
      try {
        await activation.showExistingInstance();
      } catch (error, stackTrace) {
        log('Unable to activate the existing Luma window: $error',
            name: 'fermata.desktop', error: error, stackTrace: stackTrace);
      }
      await activation.close();
      exit(0);
    }
    ServiceLocator.activation = activation;
    activation.showRequests.listen((_) async {
      final tray = ServiceLocator.tray;
      if (tray == null) {
        showWhenReady = true;
      } else {
        await tray.showWindow();
      }
    });
  }

  await RustLib.init();
  ServiceLocator.nativePicker = const NativePicker();
  ServiceLocator.updateService = const UpdateService();
  MediaKit.ensureInitialized();
  final support = await getApplicationSupportDirectory();
  final documents = await getApplicationDocumentsDirectory();
  await DBProvider.init(
    appSupportPath: support.path,
    appDocumentsPath: documents.path,
  );
  ServiceLocator.settingsDao = SettingsDAO(DBProvider.db);
  final trackDao = TrackDAO(DBProvider.db);
  final historyDao = HistoryDAO(DBProvider.db, trackDao);
  final playlistDao = PlaylistDAO(DBProvider.db, trackDao);
  ServiceLocator.downloads = DownloadDAO(DBProvider.db, trackDao);
  ServiceLocator.mediaCache = MediaCacheService(
    settings: ServiceLocator.settingsDao!,
    downloads: ServiceLocator.downloads!,
    stateDir: support.path,
  );
  await ServiceLocator.mediaCache!
      .enforceCap(await ServiceLocator.mediaCache!.cap());
  ServiceLocator.plugins = PluginService();
  await ServiceLocator.plugins!.initialize();
  ServiceLocator.mediaResolver = MediaResolverService(
    ServiceLocator.plugins,
    cache: ServiceLocator.mediaCache,
  );
  ServiceLocator.playerService = PlayerService(
    resolver: ServiceLocator.mediaResolver,
  );
  ServiceLocator.discordService = DiscordService(
    settings: ServiceLocator.settingsDao!,
  );
  ServiceLocator.audioPresetService = AudioPresetService(
    settings: ServiceLocator.settingsDao!,
    engine: ServiceLocator.playerService.engine,
  );
  await Future.wait([
    ServiceLocator.discordService.initialize(ServiceLocator.playerService),
    ServiceLocator.audioPresetService.initialize(ServiceLocator.playerService),
  ]);
  ServiceLocator.downloadService = RustDownloadService();
  ServiceLocator.downloader = DownloaderCubit(
    plugins: ServiceLocator.plugins!,
    settings: ServiceLocator.settingsDao!,
    downloads: ServiceLocator.downloads!,
    cache: ServiceLocator.mediaCache!,
    service: ServiceLocator.downloadService!,
  );
  ServiceLocator.audioHandler = await AudioService.init(
    builder: () => FermataAudioHandler(ServiceLocator.playerService),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'io.github.hungerg.fermata',
      androidNotificationChannelName: 'Luma',
    ),
  );
  if (Platform.isLinux) {
    final tray = DesktopTrayService(player: ServiceLocator.playerService);
    ServiceLocator.tray = tray;
    await tray.initialize();
    if (showWhenReady) await tray.showWindow();
    final window = WindowManager.instance.getCurrent();
    window?.title = 'Luma';
    window?.isAlwaysOnTop = false;
    window?.show();
    window?.focus();
  }
  final playerCubit = PlayerCubit(
    ServiceLocator.playerService,
    trackDao,
  );
  final settingsCubit = SettingsCubit(
    ServiceLocator.settingsDao!,
    ServiceLocator.playerService,
    ServiceLocator.mediaCache!,
    DiscordPresenceService.instance,
  );
  runApp(
    CubitProvider<SettingsCubit>(
      create: () => settingsCubit,
      child: CubitProvider<SearchCubit>(
        create: () =>
            SearchCubit(TrackPrefixIndex(trackDao), ServiceLocator.plugins),
        child: CubitProvider<PlayerCubit>(
          create: () => playerCubit..loadLibrary(),
          child: CubitProvider<PlaylistsCubit>(
            create: () => PlaylistsCubit(playlistDao),
            child: CubitProvider<HomeCubit>(
              create: () => HomeCubit(
                playerCubit,
                historyDao,
                ServiceLocator.plugins,
              ),
              child: CubitProvider<LayoutCubit>(
                create: () => LayoutCubit(ServiceLocator.settingsDao!)..load(),
                child: AnimatedBuilder(
                  animation: settingsCubit,
                  builder: (context, _) => MaterialApp(
                    title: 'Luma',
                    theme: lumaTheme(settingsCubit.state.themePreset),
                    debugShowCheckedModeBanner: false,
                    home: const ShellScreen(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
