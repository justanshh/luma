// ignore_for_file: deprecated_member_use

import 'package:fermata/core/constants/luma_settings.dart';
import 'package:flutter/material.dart';

ThemeData lumaTheme(
  LumaThemePreset preset, {
  Brightness? brightness,
}) {
  final resolvedBrightness = brightness ??
      WidgetsBinding.instance.platformDispatcher.platformBrightness;
  final seed = switch (preset) {
    LumaThemePreset.auto || LumaThemePreset.violet => const Color(0xFF7C5CFC),
    LumaThemePreset.ocean => const Color(0xFF2878A8),
    LumaThemePreset.sunset => const Color(0xFFD96570),
    LumaThemePreset.mono => const Color(0xFF64748B),
  };
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: resolvedBrightness,
  );
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: scheme.surface,
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  );
}
