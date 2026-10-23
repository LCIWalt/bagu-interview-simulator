import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/app/providers.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/core/design/theme.dart';
import 'package:mockmate/features/bank/data/bank_repository_impl.dart';
import 'package:mockmate/features/bank/data/update/bank_update_service.dart';
import 'package:mockmate/features/bank/data/update/bank_update_source.dart';
import 'package:mockmate/features/bank/data/update/manifest_verifier.dart';
import 'package:mockmate/features/bank/presentation/update/bank_update_sheet.dart';
import 'package:mockmate/l10n/generated/app_localizations.dart';

class _FailingSource implements BankUpdateSource {
  @override
  Future<RemoteManifest?> fetchManifest({
    String? etag,
    CancelToken? cancel,
  }) async {
    throw const NetworkFailure('offline');
  }

  @override
  Stream<List<int>> download(String url, {CancelToken? cancel}) =>
      const Stream<List<int>>.empty();
}

void main() {
  testWidgets('update sheet surfaces a clear failure and offers retry', (
    WidgetTester tester,
  ) async {
    final db = AppDatabase.memory();
    final root = Directory.systemTemp.createTempSync('bank_ui_update_');
    addTearDown(() async {
      await db.close();
      if (root.existsSync()) root.deleteSync(recursive: true);
    });
    final repo = BankRepositoryImpl(db);
    final service = BankUpdateService(
      db: db,
      repository: repo,
      source: _FailingSource(),
      verifier: ManifestSignatureVerifier(publicKeyBytes: Uint8List(32)),
      currentAppVersion: '0.5.0',
      bankRoot: root,
      checkThrottle: Duration.zero,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          bankRepositoryProvider.overrideWithValue(repo),
          bankUpdateServiceProvider.overrideWith((Ref ref) async => service),
        ],
        child: MaterialApp(
          theme: buildMockTheme(Brightness.light),
          locale: const Locale('zh'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const Scaffold(body: BankUpdateSheet()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('尚未安装题库'), findsOneWidget);
    await tester.tap(find.text('检查更新'));
    await tester.pumpAndSettle();

    expect(find.text('更新失败'), findsOneWidget);
    expect(find.text('网络连接失败，请检查网络或代理。'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
  });
}
