import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/features/bank/data/bank_manifest_codec.dart';
import 'package:mockmate/features/bank/data/bank_repository_impl.dart';
import 'package:mockmate/features/bank/data/question_local_repository.dart';
import 'package:mockmate/features/bank/data/update/bank_update_service.dart';
import 'package:mockmate/features/bank/data/update/bank_update_source.dart';
import 'package:mockmate/features/bank/data/update/manifest_verifier.dart';

final Uint8List _seed = Uint8List.fromList(
  List<int>.generate(32, (int i) => i + 1),
);
final Uint8List _otherSeed = Uint8List.fromList(
  List<int>.generate(32, (int i) => 99 - i),
);
late List<int> _publicKey;

class _FakeSource implements BankUpdateSource {
  _FakeSource({required this.remote, required this.archive, this.error});

  final RemoteManifest? remote;
  final Uint8List archive;
  final Failure? error;
  int fetchCount = 0;
  int downloadCount = 0;

  @override
  Future<RemoteManifest?> fetchManifest({
    String? etag,
    CancelToken? cancel,
  }) async {
    fetchCount++;
    if (error != null) throw error!;
    return remote;
  }

  @override
  Stream<List<int>> download(String url, {CancelToken? cancel}) async* {
    downloadCount++;
    if (archive.isEmpty) return;
    final half = archive.length ~/ 2;
    yield archive.sublist(0, half);
    yield archive.sublist(half);
  }
}

String _validYaml(String id, {String title = '更新后的题目'}) =>
    '''
id: $id
title: "$title"
topics: [go]
role: backend
level: mid
difficulty: 2
type: knowledge
answer:
  summary: "示例答案"
  keyPoints:
    - "示例评分点"
source:
  url: https://example.com
  title: "example"
  license: MIT
status: community
updatedAt: 2026-10-22
''';

class _Package {
  _Package({required this.remote, required this.archive});

  final RemoteManifest remote;
  final Uint8List archive;
}

Future<_Package> _package({
  required String version,
  String id = 'upd-001',
  String title = '更新后的题目',
  String minAppVersion = '0.5.0',
  bool validQuestion = true,
  bool badSignature = false,
  bool badAssetSha = false,
  bool badFileHash = false,
}) async {
  final questionBytes = utf8.encode(
    validQuestion ? _validYaml(id, title: title) : 'id: $id\n',
  );
  final filePath = 'questions/backend/$id.yaml';
  final archive = Archive()
    ..addFile(ArchiveFile(filePath, questionBytes.length, questionBytes));
  final zipBytes = Uint8List.fromList(ZipEncoder().encode(archive));
  final assetName = 'bank-$version.zip';
  final manifestJson = <String, Object?>{
    'schemaVersion': 1,
    'bankVersion': version,
    'minAppVersion': minAppVersion,
    'generatedAt': '2026-10-22T00:00:00Z',
    'gitCommit': 'test',
    'counts': <String, Object?>{'questions': 1, 'experiences': 0},
    'files': <Object?>[
      <String, Object?>{
        'path': filePath,
        'sha256': badFileHash
            ? '0' * 64
            : sha256.convert(questionBytes).toString(),
        'bytes': questionBytes.length,
      },
    ],
    'assets': <Object?>[
      <String, Object?>{
        'name': assetName,
        'sha256': badAssetSha ? '0' * 64 : sha256.convert(zipBytes).toString(),
        'bytes': zipBytes.length,
      },
    ],
    'signature': '',
  };
  final unsigned = BankManifestCodec.fromJson(manifestJson);
  final signature = await signManifest(
    manifest: unsigned.toJson(),
    privateKeyBytes: badSignature ? _otherSeed : _seed,
  );
  final signedJson = unsigned.toJson()..['signature'] = signature;
  final remote = RemoteManifest(
    manifest: BankManifestCodec.fromJson(signedJson),
    assetUrls: <String, String>{assetName: 'https://example.com/$assetName'},
    etag: 'etag-$version',
    rawJson: signedJson,
  );
  return _Package(remote: remote, archive: zipBytes);
}

