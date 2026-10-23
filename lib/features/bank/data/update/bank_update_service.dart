import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/core/util/app_logger.dart';
import 'package:path/path.dart' as p;

import '../bank_manifest_codec.dart';
import '../bank_parser.dart';
import '../bank_repository_impl.dart';
import '../bank_validator.dart';
import 'bank_archive.dart';
import 'bank_update_runner.dart';
import 'bank_update_source.dart';
import 'manifest_verifier.dart';

/// 题库更新管线（指南 §6.3）：检查 → 下载 → 校验 → staging → 事务切换。
///
/// 失败语义：任何一步失败都不改动现有题库；`question_local` 永不被触碰。
/// 成功后在 `bankRoot/versions/` 保留最近 2 个版本。
class BankUpdateService implements BankUpdateRunner {
  BankUpdateService({
    required this.db,
    required this.repository,
    required this.source,
    required this.verifier,
    required this.currentAppVersion,
    required this.bankRoot,
    this.logger,
    DateTime Function()? now,
    this.checkThrottle = const Duration(minutes: 15),
    this.maxArchiveBytes = 50 * 1024 * 1024,
    this.maxUncompressedBytes = 100 * 1024 * 1024,
  }) : _now = now ?? DateTime.now;

  final AppDatabase db;
  final BankRepositoryImpl repository;
  final BankUpdateSource source;
  final ManifestSignatureVerifier verifier;
  final String currentAppVersion;
  final Directory bankRoot;
  final AppLogger? logger;
  final DateTime Function() _now;
  final Duration checkThrottle;
  final int maxArchiveBytes;
  final int maxUncompressedBytes;

  static const String _etagKey = 'bank.update.etag';
  static const String _checkedAtKey = 'bank.update.checkedAt';
  static const String _remoteCacheKey = 'bank.update.remoteManifest';

