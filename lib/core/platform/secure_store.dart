import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 密钥只经此接口（AGENTS.md §4）。
abstract interface class SecureStore {
  Future<void> write(String key, String value);

  Future<String?> read(String key);

  Future<void> delete(String key);

  Future<void> deleteAll();
}

/// Keychain / Keystore 实现。
class PlatformSecureStore implements SecureStore {
  PlatformSecureStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
            // 无开发者证书（ad-hoc）时 sandbox 的 Keychain entitlement 不可用；
            // 使用 legacy keychain（见 ADR-0006）。
            mOptions: MacOsOptions(
              accessibility: KeychainAccessibility.first_unlock,
              useDataProtectionKeyChain: false,
            ),
          );

  final FlutterSecureStorage _storage;

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}

/// 测试用：不落盘。
class InMemorySecureStore implements SecureStore {
  final Map<String, String> values = <String, String>{};

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> deleteAll() async => values.clear();
}
