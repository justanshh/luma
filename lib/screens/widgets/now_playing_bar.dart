import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fermata/blocs/player/player_cubit.dart';
import 'package:fermata/core/models/exported.dart';
import 'package:flutter/material.dart';

class NowPlayingBar extends StatefulWidget {
  const NowPlayingBar({super.key});

  @override
  State<NowPlayingBar> createState() => _NowPlayingBarState();
}

class _NowPlayingBarState extends State<NowPlayingBar> {
  static const double _artworkExtent = 56;

  PlayerCubit? _cubit;
  ImageProvider<Object>? _artworkProvider;
  ImageStream? _artworkStream;
  late final ImageStreamListener _artworkListener = ImageStreamListener(
    _onArtwork,
    onError: _onArtworkError,
  );
  String? _artworkSignature;
  Color? _accent;
  double? _seekPosition;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cubit = context.watch<PlayerCubit>();
    if (!identical(cubit, _cubit)) {
      _cubit?.removeListener(_playerChanged);
      _cubit = cubit..addListener(_playerChanged);
    }
    _syncArtwork(cubit.state.current);
  }

  void _playerChanged() {
    if (!mounted || _cubit == null) return;
    if (_syncArtwork(_cubit!.state.current)) {
      setState(() {});
    }
  }

  bool _syncArtwork(Track? track) {
    final source = _artworkSource(track);
    final signature = '${track?.id ?? ''}\u0000$source';
    if (signature == _artworkSignature) return false;

    _artworkSignature = signature;
    _artworkStream?.removeListener(_artworkListener);
    _artworkStream = null;
    _artworkProvider = null;
    _accent = null;
    _seekPosition = null;

    final provider = _providerForSource(source);
    if (provider == null) return true;

    final resized = ResizeImage(
      provider,
      width: _artworkExtent.round(),
      height: _artworkExtent.round(),
      policy: ResizeImagePolicy.fit,
      useLogicalSize: true,
    );
    _artworkProvider = resized;
    try {
      final stream = resized.resolve(
        createLocalImageConfiguration(
          context,
          size: const Size.square(_artworkExtent),
        ),
      );
      _artworkStream = stream;
      stream.addListener(_artworkListener);
    } catch (_) {
      _artworkProvider = null;
    }
    return true;
  }

  String _artworkSource(Track? track) {
    final thumbnail = track?.thumbnail;
    final candidates = [
      thumbnail?.url,
      thumbnail?.urlHigh,
      thumbnail?.urlLow,
      track?.album?.thumbnail?.url,
    ];
    for (final candidate in candidates) {
      final source = candidate?.trim() ?? '';
      if (source.isNotEmpty) return source;
    }
    return '';
  }

  ImageProvider<Object>? _providerForSource(String source) {
    if (source.isEmpty) return null;
    if (source.startsWith('http://') || source.startsWith('https://')) {
      final uri = Uri.tryParse(source);
      if (uri != null && uri.host.isNotEmpty) return NetworkImage(source);
      return null;
    }

    try {
      final uri = Uri.tryParse(source);
      final file = uri != null && uri.scheme == 'file'
          ? File.fromUri(uri)
          : File(source);
      if (file.existsSync()) return FileImage(file);
    } catch (_) {}
    return null;
  }

  void _onArtwork(ImageInfo info, bool synchronousCall) {
    unawaited(_extractAccent(info));
  }

  void _onArtworkError(Object exception, StackTrace? stackTrace) {}

  Future<void> _extractAccent(ImageInfo info) async {
    final signature = _artworkSignature;
    try {
      final bytes =
          await info.image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (bytes == null || !mounted || signature != _artworkSignature) return;
      final accent = _dominantAccent(bytes);
      if (accent == null || !mounted || signature != _artworkSignature) return;
      setState(() => _accent = accent);
    } catch (_) {
      // Keep the theme accent when artwork cannot be decoded.
    } finally {
      info.dispose();
    }
  }

  Future<void> _seek(PlayerCubit cubit, double value) async {
    try {
      await cubit.seek(Duration(milliseconds: value.round()));
    } catch (_) {
      // The playback engine remains the source of truth if seeking fails.
    } finally {
      if (mounted && _seekPosition == value) {
        setState(() => _seekPosition = null);
      }
    }
  }

  Widget _artwork() {
    final provider = _artworkProvider;
    if (provider == null) {
      return const SizedBox(
        width: _artworkExtent,
        height: _artworkExtent,
        child: Icon(Icons.music_note, size: 48),
      );
    }
    return Image(
      key: ValueKey(_artworkSignature),
      image: provider,
      width: _artworkExtent,
      height: _artworkExtent,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const SizedBox(
        width: _artworkExtent,
        height: _artworkExtent,
        child: Icon(Icons.music_note, size: 48),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<PlayerCubit>();
    final accent = _accent ?? Theme.of(context).colorScheme.primary;
    return AnimatedBuilder(
      animation: cubit,
      builder: (context, _) {
        final state = cubit.state;
        final track = state.current;
        final maximum = state.duration.inMilliseconds.toDouble();
        final position = state.position.inMilliseconds.toDouble();
        final sliderValue = maximum <= 0
            ? 0.0
            : (_seekPosition ?? position).clamp(0.0, maximum).toDouble();
        final canSeek = track != null && maximum > 0;
        return SizedBox(
          height: 88,
          child: Row(
            children: [
              const SizedBox(width: 12),
              _artwork(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track?.title ?? 'Nothing playing',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      track?.artists.map((artist) => artist.name).join(', ') ??
                          '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Slider(
                      value: sliderValue,
                      max: maximum <= 0 ? 1 : maximum,
                      activeColor: accent,
                      onChanged: canSeek
                          ? (value) => setState(() => _seekPosition = value)
                          : null,
                      onChangeEnd: canSeek
                          ? (value) => unawaited(_seek(cubit, value))
                          : null,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Previous',
                onPressed: track == null ? null : cubit.prev,
                icon: const Icon(Icons.skip_previous),
              ),
              IconButton(
                tooltip: state.playing ? 'Pause' : 'Play',
                onPressed: track == null ? null : cubit.toggle,
                color: accent,
                icon: Icon(state.playing ? Icons.pause : Icons.play_arrow),
              ),
              IconButton(
                tooltip: 'Next',
                onPressed: track == null ? null : cubit.next,
                icon: const Icon(Icons.skip_next),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: state.volume <= 0 ? 'Unmute' : 'Mute',
                onPressed: () => unawaited(
                  cubit.setVolume(state.volume <= 0 ? 1.0 : 0.0),
                ),
                icon: Icon(_volumeIcon(state.volume)),
              ),
              SizedBox(
                width: 96,
                child: Slider(
                  value: state.volume.clamp(0.0, 1.0).toDouble(),
                  activeColor: accent,
                  onChanged: (value) => unawaited(cubit.setVolume(value)),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _cubit?.removeListener(_playerChanged);
    _artworkStream?.removeListener(_artworkListener);
    super.dispose();
  }
}

IconData _volumeIcon(double volume) {
  if (volume <= 0) return Icons.volume_off;
  if (volume < 0.5) return Icons.volume_down;
  return Icons.volume_up;
}

Color? _dominantAccent(ByteData bytes) {
  final buckets = <int, _ColorBucket>{};
  for (var offset = 0; offset + 3 < bytes.lengthInBytes; offset += 4) {
    final alpha = bytes.getUint8(offset + 3);
    if (alpha < 128) continue;
    final red = bytes.getUint8(offset);
    final green = bytes.getUint8(offset + 1);
    final blue = bytes.getUint8(offset + 2);
    final color = HSLColor.fromColor(Color.fromARGB(255, red, green, blue));
    if (color.saturation < 0.12 ||
        color.lightness < 0.1 ||
        color.lightness > 0.9) {
      continue;
    }

    // Four bits per channel keeps quantization inexpensive while preserving
    // the dominant colour family of the artwork.
    final key = ((red >> 4) << 8) | ((green >> 4) << 4) | (blue >> 4);
    final bucket = buckets.putIfAbsent(key, _ColorBucket.new);
    bucket.count++;
    bucket.red += red;
    bucket.green += green;
    bucket.blue += blue;
  }

  _ColorBucket? dominant;
  HSLColor? dominantHsl;
  var dominantScore = 0.0;
  for (final bucket in buckets.values) {
    final average = Color.fromARGB(
      255,
      bucket.red ~/ bucket.count,
      bucket.green ~/ bucket.count,
      bucket.blue ~/ bucket.count,
    );
    final hsl = HSLColor.fromColor(average);
    final lightnessWeight =
        (1 - (hsl.lightness - 0.5).abs() * 1.6).clamp(0.2, 1.0).toDouble();
    final score = bucket.count * (0.2 + hsl.saturation) * lightnessWeight;
    if (score > dominantScore) {
      dominant = bucket;
      dominantHsl = hsl;
      dominantScore = score;
    }
  }

  if (dominant == null || dominantHsl == null) return null;
  return dominantHsl
      .withSaturation(dominantHsl.saturation.clamp(0.35, 0.9).toDouble())
      .withLightness(dominantHsl.lightness.clamp(0.35, 0.65).toDouble())
      .toColor();
}

class _ColorBucket {
  int count = 0;
  int red = 0;
  int green = 0;
  int blue = 0;
}
