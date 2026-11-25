// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import 'dart:async';
import 'dart:developer';

import 'package:dbus/dbus.dart';

/// Claims a fixed session-bus name so later launches can activate this window.
class DesktopActivationService {
  static const name = 'io.github.hungerg.fermata';
  static const interface = name;
  static const objectPath =
      DBusObjectPath.unchecked('/io/github/hungerg/fermata');

  final _showRequests = StreamController<void>.broadcast();
  DBusClient? _client;
  bool _closed = false;

  Stream<void> get showRequests => _showRequests.stream;

  /// Returns false when another Fermata instance already owns [name].
  ///
  /// A missing session bus is non-fatal: the application can still run without
  /// second-instance activation.
  Future<bool> claim() async {
    try {
      final client = DBusClient.session();
      _client = client;
      await client.registerObject(_ActivationObject(() {
        _showRequests.add(null);
      }));
      final reply = await client.requestName(
        name,
        flags: {DBusRequestNameFlag.doNotQueue},
      );
      return reply == DBusRequestNameReply.primaryOwner ||
          reply == DBusRequestNameReply.alreadyOwner;
    } catch (error, stackTrace) {
      log('Unable to claim the desktop activation name: $error',
          name: 'fermata.desktop', error: error, stackTrace: stackTrace);
      await close();
      return true;
    }
  }

  Future<void> showExistingInstance() async {
    final client = _client;
    if (client == null || _closed) return;
    await client.callMethod(
      destination: name,
      path: objectPath,
      interface: interface,
      name: 'Show',
      replySignature: DBusSignature(''),
    );
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _showRequests.close();
    await _client?.close();
    _client = null;
  }
}

class _ActivationObject extends DBusObject {
  _ActivationObject(this._onShow) : super(DesktopActivationService.objectPath);

  final void Function() _onShow;

  @override
  List<DBusIntrospectInterface> introspect() {
    return [
      DBusIntrospectInterface(DesktopActivationService.interface, methods: [
        DBusIntrospectMethod('Show'),
      ]),
    ];
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface != DesktopActivationService.interface) {
      return DBusMethodErrorResponse.unknownInterface();
    }
    if (methodCall.name != 'Show') {
      return DBusMethodErrorResponse.unknownMethod();
    }
    if (methodCall.signature != DBusSignature('')) {
      return DBusMethodErrorResponse.invalidArgs();
    }
    _onShow();
    return DBusMethodSuccessResponse([]);
  }
}
