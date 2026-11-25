// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:fermata/core/models/exported.dart';
import 'package:flutter/material.dart';

class ArtworkThumbnail extends StatelessWidget {
  const ArtworkThumbnail({
    super.key,
    required this.artwork,
    this.size = 48,
    this.borderRadius = 12,
  });

  final Artwork? artwork;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final url = artwork?.urlHigh ?? artwork?.urlLow ?? artwork?.url ?? '';
    final Widget image;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      image = Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallback(context),
      );
    } else if (url.isNotEmpty) {
      image = Image.file(
        File(url),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallback(context),
      );
    } else {
      image = _fallback(context);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(width: size, height: size, child: image),
    );
  }

  Widget _fallback(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.music_note_rounded,
        size: size * 0.45,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
