// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:fermata/blocs/player/player_cubit.dart';
import 'package:window_manager/window_manager.dart';

import 'status_notifier_item.dart';
import 'linux_window.dart';
import 'tray_menu.dart';

/// Owns the Linux StatusNotifierItem, its menu, and the main window controls.
///
/// A single instance is registered in `ServiceLocator.tray`.
class DesktopTrayService {
  DesktopTrayService({required PlayerService player}) : _player = player;

  static const _watcherName = 'org.kde.StatusNotifierWatcher';
  static const _watcherPath =
      DBusObjectPath.unchecked('/StatusNotifierWatcher');

  final PlayerService _player;
  final LinuxWindow _linuxWindow = LinuxWindow();
  DBusClient? _client;
  FermataStatusNotifierItem? _item;
  TrayMenu? _menu;
  StreamSubscription<DBusNameOwnerChangedEvent>? _watcherSubscription;
  ListenerId? _windowListener;
  Window? _window;
  String? _busName;
  Future<void>? _initialization;
  Future<void> _registration = Future<void>.value();
  bool _dbusReady = false;
  bool _closed = false;
  bool _quitting = false;
  bool? _lastPlaying;
  bool? _lastHasCurrent;

  /// Called after a native close request has been cancelled.
  Future<void> Function()? closeRequestedHandler;

  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    _window = WindowManager.instance.getCurrent();
    _windowListener = WindowManager.instance.addListener(_onWindowEvent);
    _player.addListener(_onPlayerChanged);
    _lastPlaying = _player.playing;
    _lastHasCurrent = _player.current != null;

