import 'package:fermata/services/db/global_db.dart';
import 'package:isar/isar.dart';

class SettingsDAO {
  const SettingsDAO(this._db);

  final Future<Isar> _db;

  Future<void> putSettingStr(String key, String value) async {
    final isar = await _db;
    await isar.writeTxn(() => isar.appSettingsStrDBs.put(
          AppSettingsStrDB(settingName: key, settingValue: value),
        ));
  }

  Future<String?> getSettingStr(String key, {String? defaultValue}) async {
    final isar = await _db;
    return isar.appSettingsStrDBs
            .filter()
            .settingNameEqualTo(key)
            .findFirstSync()
            ?.settingValue ??
        defaultValue;
  }

  Future<void> putSettingBool(String key, bool value) async {
    final isar = await _db;
    await isar.writeTxn(() => isar.appSettingsBoolDBs.put(
          AppSettingsBoolDB(settingName: key, settingValue: value),
        ));
  }

  Future<bool?> getSettingBool(String key, {bool? defaultValue}) async {
    final isar = await _db;
    return isar.appSettingsBoolDBs
            .filter()
            .settingNameEqualTo(key)
            .findFirstSync()
            ?.settingValue ??
        defaultValue;
  }
}
