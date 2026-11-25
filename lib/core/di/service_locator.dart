import 'package:audio_service/audio_service.dart';
import 'package:fermata/blocs/downloader/downloader_cubit.dart';
import 'package:fermata/blocs/player/player_cubit.dart';
import 'package:fermata/services/cache/media_cache_service.dart';
import 'package:fermata/services/db/dao/download_dao.dart';
import 'package:fermata/services/db/dao/settings_dao.dart';
import 'package:fermata/services/desktop/desktop_activation_service.dart';
import 'package:fermata/services/desktop/discord_service.dart';
import 'package:fermata/services/desktop/native_picker.dart';
import 'package:fermata/services/desktop/tray_service.dart';
import 'package:fermata/services/desktop/update_service.dart';
import 'package:fermata/services/download/rust_download_service.dart';
import 'package:fermata/services/player/audio_preset_service.dart';
import 'package:fermata/services/player/media_resolver_service.dart';
import 'package:fermata/services/plugin/plugin_service.dart';

class ServiceLocator {
  static late PlayerService playerService;
  static PluginService? plugins;
  static SettingsDAO? settingsDao;
  static MediaResolverService? mediaResolver;
  static MediaCacheService? mediaCache;
  static DownloadDAO? downloads;
  static RustDownloadService? downloadService;
  static DownloaderCubit? downloader;
  static BaseAudioHandler? audioHandler;
  static DesktopActivationService? activation;
  static DesktopTrayService? tray;
  static late NativePicker nativePicker;
  static late UpdateService updateService;
  static late DiscordService discordService;
  static late AudioPresetService audioPresetService;
}
