import 'package:fermata/blocs/player/player_cubit.dart';
import 'package:fermata/core/di/service_locator.dart';
import 'package:flutter/foundation.dart';

/// Compatibility facade for the Discord singleton registered in ServiceLocator.
///
/// The actual connection and playback listener live in [DiscordService]. Keeping
/// this small facade avoids constructing a second Rust presence worker.
class DiscordPresenceService {
  DiscordPresenceService._();

  static final DiscordPresenceService instance = DiscordPresenceService._();

  final ValueNotifier<String?> statusMessage = ValueNotifier<String?>(null);

  bool get isRunning => ServiceLocator.discordService.enabled;

  void startListening(PlayerService _) {
    // ServiceLocator.discordService is initialized once by main and already
    // follows the same PlayerService singleton.
  }

  Future<void> setEnabled(bool enabled) async {
    try {
      await ServiceLocator.discordService.setEnabled(enabled);
      statusMessage.value = null;
    } catch (error) {
      statusMessage.value = 'Discord connection failed: $error';
    }
  }
}
