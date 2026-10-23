import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../platform/secure_store.dart';
import 'preferences.dart';
import 'provider_config.dart';

/// provider 配置读写：非敏感字段进 DB，密钥进 SecureStore。
class ProviderRepository {
  ProviderRepository(this._db, this._secure);

  final AppDatabase _db;
  final SecureStore _secure;

  Future<List<ProviderConfig>> loadAll() async {
    final rows = await _db.select(_db.providers).get();
    final byRole = <ProviderRole, ProviderConfig>{};
    for (final row in rows) {
      final role = ProviderRole.values.firstWhere(
        (ProviderRole value) => value.name == row.id,
        orElse: () => ProviderRole.interviewer,
      );
      byRole[role] = ProviderConfig.fromRow(
        role: role,
        baseUrl: row.baseUrl,
        modelMapJson: row.modelMap,
        enabled: row.enabled,
      );
    }
    return ProviderRole.values
        .map(
          (ProviderRole role) => byRole[role] ?? ProviderConfig.defaults(role),
        )
        .toList(growable: false);
  }

  Future<String?> loadKey(ProviderRole role) =>
      _secure.read('mockmate.provider.${role.name}');

  Future<void> save(ProviderConfig config, {String? apiKey}) async {
    await _db
        .into(_db.providers)
        .insertOnConflictUpdate(
          ProvidersCompanion.insert(
            id: config.role.name,
            kind: config.role.name,
            baseUrl: config.baseUrl.trim(),
            modelMap: Value(jsonEncode(config.modelMap)),
            keyRef: Value(config.keyAlias),
            enabled: Value(config.enabled),
          ),
        );
    if (apiKey != null && apiKey.isNotEmpty) {
      await _secure.write(config.keyAlias, apiKey);
      // 防止 Keychain 静默失败：写入后回读校验，失败就明确抛错。
      final stored = await _secure.read(config.keyAlias);
      if (stored != apiKey) {
        throw StateError('API key 写入钥匙串失败（回读为空或不一致）');
      }
    }
  }

  Future<void> deleteKey(ProviderRole role) =>
      _secure.delete('mockmate.provider.${role.name}');

  /// 启动时清理遗留的明文 key（历史版本可能写进 DB）。
  Future<void> scrubLegacyKeys() async {
    final rows = await _db.select(_db.providers).get();
    for (final row in rows) {
      if (row.baseUrl.contains('sk-')) {
        await (_db.update(
          _db.providers,
        )..where((Providers t) => t.id.equals(row.id))).write(
          ProvidersCompanion(
            baseUrl: Value(
              row.baseUrl.replaceAll(RegExp('sk-[A-Za-z0-9_-]+'), ''),
            ),
          ),
        );
      }
    }
  }
}

class PreferencesRepository {
  PreferencesRepository(this._db);

  static const String _key = 'app.preferences';
  final AppDatabase _db;

  Future<AppPreferences> load() async {
    final row = await (_db.select(
      _db.settings,
    )..where((Settings t) => t.key.equals(_key))).getSingleOrNull();
    if (row == null) return const AppPreferences();
    return AppPreferences.fromJson(row.value);
  }

  Future<void> save(AppPreferences prefs) async {
    await _db
        .into(_db.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: _key,
            value: jsonEncode(prefs.toJson()),
            updatedAt: DateTime.now(),
          ),
        );
  }
}

/// 用于把 JSON 列表写进 TEXT 列的小工具，避免散落 `jsonEncode`。
String encodeJsonList(List<String> values) => jsonEncode(values);

/// BLOB 向量解包（后续 T-024 使用；先固定 little-endian float32）。
List<double> decodeFloat32(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  return List<double>.generate(
    data.lengthInBytes ~/ 4,
    (int i) => data.getFloat32(i * 4, Endian.little),
    growable: false,
  );
}

Uint8List encodeFloat32(List<double> values) {
  final data = ByteData(values.length * 4);
  for (var i = 0; i < values.length; i++) {
    data.setFloat32(i * 4, values[i], Endian.little);
  }
  return data.buffer.asUint8List();
}
