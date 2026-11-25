// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import 'dart:async';

import 'package:dbus/dbus.dart';

class TrayMenuItem {
  const TrayMenuItem({
    required this.id,
    required this.label,
    required this.enabled,
    this.iconName,
    this.separator = false,
  });

  final int id;
  final String label;
  final bool enabled;
  final String? iconName;
  final bool separator;
}

/// A flat com.canonical.dbusmenu menu used by the StatusNotifierItem.
class TrayMenu extends DBusObject {
  TrayMenu({
    required this.itemBuilder,
    required Map<int, FutureOr<void> Function()> actions,
  })  : _actions = actions,
        _items = itemBuilder(),
        super(const DBusObjectPath.unchecked('/MenuBar'));

  static const interface = 'com.canonical.dbusmenu';

  final List<TrayMenuItem> Function() itemBuilder;
  final Map<int, FutureOr<void> Function()> _actions;
  List<TrayMenuItem> _items;
  int _revision = 0;

  Future<void> refresh() async {
    final next = itemBuilder();
    if (_sameItems(_items, next)) return;
    _items = next;
    _revision++;
    await notifyLayoutUpdated();
  }

  Future<void> notifyLayoutUpdated() async {
    await emitSignal(interface, 'LayoutUpdated', [DBusUint32(_revision)]);
  }

  bool _sameItems(List<TrayMenuItem> previous, List<TrayMenuItem> next) {
    if (previous.length != next.length) return false;
    for (var index = 0; index < previous.length; index++) {
      final left = previous[index];
      final right = next[index];
      if (left.id != right.id ||
          left.label != right.label ||
          left.enabled != right.enabled ||
          left.iconName != right.iconName ||
          left.separator != right.separator) {
        return false;
      }
    }
    return true;
  }

  DBusStruct _itemLayout(
    TrayMenuItem item, {
    required int recursionDepth,
    required Set<String> propertyNames,
  }) {
    final properties = <String, DBusValue>{
      'type': DBusString(item.separator ? 'separator' : 'standard'),
      'visible': const DBusBoolean(true),
      if (!item.separator) ...{
        'label': DBusString(item.label),
        'enabled': DBusBoolean(item.enabled),
        'toggle-type': const DBusInt32(0),
        if (item.iconName != null) 'icon-name': DBusString(item.iconName!),
      },
    };
    final selectedProperties = propertyNames.isEmpty
        ? properties
        : Map.fromEntries(properties.entries.where(
            (entry) => propertyNames.contains(entry.key),
          ));
    return DBusStruct([
      DBusInt32(item.id),
      DBusDict.stringVariant(selectedProperties),
      DBusArray(DBusSignature('v'), const []),
    ]);
  }

  DBusStruct _rootLayout({
    required List<TrayMenuItem> items,
    required int recursionDepth,
    required Set<String> propertyNames,
  }) {
    final properties = <String, DBusValue>{
      'children-display': const DBusString('submenu'),
    };
    final selectedProperties = propertyNames.isEmpty
        ? properties
        : Map.fromEntries(properties.entries.where(
            (entry) => propertyNames.contains(entry.key),
          ));
    final children = recursionDepth <= 0
        ? const <DBusValue>[]
        : items
            .map((item) => DBusVariant(_itemLayout(
                  item,
                  recursionDepth: recursionDepth - 1,
                  propertyNames: propertyNames,
                )))
            .toList(growable: false);
    return DBusStruct([
      const DBusInt32(0),
      DBusDict.stringVariant(selectedProperties),
      DBusArray(DBusSignature('v'), children),
    ]);
  }

