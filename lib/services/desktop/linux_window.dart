import 'dart:ffi';
import 'dart:io';

final class _GList extends Struct {
  external Pointer<Void> data;
  external Pointer<_GList> next;
  external Pointer<_GList> prev;
}

class LinuxWindow {
  LinuxWindow() : _lib = DynamicLibrary.open('libgtk-3.so.0') {
    _listToplevels = _lib.lookupFunction<Pointer<_GList> Function(),
        Pointer<_GList> Function()>('gtk_window_list_toplevels');
    _showAll = _lib.lookupFunction<Void Function(Pointer<Void>),
        void Function(Pointer<Void>)>('gtk_widget_show_all');
    _present = _lib.lookupFunction<Void Function(Pointer<Void>),
        void Function(Pointer<Void>)>('gtk_window_present');
    _hide = _lib.lookupFunction<Void Function(Pointer<Void>),
        void Function(Pointer<Void>)>('gtk_widget_hide');
    _move = _lib.lookupFunction<Void Function(Pointer<Void>, Int32, Int32),
        void Function(Pointer<Void>, int, int)>('gtk_window_move');
    _resize = _lib.lookupFunction<Void Function(Pointer<Void>, Int32, Int32),
        void Function(Pointer<Void>, int, int)>('gtk_window_resize');
    _visible = _lib.lookupFunction<Int32 Function(Pointer<Void>),
        int Function(Pointer<Void>)>('gtk_widget_get_visible');
    _freeList = _lib.lookupFunction<Void Function(Pointer<Void>),
        void Function(Pointer<Void>)>('g_list_free');
  }

  final DynamicLibrary _lib;
  late final Pointer<_GList> Function() _listToplevels;
  late final void Function(Pointer<Void>) _showAll;
  late final void Function(Pointer<Void>) _present;
  late final void Function(Pointer<Void>) _hide;
  late final void Function(Pointer<Void>, int, int) _move;
  late final void Function(Pointer<Void>, int, int) _resize;
  late final int Function(Pointer<Void>) _visible;
  late final void Function(Pointer<Void>) _freeList;

  void _each(void Function(Pointer<Void>) action) {
    var node = _listToplevels();
    final head = node;
    while (node != nullptr) {
      action(node.ref.data);
      node = node.ref.next;
    }
    if (head != nullptr) _freeList(head.cast());
  }

  void show() {
    if (!Platform.isLinux) return;
    _each((window) {
      _move(window, 0, 0);
      _resize(window, 1280, 720);
      _showAll(window);
      _present(window);
    });
  }

  void hide() {
    if (!Platform.isLinux) return;
    _each(_hide);
  }

  bool get isVisible {
    if (!Platform.isLinux) return true;
    var visible = false;
    _each((window) {
      if (_visible(window) != 0) visible = true;
    });
    return visible;
  }
}
