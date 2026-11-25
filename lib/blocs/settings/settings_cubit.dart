import 'dart:async';

import 'package:fermata/blocs/player/player_cubit.dart';
import 'package:fermata/core/constants/luma_settings.dart';
import 'package:fermata/core/di/service_locator.dart';
import 'package:fermata/services/cache/media_cache_service.dart';
import 'package:fermata/services/db/dao/settings_dao.dart';
import 'package:fermata/services/discord/discord_presence_service.dart';
import 'package:fermata/services/player/audio_preset_service.dart';

class SettingsState {
  const SettingsState({
    this.themePreset = LumaThemePreset.auto,
    this.equalizerPreset = LumaEqualizerPreset.auto,
    this.discordEnabled = true,
    this.closeToTray = false,
    this.cacheBytes = 0,
    this.loaded = false,
    this.loading = false,
    this.clearingCache = false,
    this.discordStatus,
    this.error,
  });

  final LumaThemePreset themePreset;
  final LumaEqualizerPreset equalizerPreset;
  final bool discordEnabled;
  final bool closeToTray;
  final int cacheBytes;
  final bool loaded;
  final bool loading;
  final bool clearingCache;
  final String? discordStatus;
  final String? error;

  SettingsState copyWith({
    LumaThemePreset? themePreset,
    LumaEqualizerPreset? equalizerPreset,
    bool? discordEnabled,
    bool? closeToTray,
    int? cacheBytes,
    bool? loaded,
    bool? loading,
    bool? clearingCache,
    String? discordStatus,
    String? error,
    bool clearError = false,
    bool clearDiscordStatus = false,
  }) {
    return SettingsState(
      themePreset: themePreset ?? this.themePreset,
      equalizerPreset: equalizerPreset ?? this.equalizerPreset,
      discordEnabled: discordEnabled ?? this.discordEnabled,
      closeToTray: closeToTray ?? this.closeToTray,
      cacheBytes: cacheBytes ?? this.cacheBytes,
      loaded: loaded ?? this.loaded,
      loading: loading ?? this.loading,
      clearingCache: clearingCache ?? this.clearingCache,
      discordStatus:
          clearDiscordStatus ? null : (discordStatus ?? this.discordStatus),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(
    this._settings,
    PlayerService _,
    this._cache,
    this._discord,
  ) : super(const SettingsState()) {
    _discord.statusMessage.addListener(_onDiscordStatus);
    unawaited(load());
  }

  final SettingsDAO _settings;
  final MediaCacheService _cache;
  final DiscordPresenceService _discord;
  bool _disposed = false;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final themeValue = await _settings.getSettingStr(
        LumaSettingsKeys.themePreset,
      );
      final eqValue = await _settings.getSettingStr(
        LumaSettingsKeys.equalizerPreset,
      );
      final discord = await _settings.getSettingBool(
        LumaSettingsKeys.discordEnabled,
        defaultValue: true,
      );
      final closeToTray = await _settings.getSettingBool(
        LumaSettingsKeys.closeToTray,
        defaultValue: false,
      );
      final cacheBytes = await _cache.usage();
      if (_disposed) return;
      final themePreset = LumaThemePreset.fromStorage(themeValue);
      final equalizerPreset = LumaEqualizerPreset.fromStorage(eqValue);
      emit(state.copyWith(
        themePreset: themePreset,
        equalizerPreset: equalizerPreset,
        discordEnabled: discord ?? true,
        closeToTray: closeToTray ?? false,
        cacheBytes: cacheBytes,
        loaded: true,
        loading: false,
      ));
      await _applyEqualizer(equalizerPreset);
      if (discord == true) await _discord.setEnabled(true);
    } catch (error) {
      if (!_disposed) {
        emit(state.copyWith(loading: false, error: error.toString()));
      }
    }
  }

  Future<void> setThemePreset(LumaThemePreset preset) async {
    emit(state.copyWith(themePreset: preset, clearError: true));
    try {
      await _settings.putSettingStr(
        LumaSettingsKeys.themePreset,
        preset.storageValue,
      );
    } catch (error) {
      if (!_disposed) emit(state.copyWith(error: error.toString()));
    }
  }

  Future<void> setEqualizerPreset(LumaEqualizerPreset preset) async {
    emit(state.copyWith(equalizerPreset: preset, clearError: true));
    try {
      await _settings.putSettingStr(
        LumaSettingsKeys.equalizerPreset,
        preset.storageValue,
      );
      await _applyEqualizer(preset);
    } catch (error) {
      if (!_disposed) emit(state.copyWith(error: error.toString()));
    }
  }

  Future<void> _applyEqualizer(LumaEqualizerPreset preset) async {
    await ServiceLocator.audioPresetService.applyPreset(
      switch (preset) {
        LumaEqualizerPreset.auto => AudioPreset.auto,
        LumaEqualizerPreset.balanced => AudioPreset.balanced,
        LumaEqualizerPreset.bass => AudioPreset.bass,
        LumaEqualizerPreset.vocal => AudioPreset.vocal,
        LumaEqualizerPreset.clear => AudioPreset.clear,
      },
      persist: false,
    );
  }

  Future<void> setDiscordEnabled(bool enabled) async {
    emit(state.copyWith(discordEnabled: enabled, clearError: true));
    try {
      await _settings.putSettingBool(LumaSettingsKeys.discordEnabled, enabled);
      await _discord.setEnabled(enabled);
    } catch (error) {
      if (!_disposed) emit(state.copyWith(error: error.toString()));
    }
  }

  Future<void> setCloseToTray(bool enabled) async {
    emit(state.copyWith(closeToTray: enabled, clearError: true));
    try {
      await _settings.putSettingBool(LumaSettingsKeys.closeToTray, enabled);
    } catch (error) {
      if (!_disposed) emit(state.copyWith(error: error.toString()));
    }
  }

  Future<void> clearCache() async {
    if (state.clearingCache) return;
    emit(state.copyWith(clearingCache: true, clearError: true));
    try {
      await _cache.clear();
      final usage = await _cache.usage();
      if (!_disposed) {
        emit(state.copyWith(cacheBytes: usage, clearingCache: false));
      }
    } catch (error) {
      if (!_disposed) {
        emit(state.copyWith(clearingCache: false, error: error.toString()));
      }
    }
  }

  void _onDiscordStatus() {
    if (_disposed) return;
    final message = _discord.statusMessage.value;
    emit(state.copyWith(
      discordStatus: message,
      clearDiscordStatus: message == null,
    ));
  }

  @override
  void dispose() {
    _disposed = true;
    _discord.statusMessage.removeListener(_onDiscordStatus);
    super.dispose();
  }
}