    try {
      final client = DBusClient.session();
      _client = client;
      final item = FermataStatusNotifierItem(onActivate: showWindow);
      final menu = TrayMenu(
        itemBuilder: _buildMenuItems,
        actions: {
          1: _togglePlayback,
          2: _next,
          3: _previous,
          5: _toggleWindow,
          6: quit,
        },
      );
      _item = item;
      _menu = menu;
      await client.registerObject(item);
      await client.registerObject(menu);

      _busName = 'org.kde.StatusNotifierItem-$pid-1';
      final reply = await client.requestName(
        _busName!,
        flags: {DBusRequestNameFlag.doNotQueue},
      );
      if (reply != DBusRequestNameReply.primaryOwner &&
          reply != DBusRequestNameReply.alreadyOwner) {
        throw StateError('Unable to own the StatusNotifierItem bus name');
      }

      _dbusReady = true;
      _watcherSubscription = client.nameOwnerChanged.listen(
        _onWatcherChanged,
        onError: (Object error, StackTrace stackTrace) {
          log('StatusNotifierWatcher monitor failed: $error',
              name: 'fermata.tray', error: error, stackTrace: stackTrace);
        },
      );
      final watcherOwner = await client.getNameOwner(_watcherName);
      if (watcherOwner != null) {
        await _queueRegistration(watcherOwner);
      }
    } catch (error, stackTrace) {
      log('Unable to initialize the system tray: $error',
          name: 'fermata.tray', error: error, stackTrace: stackTrace);
      await _closeDBus();
    }
  }

  Window? get _targetWindow {
    final existing = _window;
    if (existing != null) return existing;
    final current = WindowManager.instance.getCurrent();
    if (current != null) {
      _window = current;
      return current;
    }
    final windows = WindowManager.instance.getAll();
    if (windows.isNotEmpty) {
      _window = windows.first;
      return windows.first;
    }
    return null;
  }

  bool get _windowVisible => _linuxWindow.isVisible;

  Future<void> showWindow() async {
    _linuxWindow.show();
    await _refreshMenu();
  }

  Future<void> hideWindow() async {
    _linuxWindow.hide();
    await _refreshMenu();
  }

  Future<void> _toggleWindow() => _windowVisible ? hideWindow() : showWindow();

  Future<void> quit() async {
    if (_quitting || _closed) return;
    _quitting = true;
    final window = _targetWindow;
    if (window == null || !Window.isCloseSupported() || !window.close()) {
      exit(0);
    }
  }

  Future<void> _onWindowEvent(WindowEvent event) async {
    if (event is! WindowCloseRequestedEvent) return;
    final window = _targetWindow;
    if (window == null || event.windowId != window.id) return;
    if (_quitting) return;

    // Cancel synchronously, before a dialog or an async settings lookup.
    event.request.cancel();
    final handler = closeRequestedHandler;
    if (handler != null) {
      await handler();
    } else {
      await hideWindow();
    }
  }

  Future<void> _togglePlayback() async {
    await _player.toggle();
    await _refreshMenu();
  }

  Future<void> _next() async {
    await _player.next();
    await _refreshMenu();
  }

  Future<void> _previous() async {
    await _player.prev();
    await _refreshMenu();
  }

  void _onPlayerChanged() {
    final playing = _player.playing;
    final hasCurrent = _player.current != null;
    if (playing == _lastPlaying && hasCurrent == _lastHasCurrent) return;
    _lastPlaying = playing;
    _lastHasCurrent = hasCurrent;
    final menu = _menu;
    if (menu != null) unawaited(menu.refresh());
  }

  Future<void> _refreshMenu() async {
    await _menu?.refresh();
  }

  List<TrayMenuItem> _buildMenuItems() {
    final hasCurrent = _player.current != null;
    return [
      TrayMenuItem(
        id: 1,
        label: _player.playing ? 'Pause' : 'Play',
        enabled: hasCurrent,
        iconName:
            _player.playing ? 'media-playback-pause' : 'media-playback-start',
      ),
      TrayMenuItem(
        id: 2,
        label: 'Next',
        enabled: hasCurrent,
        iconName: 'media-skip-forward',
      ),
      TrayMenuItem(
        id: 3,
        label: 'Previous',
        enabled: hasCurrent,
        iconName: 'media-skip-backward',
      ),
      const TrayMenuItem(id: 4, label: '', enabled: false, separator: true),
      TrayMenuItem(
        id: 5,
        label: _windowVisible ? 'Hide window' : 'Show window',
        enabled: true,
        iconName: _windowVisible ? 'view-restore' : 'window-new',
      ),
      const TrayMenuItem(
        id: 6,
        label: 'Quit',
        enabled: true,
        iconName: 'application-exit',
      ),
    ];
  }

  void _onWatcherChanged(DBusNameOwnerChangedEvent event) {
    if (_closed || event.name != _watcherName || event.newOwner == null) {
      return;
    }
    unawaited(_queueRegistration(event.newOwner!));
  }

  Future<void> _queueRegistration(String watcherOwner) {
    _registration = _registration.then((_) async {
      try {
        await _registerWithWatcher(watcherOwner);
      } catch (error, stackTrace) {
        log('Unable to register the system tray: $error',
            name: 'fermata.tray', error: error, stackTrace: stackTrace);
      }
    });
    return _registration;
  }

  Future<void> _registerWithWatcher(String watcherOwner) async {
    final client = _client;
    final item = _item;
    final menu = _menu;
    final busName = _busName;
    if (_closed || !_dbusReady || client == null || busName == null) return;

    await client.callMethod(
      destination: watcherOwner,
      path: _watcherPath,
      interface: _watcherName,
      name: 'RegisterStatusNotifierItem',
      values: [DBusString(busName)],
      replySignature: DBusSignature(''),
    );
    await item?.republish();
    await menu?.refresh();
    await menu?.notifyLayoutUpdated();
  }

  Future<void> _closeDBus() async {
    _dbusReady = false;
    await _watcherSubscription?.cancel();
    _watcherSubscription = null;

    final client = _client;
    final busName = _busName;
    if (client != null && busName != null) {
      try {
        await client.releaseName(busName);
      } catch (_) {
        // Closing the connection releases every name and object as well.
      }
    }
    _busName = null;
    _item = null;
    _menu = null;
    await client?.close();
    _client = null;
  }

  Future<void> dispose() async {
    if (_closed) return;
    _closed = true;
    _player.removeListener(_onPlayerChanged);
    final listener = _windowListener;
    if (listener != null) WindowManager.instance.removeListener(listener);
    _windowListener = null;
    await _closeDBus();
    _window?.dispose();
    _window = null;
  }
}
