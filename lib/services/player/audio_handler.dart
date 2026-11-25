import 'package:audio_service/audio_service.dart';
import 'package:fermata/blocs/player/player_cubit.dart';
import 'package:fermata/core/adapters/track_adapter.dart';
import 'package:fermata/services/player/player_engine.dart';

class FermataAudioHandler extends BaseAudioHandler {
  FermataAudioHandler(this.player) {
    player.addListener(_sync);
    _sync();
  }

  final PlayerService player;
  String? _lastMediaId;
  String? _lastQueueSignature;

  void _sync() {
    final track = player.current;
    final mediaId = track?.id;
    if (mediaId != _lastMediaId) {
      _lastMediaId = mediaId;
      mediaItem.add(track == null ? null : trackToMediaItem(track));
    }
    final queueSignature = player.queue.map((track) => track.id).join('\n');
    if (queueSignature != _lastQueueSignature) {
      _lastQueueSignature = queueSignature;
      queue.add(player.queue.map(trackToMediaItem).toList(growable: false));
    }
    playbackState.add(PlaybackState(
      processingState: player.reconnecting
          ? AudioProcessingState.buffering
          : player.engine.state == EngineState.idle ||
                  player.engine.state == EngineState.completed
              ? AudioProcessingState.idle
              : player.error != null || player.engine.state == EngineState.error
                  ? AudioProcessingState.error
                  : AudioProcessingState.ready,
      playing: player.playing,
      controls: const [
        MediaControl.stop,
        MediaControl.skipToPrevious,
        MediaControl.play,
        MediaControl.pause,
        MediaControl.skipToNext,
      ],
      systemActions: const {MediaAction.seek},
      updatePosition: player.position,
      bufferedPosition: player.engine.buffered,
      speed: player.engine.speed,
      errorMessage: player.error,
      queueIndex: player.currentIndex < 0 ? null : player.currentIndex,
    ));
  }

  @override
  Future<void> play() => player.resume();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> stop() => player.stop();

  @override
  Future<void> skipToNext() => player.next();

  @override
  Future<void> skipToPrevious() => player.prev();

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dbusVolume') {
      final value = extras?['value'];
      if (value is num) await player.engine.setVolume(value.toDouble());
    }
  }

  void dispose() {
    player.removeListener(_sync);
  }
}
