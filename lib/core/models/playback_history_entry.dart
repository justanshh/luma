import 'package:fermata/core/models/exported.dart';

class PlaybackHistoryEntry {
  const PlaybackHistoryEntry({
    required this.track,
    required this.playedAt,
  });

  final Track track;
  final DateTime playedAt;
}
