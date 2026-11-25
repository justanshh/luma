import 'dart:io';

import 'package:fermata/services/db/database_schemas.dart';
import 'package:isar/isar.dart';

/// Owns the canonical database connection.
class DBProvider {
  static late String appSuppDir;
  static late String appDocDir;
  static late Future<Isar> db;
  static Future<Isar>? _opening;

  static const schemas = databaseSchemas;

  static Future<Isar> init({
    required String appSupportPath,
    required String appDocumentsPath,
  }) async {
    appSuppDir = appSupportPath;
    appDocDir = appDocumentsPath;
    db = openDB();
    return db;
  }

  static Future<Isar> openDB() {
    final existing = Isar.getInstance('dbv3');
    if (existing != null) return Future.value(existing);
    return _opening ??= _openCanonical();
  }

  static Future<Isar> _openCanonical() async {
    try {
      await Directory(appSuppDir).create(recursive: true);
      return await Isar.open(schemas, directory: appSuppDir, name: 'dbv3');
    } finally {
      _opening = null;
    }
  }
}
