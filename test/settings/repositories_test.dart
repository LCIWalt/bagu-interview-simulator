import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/core/platform/secure_store.dart';
import 'package:mockmate/core/settings/connectivity.dart';
import 'package:mockmate/core/settings/preferences.dart';
import 'package:mockmate/core/settings/provider_config.dart';
import 'package:mockmate/core/settings/repositories.dart';

class _SilentSecureStore implements SecureStore {
  @override
  Future<void> write(String key, String value) async {}

  @override
  Future<String?> read(String key) async => null;

  @override
  Future<void> delete(String key) async {}

  @override
  Future<void> deleteAll() async {}
}

void main() {
  late AppDatabase db;
  late InMemorySecureStore secure;

  setUp(() {
    db = AppDatabase.memory();
    secure = InMemorySecureStore();
  });
  tearDown(() => db.close());

  test(
    'provider config saves non-sensitive fields to DB and key to secure store',
    () async {
      final repo = ProviderRepository(db, secure);
      const config = ProviderConfig(
        role: ProviderRole.scorer,
        baseUrl: 'https://api.deepseek.com/v1',
        model: 'deepseek-chat',
        temperature: 0.2,
        enabled: true,
      );

      await repo.save(config, apiKey: 'sk-very-secret-key');

      final rows = await db.select(db.providers).get();
      expect(rows, hasLength(1));
      expect(rows.single.baseUrl, 'https://api.deepseek.com/v1');
      expect(rows.single.modelMap, contains('deepseek-chat'));
      expect(rows.single.modelMap, isNot(contains('very-secret')));
      expect(rows.single.keyRef, 'mockmate.provider.scorer');
      expect(secure.values['mockmate.provider.scorer'], 'sk-very-secret-key');

      final loaded = await repo.loadAll();
      final scorer = loaded.firstWhere(
        (ProviderConfig c) => c.role == ProviderRole.scorer,
      );
      expect(scorer.model, 'deepseek-chat');
      expect(scorer.temperature, 0.2);
      expect(scorer.enabled, true);
      final key = await repo.loadKey(ProviderRole.scorer);
      expect(key, 'sk-very-secret-key');
    },
  );

  test('rejects silent keychain write failures', () async {
    final repo = ProviderRepository(db, _SilentSecureStore());
    await expectLater(
      repo.save(
        ProviderConfig.defaults(ProviderRole.interviewer),
        apiKey: 'sk-lost',
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('missing DB rows fall back to defaults without keys', () async {
    final repo = ProviderRepository(db, secure);
    final configs = await repo.loadAll();
    expect(configs, hasLength(ProviderRole.values.length));
    expect(configs.first.role, ProviderRole.interviewer);
    expect(await repo.loadKey(ProviderRole.interviewer), isNull);
  });

  test('saving without apiKey keeps the existing key', () async {
    final repo = ProviderRepository(db, secure);
    await repo.save(
      ProviderConfig.defaults(ProviderRole.interviewer),
      apiKey: 'sk-one',
    );
    await repo.save(
      ProviderConfig.defaults(ProviderRole.interviewer)
          .copyWith(model: 'other-model'),
    );
    expect(await repo.loadKey(ProviderRole.interviewer), 'sk-one');
  });

  test('preferences round-trip through settings table', () async {
    final repo = PreferencesRepository(db);
    expect((await repo.load()).themeMode, ThemeMode.system);

    await repo.save(
      const AppPreferences(themeMode: ThemeMode.dark, localeCode: 'en'),
    );
    final loaded = await repo.load();
    expect(loaded.themeMode, ThemeMode.dark);
    expect(loaded.localeCode, 'en');

    await repo.save(loaded.copyWith(clearLocale: true));
    expect((await repo.load()).localeCode, isNull);
  });

  test('float32 vector codec round-trips', () {
    final bytes = encodeFloat32(<double>[0.25, -1.5, 3.0]);
    expect(bytes.length, 12);
    expect(decodeFloat32(bytes), <double>[0.25, -1.5, 3.0]);
  });

  test('base URL validation only allows http(s)', () {
    expect(
      parseProviderBaseUrl('https://api.deepseek.com/v1').host,
      'api.deepseek.com',
    );
    expect(parseProviderBaseUrl('http://127.0.0.1:11434'), isNotNull);
    expect(
      () => parseProviderBaseUrl('ftp://example.com'),
      throwsFormatException,
    );
    expect(() => parseProviderBaseUrl('not a url'), throwsFormatException);
  });
}
