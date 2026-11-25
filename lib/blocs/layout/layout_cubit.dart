import 'dart:async';
import 'dart:convert';

import 'package:fermata/blocs/player/player_cubit.dart';
import 'package:fermata/services/db/dao/settings_dao.dart';

class LayoutState {
  const LayoutState({
    required this.sidebarWidth,
    required this.queueWidth,
    required this.queueVisible,
  });

  final double sidebarWidth;
  final double queueWidth;
  final bool queueVisible;
}

class LayoutCubit extends Cubit<LayoutState> {
  LayoutCubit(this._settings)
      : super(const LayoutState(
          sidebarWidth: 220,
          queueWidth: 300,
          queueVisible: true,
        ));

  static const key = 'layout.state';
  final SettingsDAO _settings;
  Timer? _debounce;

  Future<void> load() async {
    final raw = await _settings.getSettingStr(key);
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      emit(LayoutState(
        sidebarWidth: (json['sidebarWidth'] as num?)?.toDouble() ?? 220,
        queueWidth: (json['queueWidth'] as num?)?.toDouble() ?? 300,
        queueVisible: json['queueVisible'] as bool? ?? true,
      ));
    } catch (_) {
      emit(state);
    }
  }

  void setSidebarWidth(double value) {
    emit(LayoutState(
      sidebarWidth: value.clamp(160.0, 420.0),
      queueWidth: state.queueWidth,
      queueVisible: state.queueVisible,
    ));
    _scheduleSave();
  }

  void setQueueWidth(double value) {
    emit(LayoutState(
      sidebarWidth: state.sidebarWidth,
      queueWidth: value.clamp(200.0, 520.0),
      queueVisible: state.queueVisible,
    ));
    _scheduleSave();
  }

  void toggleQueue() {
    emit(LayoutState(
      sidebarWidth: state.sidebarWidth,
      queueWidth: state.queueWidth,
      queueVisible: !state.queueVisible,
    ));
    _scheduleSave();
  }

  void resetSidebar() => setSidebarWidth(220);
  void resetQueue() => setQueueWidth(300);

  void _scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      unawaited(_settings.putSettingStr(
          key,
          jsonEncode({
            'sidebarWidth': state.sidebarWidth,
            'queueWidth': state.queueWidth,
            'queueVisible': state.queueVisible,
          })));
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    unawaited(_settings.putSettingStr(
        key,
        jsonEncode({
          'sidebarWidth': state.sidebarWidth,
          'queueWidth': state.queueWidth,
          'queueVisible': state.queueVisible,
        })));
    super.dispose();
  }
}
