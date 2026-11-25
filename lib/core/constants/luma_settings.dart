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

  /// Gains for the ten bands exposed by the player engine.
  List<double> get gains => switch (this) {
        LumaEqualizerPreset.auto || LumaEqualizerPreset.balanced => const [
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0
          ],
        LumaEqualizerPreset.bass => const [6, 5, 3, 1, 0, 0, -1, -1, -2, -2],
        LumaEqualizerPreset.vocal => const [-2, -1, 0, 2, 4, 5, 4, 2, 0, -1],
        LumaEqualizerPreset.clear => const [2, 1, 0, -1, -2, -1, 1, 3, 4, 4],
      };
}

class LumaSettingsKeys {
  const LumaSettingsKeys._();

  static const themePreset = 'settings.theme_preset';
  static const equalizerPreset = 'audio.preset';
  static const discordEnabled = 'discord.enabled';

  /// Shared with the existing desktop close handler.
  static const closeToTray = 'desktop.close_to_tray';
}
