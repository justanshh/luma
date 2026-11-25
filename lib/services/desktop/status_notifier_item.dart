// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import 'dart:async';

import 'package:dbus/dbus.dart';

/// The StatusNotifierItem object exported by Luma's system tray.
class FermataStatusNotifierItem extends DBusObject {
  FermataStatusNotifierItem({required this.onActivate})
      : super(const DBusObjectPath.unchecked('/StatusNotifierItem'));

  static const interfaceName = 'org.kde.StatusNotifierItem';
  static const iconName = 'audio-x-generic';

  final FutureOr<void> Function() onActivate;

  Map<String, DBusValue> get _properties => {
        'Category': const DBusString('ApplicationStatus'),
        'Id': const DBusString('fermata'),
        'Title': const DBusString('Luma'),
        'Status': const DBusString('Active'),
        'IconName': const DBusString(iconName),
        'IconAccessibleDesc': const DBusString('Luma music player'),
        'AttentionIconName': const DBusString(''),
        'ToolTip': DBusStruct([
          const DBusString(iconName),
          DBusDict.stringVariant({
            'Title': const DBusString('Luma'),
            'IconName': const DBusString(iconName),
          }),
        ]),
        'MenuObjectPath': const DBusObjectPath.unchecked('/MenuBar'),
      };

  /// Re-announces the item after a new watcher starts.
  Future<void> republish() async {
    await emitSignal(interfaceName, 'NewIcon');
    await emitSignal(interfaceName, 'NewAttentionIcon');
    await emitSignal(interfaceName, 'NewStatus', [const DBusString('Active')]);
    await emitSignal(interfaceName, 'NewTitle', [const DBusString('Luma')]);
    await emitSignal(interfaceName, 'NewToolTip', [_properties['ToolTip']!]);
  }

  @override
  List<DBusIntrospectInterface> introspect() {
    return [
      DBusIntrospectInterface(interfaceName, methods: [
        DBusIntrospectMethod('Activate', args: [
          DBusIntrospectArgument(DBusSignature('i'), DBusArgumentDirection.in_,
              name: 'x'),
          DBusIntrospectArgument(DBusSignature('i'), DBusArgumentDirection.in_,
              name: 'y'),
        ]),
        DBusIntrospectMethod('SecondaryActivate', args: [
          DBusIntrospectArgument(DBusSignature('i'), DBusArgumentDirection.in_,
              name: 'x'),
          DBusIntrospectArgument(DBusSignature('i'), DBusArgumentDirection.in_,
              name: 'y'),
        ]),
        DBusIntrospectMethod('ContextMenu', args: [
          DBusIntrospectArgument(DBusSignature('i'), DBusArgumentDirection.in_,
              name: 'x'),
          DBusIntrospectArgument(DBusSignature('i'), DBusArgumentDirection.in_,
              name: 'y'),
        ]),
        DBusIntrospectMethod('Scroll', args: [
          DBusIntrospectArgument(DBusSignature('i'), DBusArgumentDirection.in_,
              name: 'delta'),
          DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_,
              name: 'orientation'),
        ]),
      ], signals: [
        DBusIntrospectSignal('NewIcon'),
        DBusIntrospectSignal('NewAttentionIcon'),
        DBusIntrospectSignal('NewStatus', args: [
          DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.out,
              name: 'status'),
        ]),
        DBusIntrospectSignal('NewTitle', args: [
          DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.out,
              name: 'title'),
        ]),
        DBusIntrospectSignal('NewToolTip', args: [
          DBusIntrospectArgument(
              DBusSignature('(sa{sv})'), DBusArgumentDirection.out,
              name: 'tooltip'),
        ]),
      ], properties: [
        DBusIntrospectProperty('Category', DBusSignature('s'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Id', DBusSignature('s'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Title', DBusSignature('s'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Status', DBusSignature('s'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('IconName', DBusSignature('s'),
            access: DBusPropertyAccess.read,
            annotations: [
              DBusIntrospectAnnotation(
                  'org.freedesktop.DBus.Property.EmitsChangedSignal', 'true'),
            ]),
        DBusIntrospectProperty('IconAccessibleDesc', DBusSignature('s'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('AttentionIconName', DBusSignature('s'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('ToolTip', DBusSignature('(sa{sv})'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('MenuObjectPath', DBusSignature('o'),
            access: DBusPropertyAccess.read),
      ]),
    ];
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface != interfaceName) {
      return DBusMethodErrorResponse.unknownInterface();
    }
    switch (methodCall.name) {
      case 'Activate':
      case 'SecondaryActivate':
        if (methodCall.signature != DBusSignature('ii')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        await onActivate();
        return DBusMethodSuccessResponse([]);
      case 'ContextMenu':
        if (methodCall.signature != DBusSignature('ii')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return DBusMethodSuccessResponse([]);
      case 'Scroll':
        if (methodCall.signature != DBusSignature('is')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return DBusMethodSuccessResponse([]);
      default:
        return DBusMethodErrorResponse.unknownMethod();
    }
  }

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    if (interface != interfaceName) {
      return DBusMethodErrorResponse.unknownInterface();
    }
    final value = _properties[name];
    if (value == null) return DBusMethodErrorResponse.unknownProperty();
    return DBusMethodSuccessResponse([DBusVariant(value)]);
  }

  @override
  Future<DBusMethodResponse> setProperty(
      String interface, String name, DBusValue value) async {
    if (interface != interfaceName) {
      return DBusMethodErrorResponse.unknownInterface();
    }
    if (_properties.containsKey(name)) {
      return DBusMethodErrorResponse.propertyReadOnly();
    }
    return DBusMethodErrorResponse.unknownProperty();
  }

  @override
  Future<DBusMethodResponse> getAllProperties(String interface) async {
    if (interface != interfaceName) {
      return DBusMethodErrorResponse.unknownInterface();
    }
    return DBusGetAllPropertiesResponse(_properties);
  }
}