  @override
  Stream<BankUpdateProgress> run({
    required BankChannel channel,
    bool force = false,
    CancelToken? cancel,
    String? mirrorBase,
  }) async* {
    yield const BankChecking();
    Directory? staging;
    String? uncommittedDir;

    try {
      cancel?.throwIfCancelled();
      final installed = await repository.installed();
      final remote = await _remoteManifest(force: force, cancel: cancel);
      if (remote == null) {
        yield BankUpToDate(installed);
        return;
      }

      final manifest = remote.manifest;
      final comparison = installed == null
          ? 1
          : compareBankVersions(manifest.bankVersion, installed.bankVersion);
      if (!force && comparison <= 0) {
        yield BankUpToDate(installed);
        return;
      }
      if (compareBankVersions(manifest.minAppVersion, currentAppVersion) > 0) {
        yield BankUpdateFailed(
          UnknownFailure(
            '题库需要 App ≥ ${manifest.minAppVersion}（当前 $currentAppVersion），请先升级 App',
          ),
        );
        return;
      }

      final asset = _pickAsset(manifest);
      if (asset == null) {
        yield const BankUpdateFailed(
          ParseFailure('manifest 中没有 tar.zst/zip 题库包'),
        );
        return;
      }
      if (asset.bytes > maxArchiveBytes) {
        yield const BankUpdateFailed(ParseFailure('题库包超过 50MB 上限'));
        return;
      }

      final url = _resolveAssetUrl(remote, asset.name, mirrorBase);
      final builder = BytesBuilder(copy: false);
      var received = 0;
      await for (final chunk in source.download(url, cancel: cancel)) {
        cancel?.throwIfCancelled();
        received += chunk.length;
        if (received > maxArchiveBytes) {
          throw const NetworkFailure('下载超过 50MB 上限');
        }
        builder.add(chunk);
        yield BankDownloading(receivedBytes: received, totalBytes: asset.bytes);
      }
      final archiveBytes = builder.takeBytes();
      if (asset.bytes > 0 && received != asset.bytes) {
        throw ParseFailure('下载大小 $received 与 manifest ${asset.bytes} 不一致');
      }
      final digest = sha256.convert(archiveBytes).toString();
      if (digest != asset.sha256.toLowerCase()) {
        throw const ParseFailure('SHA-256 校验失败');
      }
      yield const BankVerifying('sha256');

      if (!await verifier.verify(manifest)) {
        throw const ParseFailure('manifest Ed25519 签名校验失败');
      }
      yield const BankVerifying('signature');

      final files = BankArchive(maxUncompressedBytes: maxUncompressedBytes)
          .extract(archiveBytes);
      _verifyFileHashes(manifest, files);

      staging = Directory(
        p.join(
          bankRoot.path,
          'staging-${manifest.bankVersion}-${_now().microsecondsSinceEpoch}',
        ),
      );
      await staging.create(recursive: true);
      await _writeFiles(staging, files);
      final manifestFile = File(p.join(staging.path, 'manifest.json'));
      await manifestFile.writeAsString(jsonEncode(manifest.toJson()));

      final report = const BankValidator().validateDirectory(staging);
      if (!report.ok) {
        final first = report.sortedIssues
            .take(3)
            .map((Object e) => e.toString())
            .join('; ');
        throw ParseFailure('schema 校验失败：$first');
      }
      if (manifest.questionCount > 0 &&
          report.questionCount != manifest.questionCount) {
        throw ParseFailure(
          '题目数量不一致：manifest ${manifest.questionCount}，实际 ${report.questionCount}',
        );
      }
      yield const BankVerifying('schema');
      cancel?.throwIfCancelled();

      final questions = report.parsed
          .map((ParsedQuestion parsed) => parsed.question)
          .whereType<Question>()
          .toList(growable: false);
      final versionsDir = Directory(p.join(bankRoot.path, 'versions'));
      await versionsDir.create(recursive: true);
      final target = Directory(p.join(versionsDir.path, manifest.bankVersion));
      if (target.existsSync()) await target.delete(recursive: true);
      await _moveDirectory(staging, target);
      staging = null;
      uncommittedDir = target.path;

      yield BankActivating(manifest.bankVersion);
      await repository.applyUpdate(
        questions: questions,
        manifest: manifest,
        activeDir: target.path,
      );
      uncommittedDir = null;

      await _cleanupOldVersions(versionsDir, keep: 2);
      logger?.info(
        'bank',
        '题库已更新到 ${manifest.bankVersion}（${questions.length} 题）',
      );
      yield BankUpdated(manifest);
    } on Failure catch (failure) {
      await _cleanup(staging, uncommittedDir);
      logger?.warn('bank', '更新失败：${failure.message}');
      yield BankUpdateFailed(failure);
    } on FormatException catch (error, stack) {
      await _cleanup(staging, uncommittedDir);
      yield BankUpdateFailed(
        ParseFailure(
          '更新包格式错误：${error.message}',
          cause: error,
          stackTrace: stack,
        ),
      );
    } on Object catch (error, stack) {
      await _cleanup(staging, uncommittedDir);
      logger?.error('bank', '更新异常', error: error, stackTrace: stack);
      yield BankUpdateFailed(
        UnknownFailure('更新异常：$error', cause: error, stackTrace: stack),
      );
    }
  }

  Future<RemoteManifest?> _remoteManifest({
    required bool force,
    CancelToken? cancel,
  }) async {
    final checkedAt = await _readSetting(_checkedAtKey);
    final etag = await _readSetting(_etagKey);
    final withinThrottle =
        !force &&
        checkedAt != null &&
        _now().difference(
              DateTime.tryParse(checkedAt) ??
                  DateTime.fromMillisecondsSinceEpoch(0),
            ) <
            checkThrottle;
    if (withinThrottle) {
      final cached = await _readCachedRemote();
      if (cached != null) return cached;
    }

    final remote = await source.fetchManifest(etag: etag, cancel: cancel);
    await _writeSetting(_checkedAtKey, _now().toUtc().toIso8601String());
    if (remote == null) return null;
    await _writeSetting(_etagKey, remote.etag ?? '');
    await _writeSetting(
      _remoteCacheKey,
      jsonEncode(<String, Object?>{
        'manifest': remote.rawJson,
        'urls': remote.assetUrls,
        'etag': remote.etag,
      }),
    );
    return remote;
  }

  Future<RemoteManifest?> _readCachedRemote() async {
    final raw = await _readSetting(_remoteCacheKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final manifestJson = decoded['manifest'];
      final urls = decoded['urls'];
      if (manifestJson is! Map<String, dynamic>) return null;
      return RemoteManifest(
        manifest: BankManifestCodec.fromJson(manifestJson),
        assetUrls: urlsWith(urls),
        etag: decoded['etag']?.toString(),
        rawJson: manifestJson,
      );
    } on FormatException {
      return null;
    }
  }

