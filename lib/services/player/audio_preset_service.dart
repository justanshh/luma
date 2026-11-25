import 'dart:async';
import 'dart:developer';

import 'package:fermata/blocs/player/player_cubit.dart';
import 'package:fermata/core/models/exported.dart';
import 'package:fermata/services/db/dao/settings_dao.dart';
import 'package:fermata/services/player/player_engine.dart';

/// Selectable ten-band EQ curves for [PlayerEngine].
enum AudioPreset {
  auto,
  balanced,
  bass,
  vocal,
  clear;

  String get storageValue => name;

  /// Gains follow the engine's 32, 64, 125, 250, 500, 1k, 2k, 4k, 8k and
  /// 16k bands. Auto resolves to one of the other curves per track.
  List<double> get bandGains => List.unmodifiable(switch (this) {
        AudioPreset.auto => AudioPreset.balanced.bandGains,
        AudioPreset.balanced => _balanced,
        AudioPreset.bass => _bass,
        AudioPreset.vocal => _vocal,
        AudioPreset.clear => _clear,
      });

  static const _balanced = <double>[
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
  ];
  static const _bass = <double>[
    7.0,
    6.0,
    4.0,
    2.0,
    0.0,
    -1.0,
    -1.0,
    0.0,
    1.0,
    1.0,
  ];
  static const _vocal = <double>[
    -2.0,
    -1.0,
    0.0,
    2.0,
    4.0,
    4.0,
    3.0,
    1.0,
    0.0,
    -1.0,
  ];
  static const _clear = <double>[
    2.0,
    1.0,
    0.0,
    -1.0,
    -2.0,
    -1.0,
    1.0,
    3.0,
    5.0,
    4.0,
  ];
}

/// Applies and persists automatic or manually selected EQ presets.
class AudioPresetService {
  AudioPresetService({
    required SettingsDAO settings,
    required PlayerEngine engine,
  })  : _settings = settings,
        _engine = engine;

  static const settingKey = 'audio.preset';
  static const _disabledValue = 'off';

  static const _autoKeywords = <AudioPreset, Set<String>>{
    AudioPreset.bass: {
      'bass',
      'bassboost',
      'bass boost',
      'edm',
      'electronic',
      'dance',
      'house',
      'techno',
      'trance',
      'dubstep',
      'drum',
      'drums',
      'percussion',
      'hiphop',
      'hip hop',
      'rap',
      'trap',
      'phonk',
      'club',
      'party',
      'disco',
    },
    AudioPreset.vocal: {
      'vocal',
      'vocals',
      'singer',
      'acoustic',
      'unplugged',
      'live',
      'ballad',
      'soul',
      'rnb',
      'r b',
      'jazz',
      'blues',
      'folk',
      'country',
      'choir',
      'choral',
      'spoken',
      'poetry',
      'indie',
    },
    AudioPreset.clear: {
      'classical',
      'piano',
      'instrumental',
      'orchestra',
      'orchestral',
      'symphonic',
      'symphony',
      'cinematic',
      'ambient',
      'meditation',
      'focus',
      'study',
      'lofi',
      'lo fi',
      'harp',
      'violin',
      'cello',
      'string',
      'strings',
      'audiophile',
    },
  };

  final SettingsDAO _settings;
  final PlayerEngine _engine;

  PlayerService? _player;
  Track? _track;
  Object? _trackSignature;
  Future<void>? _initialization;
  Future<void> _applyQueue = Future<void>.value();
  int _applyGeneration = 0;
  bool _disposed = false;
  bool _enabled = true;
  AudioPreset _preset = AudioPreset.auto;

  bool get enabled => _enabled;
  AudioPreset get preset => _preset;
  AudioPreset get effectivePreset {
    if (_preset != AudioPreset.auto) return _preset;
    return presetForMetadata(
      title: _track?.title ?? '',
      artist: _track?.artists.map((item) => item.name).join(', ') ?? '',
    );
  }

  /// Restores `audio.preset` and follows [player] while Auto is selected.
  /// Calling this more than once returns the same initialization.
  Future<void> initialize(PlayerService player) {
    if (_disposed) return Future<void>.value();
    return _initialization ??= _initialize(player);
  }

  Future<void> _initialize(PlayerService player) async {
    try {
      final stored = await _settings.getSettingStr(settingKey);
      if (stored != null && stored.trim().isNotEmpty) {
        final value = stored.trim().toLowerCase();
        if (value == _disabledValue) {
          _enabled = false;
        } else {
          final restored = AudioPreset.values
              .where((preset) => preset.storageValue == value)
              .firstOrNull;
          if (restored != null) {
            _preset = restored;
            _enabled = true;
          }
        }
      }
    } catch (error, stackTrace) {
      log('Unable to restore audio EQ preference',
          name: 'fermata.audio', error: error, stackTrace: stackTrace);
    }
    if (_disposed) return;

    _player = player;
    _track = player.current;
    _trackSignature = _metadataSignature(_track);
    player.addListener(_onPlayerChanged);
    await _requestApply();
  }

