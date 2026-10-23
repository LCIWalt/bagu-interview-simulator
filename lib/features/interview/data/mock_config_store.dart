import 'dart:convert';

import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';

/// 记住上次实战配置（T-040），非敏感，存 settings。
class MockConfigStore {
  MockConfigStore(this._db);

  final AppDatabase _db;
  static const String _key = 'mock.lastConfig';

  Future<SessionConfig?> load() async {
    final row = await (_db.select(
      _db.settings,
    )..where((Settings t) => t.key.equals(_key))).getSingleOrNull();
    if (row == null) return null;
    try {
      final decoded = jsonDecode(row.value);
      if (decoded is! Map<String, dynamic>) return null;
      return SessionConfig.fromJson(decoded);
    } on FormatException {
      return null;
    }
  }

  Future<void> save(SessionConfig config) async {
    await _db
        .into(_db.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: _key,
            value: jsonEncode(config.toJson()),
            updatedAt: DateTime.now(),
          ),
        );
  }
}