  Map<String, String> urlsWith(Object? raw) {
    if (raw is! Map) return const <String, String>{};
    return <String, String>{
      for (final entry in raw.entries) '${entry.key}': '${entry.value}',
    };
  }

  BankAsset? _pickAsset(BankManifest manifest) {
    for (final suffix in <String>['.tar.zst', '.tar.gz', '.zip']) {
      for (final asset in manifest.assets) {
        if (asset.name.endsWith(suffix)) return asset;
      }
    }
    return null;
  }

  String _resolveAssetUrl(
    RemoteManifest remote,
    String name,
    String? mirrorBase,
  ) {
    if (mirrorBase != null && mirrorBase.trim().isNotEmpty) {
      final base = mirrorBase.trim().replaceAll(RegExp(r'/+$'), '');
      return '$base/$name';
    }
    final url = remote.assetUrls[name];
    if (url == null) throw ParseFailure('release 中没有资产 $name');
    return url;
  }

  void _verifyFileHashes(BankManifest manifest, Map<String, Uint8List> files) {
    if (manifest.files.isEmpty) return;
    for (final entry in manifest.files) {
      final bytes = files[entry.path];
      if (bytes == null) throw ParseFailure('题库包缺少文件 ${entry.path}');
      if (sha256.convert(bytes).toString() != entry.sha256.toLowerCase()) {
        throw ParseFailure('文件哈希不匹配：${entry.path}');
      }
    }
  }

  Future<void> _writeFiles(
    Directory target,
    Map<String, Uint8List> files,
  ) async {
    for (final entry in files.entries) {
      final file = File(p.join(target.path, entry.key));
      await file.parent.create(recursive: true);
      await file.writeAsBytes(entry.value, flush: true);
    }
  }

  Future<void> _moveDirectory(Directory from, Directory to) async {
    try {
      await from.rename(to.path);
    } on FileSystemException {
      await _copyDirectory(from, to);
      await from.delete(recursive: true);
    }
  }

  Future<void> _copyDirectory(Directory from, Directory to) async {
    await to.create(recursive: true);
    await for (final entity in from.list(recursive: true)) {
      if (entity is! File) continue;
      final relative = p.relative(entity.path, from: from.path);
      final destination = File(p.join(to.path, relative));
      await destination.parent.create(recursive: true);
      await entity.copy(destination.path);
    }
  }

  Future<void> _cleanup(Directory? staging, String? uncommittedDir) async {
    try {
      if (staging != null && staging.existsSync()) {
        await staging.delete(recursive: true);
      }
      if (uncommittedDir != null) {
        final dir = Directory(uncommittedDir);
        if (dir.existsSync()) await dir.delete(recursive: true);
      }
    } on FileSystemException {
      // 清理失败不影响现有版本。
    }
  }

  Future<void> _cleanupOldVersions(
    Directory versionsDir, {
    required int keep,
  }) async {
    try {
      final dirs = await versionsDir
          .list()
          .where((FileSystemEntity entity) => entity is Directory)
          .cast<Directory>()
          .toList();
      dirs.sort((Directory a, Directory b) {
        final av = p.basename(a.path);
        final bv = p.basename(b.path);
        return compareBankVersions(bv, av);
      });
      for (final dir in dirs.skip(keep)) {
        await dir.delete(recursive: true);
      }
    } on FileSystemException {
      // 保留多余版本无碍正确性。
    }
  }

  Future<String?> _readSetting(String key) async {
    final row = await (db.select(
      db.settings,
    )..where((Settings t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _writeSetting(String key, String value) async {
    await db
        .into(db.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(key: key, value: value, updatedAt: _now()),
        );
  }
}

/// 比较 `YYYY.M.P`；任何非数字段按 0 处理。
int compareBankVersions(String a, String b) {
  List<int> parse(String value) => value
      .split('.')
      .map((String part) => int.tryParse(part.trim()) ?? 0)
      .toList(growable: false);
  final left = parse(a);
  final right = parse(b);
  final length = left.length > right.length ? left.length : right.length;
  for (var i = 0; i < length; i++) {
    final l = i < left.length ? left[i] : 0;
    final r = i < right.length ? right[i] : 0;
    if (l != r) return l.compareTo(r);
  }
  return 0;
}
