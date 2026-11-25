class CachedMedia {
  final String mediaId;
  final String filePath;
  final String fileName;
  final DateTime? lastPlayed;

  const CachedMedia({
    required this.mediaId,
    required this.filePath,
    required this.fileName,
    required this.lastPlayed,
  });
}