  /// Selects a preset, enables the EQ and persists `audio.preset`.
  Future<void> applyPreset(AudioPreset preset, {bool persist = true}) async {
    if (_disposed) return;
    _preset = preset;
    _enabled = true;
    _track = _player?.current;
    _trackSignature = _metadataSignature(_track);
    await _requestApply();
    if (persist) await _persist();
  }

  /// Disables the EQ, or re-enables the selected preset. The disabled state is
  /// stored as `audio.preset=off`, so no additional settings key is required.
  Future<void> setEnabled(bool enabled, {bool persist = true}) async {
    if (_disposed) return;
    _enabled = enabled;
    _track = _player?.current;
    _trackSignature = _metadataSignature(_track);
    await _requestApply();
    if (persist) await _persist();
  }

  /// Applies the current selection immediately. Without [track], the current
  /// player track is used for Auto.
  Future<void> update({Track? track}) async {
    if (_disposed) return;
    _track = track ?? _player?.current;
    _trackSignature = _metadataSignature(_track);
    if (_enabled) await _requestApply();
  }

  /// Resolves Auto from normalized title and artist keywords. Unknown metadata
  /// falls back to Balanced; ties favor Vocal, then Clear, then Bass.
  static AudioPreset presetForMetadata({
    required String title,
    required String artist,
  }) {
    final normalizedTitle = _normalizeMetadata(title);
    final normalizedArtist = _normalizeMetadata(artist);
    var bass = 0;
    var vocal = 0;
    var clear = 0;

    for (final entry in _autoKeywords.entries) {
      final score = _keywordScore(normalizedTitle, entry.value) * 2 +
          _keywordScore(normalizedArtist, entry.value);
      switch (entry.key) {
        case AudioPreset.bass:
          bass = score;
        case AudioPreset.vocal:
          vocal = score;
        case AudioPreset.clear:
          clear = score;
        case AudioPreset.auto:
        case AudioPreset.balanced:
          break;
      }
    }

    if (vocal > 0 && vocal >= clear && vocal >= bass) {
      return AudioPreset.vocal;
    }
    if (clear > 0 && clear >= bass) return AudioPreset.clear;
    if (bass > 0) return AudioPreset.bass;
    return AudioPreset.balanced;
  }

  void _onPlayerChanged() {
    if (_disposed || !_enabled || _preset != AudioPreset.auto) return;
    final track = _player?.current;
    final signature = _metadataSignature(track);
    if (signature == _trackSignature) return;
    _track = track;
    _trackSignature = signature;
    unawaited(_requestApply());
  }

  Future<void> _requestApply() {
    if (_disposed) return Future<void>.value();
    final generation = ++_applyGeneration;
    final operation = _applyQueue.then((_) async {
      if (_disposed || generation != _applyGeneration) return;
      try {
        await _applyCurrent();
      } catch (error, stackTrace) {
        log('Unable to apply audio EQ preset',
            name: 'fermata.audio', error: error, stackTrace: stackTrace);
      }
    });
    _applyQueue = operation;
    return operation;
  }

  Future<void> _applyCurrent() async {
    if (!_enabled) {
      await _engine.setEqualizerEnabled(false);
      return;
    }

    final gains = effectivePreset.bandGains;
    if (_engine.equalizerEnabled) {
      await _engine.setEqualizerBandGains(gains, immediate: true);
    } else {
      // Set the curve before enabling so the first filter already uses it.
      await _engine.setEqualizerBandGains(gains);
      await _engine.setEqualizerEnabled(true);
    }
  }

  Future<void> _persist() async {
    try {
      await _settings.putSettingStr(
        settingKey,
        _enabled ? _preset.storageValue : _disabledValue,
      );
    } catch (error, stackTrace) {
      log('Unable to save audio EQ preference',
          name: 'fermata.audio', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    ++_applyGeneration;
    _player?.removeListener(_onPlayerChanged);
    _player = null;
    _track = null;
    _trackSignature = null;
    await _applyQueue;
  }
}

Object? _metadataSignature(Track? track) => track == null
    ? null
    : (
        track.id,
        track.title,
        track.artists.map((artist) => artist.name).join(', '),
      );

String _normalizeMetadata(String value) =>
    ' ${value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim()} ';

int _keywordScore(String metadata, Set<String> keywords) =>
    keywords.where((keyword) => metadata.contains(' $keyword ')).length;