  @override
  List<DBusIntrospectInterface> introspect() {
    return [
      DBusIntrospectInterface(interface, methods: [
        DBusIntrospectMethod('AboutToShow', args: [
          DBusIntrospectArgument(DBusSignature('i'), DBusArgumentDirection.in_,
              name: 'id'),
          DBusIntrospectArgument(DBusSignature('b'), DBusArgumentDirection.out,
              name: 'needUpdate'),
        ]),
        DBusIntrospectMethod('Event', args: [
          DBusIntrospectArgument(DBusSignature('i'), DBusArgumentDirection.in_,
              name: 'id'),
          DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_,
              name: 'eventId'),
          DBusIntrospectArgument(DBusSignature('v'), DBusArgumentDirection.in_,
              name: 'data'),
          DBusIntrospectArgument(DBusSignature('d'), DBusArgumentDirection.in_,
              name: 'timestamp'),
        ]),
        DBusIntrospectMethod('GetLayout', args: [
          DBusIntrospectArgument(DBusSignature('i'), DBusArgumentDirection.in_,
              name: 'parentId'),
          DBusIntrospectArgument(DBusSignature('i'), DBusArgumentDirection.in_,
              name: 'recursionDepth'),
          DBusIntrospectArgument(DBusSignature('as'), DBusArgumentDirection.in_,
              name: 'propertyNames'),
          DBusIntrospectArgument(DBusSignature('u'), DBusArgumentDirection.out,
              name: 'revision'),
          DBusIntrospectArgument(
              DBusSignature('a(ia{sv}av)'), DBusArgumentDirection.out,
              name: 'layout'),
        ]),
        DBusIntrospectMethod('GetGroupProperties', args: [
          DBusIntrospectArgument(DBusSignature('ai'), DBusArgumentDirection.in_,
              name: 'ids'),
          DBusIntrospectArgument(DBusSignature('as'), DBusArgumentDirection.in_,
              name: 'propertyNames'),
          DBusIntrospectArgument(
              DBusSignature('a(ia{sv})'), DBusArgumentDirection.out,
              name: 'properties'),
        ]),
      ], signals: [
        DBusIntrospectSignal('ItemsPropertiesUpdated', args: [
          DBusIntrospectArgument(
              DBusSignature('a(ia{sv})'), DBusArgumentDirection.out,
              name: 'changedProps'),
          DBusIntrospectArgument(DBusSignature('as'), DBusArgumentDirection.out,
              name: 'removedProps'),
        ]),
        DBusIntrospectSignal('LayoutUpdated', args: [
          DBusIntrospectArgument(DBusSignature('u'), DBusArgumentDirection.out,
              name: 'revision'),
        ]),
      ]),
    ];
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface != interface) {
      return DBusMethodErrorResponse.unknownInterface();
    }
    switch (methodCall.name) {
      case 'AboutToShow':
        if (methodCall.signature != DBusSignature('i')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        await refresh();
        return DBusMethodSuccessResponse([const DBusBoolean(true)]);
      case 'Event':
        if (methodCall.signature != DBusSignature('isvd')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        if (methodCall.values[1].asString() == 'clicked') {
          final action = _actions[methodCall.values[0].asInt32()];
          if (action != null) await Future<void>.sync(action);
        }
        return DBusMethodSuccessResponse([]);
      case 'GetLayout':
        if (methodCall.signature != DBusSignature('ias')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        final items = itemBuilder();
        _items = items;
        final parentId = methodCall.values[0].asInt32();
        final recursionDepth = methodCall.values[1].asInt32();
        final propertyNames = methodCall.values[2].asStringArray().toSet();
        final layout = parentId == 0
            ? [
                _rootLayout(
                  items: items,
                  recursionDepth: recursionDepth,
                  propertyNames: propertyNames,
                ),
              ]
            : <DBusStruct>[];
        return DBusMethodSuccessResponse([
          DBusUint32(_revision),
          DBusArray(
            DBusSignature('(ia{sv}av)'),
            layout,
          ),
        ]);
      case 'GetGroupProperties':
        if (methodCall.signature != DBusSignature('aias')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return DBusMethodSuccessResponse([
          DBusArray(DBusSignature('(ia{sv})'), const []),
        ]);
      default:
        return DBusMethodErrorResponse.unknownMethod();
    }
  }
}
