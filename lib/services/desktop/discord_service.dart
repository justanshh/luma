import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:fermata/blocs/player/player_cubit.dart';
import 'package:fermata/services/db/dao/settings_dao.dart';
import 'package:fermata/services/player/player_engine.dart';
import 'package:fermata/src/rust/api/discord.dart';

/// Publishes Fermata playback to Discord through the existing Rust IPC worker.
class DiscordService {
  DiscordService({
    required SettingsDAO settings,
    this.clearPresenceWhenPaused = true,
  }) : _settings = settings;

  /// Bloomee's Discord application, reused so existing artwork assets and
  /// application setup continue to work.
  static const clientId = '1512528534667661443';
  static const enabledSettingKey = 'discord.enabled';

  static const _progressRefreshInterval = Duration(seconds: 10);
  static const _seekThreshold = Duration(seconds: 2);

  final SettingsDAO _settings;

  PlayerService? _player;
  Future<void>? _initialization;
  bool _initialized = false;
  bool _disposed = false;
  bool _enabled = true;
  bool _started = false;
  bool _visible = false;

  Object? _lastSignature;
  Duration? _lastObservedPosition;
  DateTime? _lastPublishedAt;

  /// When true, pausing removes the activity. When false, the track remains
  /// visible without a progress bar. Stopping always clears the activity.
  bool clearPresenceWhenPaused;

  bool get enabled => _enabled;
  bool get isDesktop =>
      Platform.isLinux || Platform.isMacOS || Platform.isWindows;

  /// Restores the persisted preference and starts following [player].
  /// Calling this more than once returns the same initialization.
  Future<void> initialize(PlayerService player) {
    if (_disposed) return Future<void>.value();
    return _initialization ??= _initialize(player);
  }

  Future<void> _initialize(PlayerService player) async {
    try {
      _enabled = await _settings.getSettingBool(
            enabledSettingKey,
            defaultValue: true,
          ) ??
          true;
    } catch (error, stackTrace) {
      log('Unable to restore Discord presence preference',
          name: 'fermata.discord', error: error, stackTrace: stackTrace);
    }
    if (_disposed) return;

    _player = player;
    player.addListener(_onPlayerChanged);
    _initialized = true;
    if (_enabled && isDesktop) _start();
    _onPlayerChanged();
  }

  /// Enables or disables presence and persists `discord.enabled`.
  Future<void> setEnabled(bool enabled) async {
    if (_disposed) return;
    _enabled = enabled;
    if (enabled) {
      if (isDesktop) _start();
    } else {
      _clearPresence();
    }
    update();
    try {
      await _settings.putSettingBool(enabledSettingKey, enabled);
    } catch (error, stackTrace) {
      log('Unable to save Discord presence preference',
          name: 'fermata.discord', error: error, stackTrace: stackTrace);
    }
  }

  /// Changes pause behavior and immediately republishes the current track.
  void setClearPresenceWhenPaused(bool clear) {
    if (_disposed || clearPresenceWhenPaused == clear) return;
    clearPresenceWhenPaused = clear;
    update();
  }

  /// Forces a presence refresh from the current [PlayerService] snapshot.
  void update() {
    if (!_initialized || _disposed) return;
    _onPlayerChanged();
  }

