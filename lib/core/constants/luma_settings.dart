enum LumaThemePreset {
  auto,
  violet,
  ocean,
  sunset,
  mono;

  String get label => switch (this) {
        LumaThemePreset.auto => 'Auto',
        LumaThemePreset.violet => 'Violet',
        LumaThemePreset.ocean => 'Ocean',
        LumaThemePreset.sunset => 'Sunset',
        LumaThemePreset.mono => 'Mono',
      };

  String get storageValue => name;

  static LumaThemePreset fromStorage(String? value) {
    return LumaThemePreset.values.firstWhere(
      (preset) => preset.storageValue == value,
      orElse: () => LumaThemePreset.auto,
    );
  }
}

enum LumaEqualizerPreset {
  auto,
  balanced,
  bass,
  vocal,
  clear;

  String get label => switch (this) {
        LumaEqualizerPreset.auto => 'Auto',
        LumaEqualizerPreset.balanced => 'Balanced',
        LumaEqualizerPreset.bass => 'Bass',
        LumaEqualizerPreset.vocal => 'Vocal',
        LumaEqualizerPreset.clear => 'Clear',
      };

  String get storageValue => name;

  static LumaEqualizerPreset fromStorage(String? value) {
    return LumaEqualizerPreset.values.firstWhere(
      (preset) => preset.storageValue == value,
      orElse: () => LumaEqualizerPreset.auto,
    );
  }
}

class LumaSettingsKeys {
  const LumaSettingsKeys._();

  static const themePreset = 'settings.theme_preset';
  static const equalizerPreset = 'audio.preset';
  static const discordEnabled = 'discord.enabled';

  /// Shared with the existing desktop close handler.
  static const closeToTray = 'desktop.close_to_tray';
}