void main() {
  late AppDatabase db;
  late BankRepositoryImpl repo;
  late QuestionLocalRepository local;
  late Directory root;

  setUpAll(() async {
    final keyPair = await Ed25519().newKeyPairFromSeed(_seed);
    _publicKey = (await keyPair.extractPublicKey()).bytes;
  });

  setUp(() {
    db = AppDatabase.memory();
    repo = BankRepositoryImpl(db);
    local = QuestionLocalRepository(db);
    root = Directory.systemTemp.createTempSync('bank_update_');
  });
  tearDown(() async {
    await db.close();
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  BankUpdateService service(_FakeSource source, {String appVersion = '0.5.0'}) {
    return BankUpdateService(
      db: db,
      repository: repo,
      source: source,
      verifier: ManifestSignatureVerifier(publicKeyBytes: _publicKey),
      currentAppVersion: appVersion,
      bankRoot: root,
      checkThrottle: Duration.zero,
      now: () => DateTime.utc(2026, 10, 22),
    );
  }

  test('installs a signed package, persists manifest and versions', () async {
    final pkg = await _package(version: '2026.10.2');
    final source = _FakeSource(remote: pkg.remote, archive: pkg.archive);
    final events = await service(source)
        .run(channel: BankChannel.stable, force: true)
        .toList();

    expect(events.first, isA<BankChecking>());
    expect(events.whereType<BankDownloading>(), isNotEmpty);
    expect(
      events.last,
      isA<BankUpdated>(),
      reason: events.last is BankUpdateFailed
          ? (events.last as BankUpdateFailed).failure.toString()
          : events.toString(),
    );
    expect(
      events.whereType<BankVerifying>().map((BankVerifying e) => e.stage),
      containsAll(<String>['sha256', 'signature', 'schema']),
    );
    expect(events.whereType<BankActivating>(), hasLength(1));

    expect(await repo.countQuestions(), 1);
    final installed = await repo.installed();
    expect(installed?.bankVersion, '2026.10.2');
    final meta = await db.select(db.bankMeta).getSingle();
    expect(meta.signatureOk, isTrue);
    expect(Directory(meta.activeDir).existsSync(), isTrue);
  });

  test('bad asset sha never affects the current bank', () async {
    final pkg = await _package(version: '2026.10.2', badAssetSha: true);
    final events = await service(
      _FakeSource(remote: pkg.remote, archive: pkg.archive),
    ).run(channel: BankChannel.stable, force: true).toList();
    expect(events.last, isA<BankUpdateFailed>());
    expect((events.last as BankUpdateFailed).failure, isA<ParseFailure>());
    expect(await repo.countQuestions(), 0);
    expect(await repo.installed(), isNull);
    expect(Directory('${root.path}/versions').existsSync(), isFalse);
  });

  test('rejects a manifest signed by another key', () async {
    final pkg = await _package(version: '2026.10.2', badSignature: true);
    final events = await service(
      _FakeSource(remote: pkg.remote, archive: pkg.archive),
    ).run(channel: BankChannel.stable, force: true).toList();
    expect(events.last, isA<BankUpdateFailed>());
    expect((events.last as BankUpdateFailed).failure.message, contains('签名'));
    expect(await repo.countQuestions(), 0);
  });

  test('rejects per-file hash mismatch', () async {
    final pkg = await _package(version: '2026.10.2', badFileHash: true);
    final events = await service(
      _FakeSource(remote: pkg.remote, archive: pkg.archive),
    ).run(channel: BankChannel.stable, force: true).toList();
    expect(events.last, isA<BankUpdateFailed>());
    expect(await repo.countQuestions(), 0);
  });

  test('blocks updates that require a newer app', () async {
    final pkg = await _package(version: '2026.10.2', minAppVersion: '9.9.9');
    final source = _FakeSource(remote: pkg.remote, archive: pkg.archive);
    final events = await service(source)
        .run(channel: BankChannel.stable, force: true)
        .toList();
    final failed = events.last as BankUpdateFailed;
    expect(failed.failure.message, contains('9.9.9'));
    expect(source.downloadCount, 0);
  });

  test('returns BankUpToDate for same version without downloading', () async {
    final first = await _package(version: '2026.10.2');
    await service(_FakeSource(remote: first.remote, archive: first.archive))
        .run(channel: BankChannel.stable, force: true)
        .toList();

    final second = await _package(version: '2026.10.2');
    final source = _FakeSource(remote: second.remote, archive: second.archive);
    final events = await service(source)
        .run(channel: BankChannel.stable)
        .toList();
    expect(events.last, isA<BankUpToDate>());
    expect(source.downloadCount, 0);
  });

  test('rolls back when the new bank fails schema validation', () async {
    final good = await _package(version: '2026.10.2', title: '旧标题');
    await service(_FakeSource(remote: good.remote, archive: good.archive))
        .run(channel: BankChannel.stable, force: true)
        .toList();

    final bad = await _package(version: '2026.10.3', validQuestion: false);
    final events = await service(
      _FakeSource(remote: bad.remote, archive: bad.archive),
    ).run(channel: BankChannel.stable, force: true).toList();
    expect(events.last, isA<BankUpdateFailed>());
    expect((await repo.installed())?.bankVersion, '2026.10.2');
    expect((await repo.byId('upd-001'))?.title, '旧标题');
    final versions = Directory('${root.path}/versions')
        .listSync()
        .whereType<Directory>()
        .map((Directory d) => d.path.split('/').last);
    expect(versions, <String>['2026.10.2']);
  });

  test('keeps user notes across updates and only keeps 2 versions', () async {
    for (final version in <String>['2026.10.2', '2026.10.3', '2026.10.4']) {
      final pkg = await _package(version: version);
      await service(_FakeSource(remote: pkg.remote, archive: pkg.archive))
          .run(channel: BankChannel.stable, force: true)
          .toList();
      if (version == '2026.10.2') {
        await local.saveNote('upd-001', '我的笔记');
      }
    }
    expect((await local.get('upd-001'))?.noteMd, '我的笔记');
    final versions =
        Directory('${root.path}/versions')
            .listSync()
            .whereType<Directory>()
            .map((Directory d) => d.path.split('/').last)
            .toList()
          ..sort();
    expect(versions, <String>['2026.10.3', '2026.10.4']);

    final meta = await db.select(db.bankMeta).getSingle();
    expect(meta.version, '2026.10.4');
  });

  test('network error keeps the current version', () async {
    final good = await _package(version: '2026.10.2');
    await service(_FakeSource(remote: good.remote, archive: good.archive))
        .run(channel: BankChannel.stable, force: true)
        .toList();

    final events = await service(
      _FakeSource(
        remote: null,
        archive: Uint8List(0),
        error: const NetworkFailure('offline'),
      ),
    ).run(channel: BankChannel.stable, force: true).toList();
    expect(events.last, isA<BankUpdateFailed>());
    expect((await repo.installed())?.bankVersion, '2026.10.2');
  });
}
