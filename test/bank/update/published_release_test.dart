import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/features/bank/data/bank_manifest_codec.dart';
import 'package:mockmate/features/bank/data/bank_repository_impl.dart';
import 'package:mockmate/features/bank/data/update/bank_public_key.dart';
import 'package:mockmate/features/bank/data/update/bank_update_service.dart';
import 'package:mockmate/features/bank/data/update/bank_update_source.dart';
import 'package:mockmate/features/bank/data/update/manifest_verifier.dart';

class _FileSource implements BankUpdateSource {
  _FileSource(this.manifestFile, this.archiveFile);

  final File manifestFile;
  final File archiveFile;

  @override
  Future<RemoteManifest?> fetchManifest({
    String? etag,
    CancelToken? cancel,
  }) async {
    final json =
        jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>;
    final manifest = BankManifestCodec.fromJson(json);
    final asset = manifest.assets.first;
    return RemoteManifest(
      manifest: manifest,
      assetUrls: <String, String>{asset.name: archiveFile.path},
      etag: 'fixture',
      rawJson: json,
    );
  }

  @override
  Stream<List<int>> download(String url, {CancelToken? cancel}) async* {
    yield await archiveFile.readAsBytes();
  }
}

void main() {
  test(
    'app pulls a release produced by tool/build_bank_release.dart',
    () async {
      final db = AppDatabase.memory();
      final root = Directory.systemTemp.createTempSync('release_pull_');
      addTearDown(() async {
        await db.close();
        if (root.existsSync()) root.deleteSync(recursive: true);
      });
      final repo = BankRepositoryImpl(db);
      final service = BankUpdateService(
        db: db,
        repository: repo,
        source: _FileSource(
          File('test/fixtures/bank_release/manifest.json'),
          File('test/fixtures/bank_release/bank-2026.10.2.tar.zst'),
        ),
        verifier: ManifestSignatureVerifier.fromBase64(kDefaultBankPublicKey),
        currentAppVersion: '0.5.0',
        bankRoot: root,
        checkThrottle: Duration.zero,
      );

      final events = await service
          .run(channel: BankChannel.stable, force: true)
          .toList();
      expect(
        events.last,
        isA<BankUpdated>(),
        reason: events.last is BankUpdateFailed
            ? (events.last as BankUpdateFailed).failure.toString()
            : null,
      );
      expect(await repo.countQuestions(), 16);
      expect((await repo.installed())?.bankVersion, '2026.10.2');
      final drill = await repo.search(const QuestionQuery(text: 'GMP'));
      expect(drill, isNotEmpty);
    },
  );
}