  void _onPlayerChanged() {
    final player = _player;
    if (player == null ||
        !_initialized ||
        _disposed ||
        !_enabled ||
        !_started ||
        !isDesktop) {
      return;
    }

    final track = player.current;
    if (track == null) {
      _clearPresence();
      return;
    }

    final position = player.position;
    final jumped = _lastObservedPosition != null &&
        (position - _lastObservedPosition!).abs() >= _seekThreshold;
    _lastObservedPosition = position;

    if (!player.playing &&
        (clearPresenceWhenPaused ||
            player.engine.state == EngineState.idle ||
            player.engine.state == EngineState.completed)) {
      _clearPresence();
      return;
    }

    final title = track.title.trim().isEmpty ? 'Unknown title' : track.title;
    final artistNames = track.artists
        .map((artist) => artist.name.trim())
        .where((name) => name.isNotEmpty)
        .join(', ');
    final artist = artistNames.isEmpty ? 'Unknown artist' : artistNames;
    final artwork = track.thumbnail;
    final image = _httpsUrl(artwork.urlHigh) ??
        _httpsUrl(artwork.url) ??
        _httpsUrl(artwork.urlLow);
    final link = _webUrl(track.url);
    final artistLink = track.artists
        .map((item) => _webUrl(item.url))
        .whereType<String>()
        .firstOrNull;
    final durationMs = _boundedMilliseconds(player.duration);
    final activity = DiscordActivity(
      kind: DiscordActivityKind.listening,
      statusDisplay: DiscordStatusDisplay.state,
      details: title,
      detailsUrl: link,
      state: artist,
      stateUrl: artistLink,
      largeImage: image,
      largeText: track.album?.title ?? artist,
      largeUrl: link,
      progress: player.playing
          ? DiscordProgress(
              positionMs: _boundedMilliseconds(position),
              durationMs: durationMs > 0 ? durationMs : null,
            )
          : null,
      buttons: const [],
    );
    final signature = (
      track.id,
      title,
      artist,
      image,
      link,
      artistLink,
      track.album?.title,
      player.playing,
      durationMs,
    );
    final now = DateTime.now();
    final refreshDue = player.playing &&
        (_lastPublishedAt == null ||
            now.difference(_lastPublishedAt!) >= _progressRefreshInterval);

    // Discord advances its own progress bar. Avoid sending on every position
    // notification, but refresh after seeks and periodically for clock drift.
    if (_visible && signature == _lastSignature && !jumped && !refreshDue) {
      return;
    }

    if (_send(activity)) {
      _lastSignature = signature;
      _lastPublishedAt = now;
      _lastObservedPosition = position;
      _visible = true;
    }
  }

  void _start() {
    if (!isDesktop || _started || _disposed) return;
    try {
      discordStart(clientId: clientId);
      _started = true;
    } catch (error, stackTrace) {
      log('Unable to start Discord presence',
          name: 'fermata.discord', error: error, stackTrace: stackTrace);
    }
  }

  void _clearPresence() {
    _lastSignature = null;
    _lastObservedPosition = null;
    _lastPublishedAt = null;
    if (!_visible) return;
    if (_send(null)) _visible = false;
  }

  bool _send(DiscordActivity? activity) {
    if (!_started || !isDesktop || _disposed) return false;
    try {
      discordSetActivity(activity: activity);
      return true;
    } catch (error, stackTrace) {
      log('Unable to update Discord presence',
          name: 'fermata.discord', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _player?.removeListener(_onPlayerChanged);
    _player = null;
    _lastSignature = null;
    _lastObservedPosition = null;
    _lastPublishedAt = null;
    if (_started) {
      try {
        discordStop();
      } catch (error, stackTrace) {
        log('Unable to stop Discord presence',
            name: 'fermata.discord', error: error, stackTrace: stackTrace);
      }
    }
    _started = false;
    _visible = false;
  }
}

int _boundedMilliseconds(Duration duration) =>
    duration.inMilliseconds.clamp(0, 0xFFFFFFFF).toInt();

String? _httpsUrl(String? value) {
  final uri = value == null ? null : Uri.tryParse(value.trim());
  if (uri == null || uri.scheme != 'https' || !uri.hasAuthority) return null;
  return uri.toString();
}

String? _webUrl(String? value) {
  final uri = value == null ? null : Uri.tryParse(value.trim());
  if (uri == null ||
      (uri.scheme != 'https' && uri.scheme != 'http') ||
      !uri.hasAuthority) {
    return null;
  }
  return uri.toString();
}
