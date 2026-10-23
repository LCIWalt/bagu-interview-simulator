import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/contracts/contracts.dart';
import '../../../core/util/app_logger.dart';
import 'bank_manifest_codec.dart';
import 'bank_parser.dart';
import 'bank_repository_impl.dart';

/// 首次启动（或种子题库版本升级）时把 `assets/bank_seed` 装进 SQLite。
///
/// 种子内容在构建前用 `tool/validate_bank.dart` 校验；运行时再校验一次，
/// 单题损坏只跳过该题并记日志，不阻塞整体安装。
class SeedBankInstaller {
  SeedBankInstaller(
    this._repository, {
    AssetBundle? bundle,
    this.logger,
    this.assetRoot = 'assets/bank_seed',
  }) : _bundle = bundle ?? rootBundle;

  final BankRepositoryImpl _repository;
  final AssetBundle _bundle;
  final AppLogger? logger;
  final String assetRoot;

  static String manifestPath(String root) => '$root/manifest.json';

  Future<bool> installIfNeeded({bool force = false}) async {
    // 使用 bytes + 同步 UTF-8 解码：manifest 现已超过 50KB，loadString 会走
    // compute isolate，在 widget test 的 fake async 下会卡住。
    final data = await _bundle.load(manifestPath(assetRoot));
    final raw = utf8.decode(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('bank_seed manifest.json 必须是对象');
    }
    final manifest = BankManifestCodec.fromJson(decoded);
    final current = await _repository.installed();
    if (!force && current?.bankVersion == manifest.bankVersion) {
      logger?.debug('bank', 'seed ${manifest.bankVersion} 已安装，跳过');
      return false;
    }

    final assetManifest = await AssetManifest.loadFromAssetBundle(_bundle);
    final prefix = '$assetRoot/questions/';
    final paths =
        assetManifest
            .listAssets()
            .where(
              (String path) =>
                  path.startsWith(prefix) && path.endsWith('.yaml'),
            )
            .toList(growable: false)
          ..sort();
    if (paths.isEmpty) {
      throw StateError('bank_seed 中没有题目资源（$prefix）');
    }

    final parser = BankQuestionParser(bankVersion: manifest.bankVersion);
    final questions = <Question>[];
    for (final path in paths) {
      final result = parser.parse(await _bundle.loadString(path), path);
      if (result.question == null) {
        final messages = result.issues
            .map((Object e) => e.toString())
            .join('; ');
        logger?.warn('bank', messages);
        continue;
      }
      if (result.issues.isNotEmpty) {
        logger?.warn('bank', '$path 有非致命问题，已跳过');
        continue;
      }
      questions.add(result.question!);
    }
    if (questions.isEmpty) {
      throw StateError('bank_seed 没有可用的题目');
    }

    await _repository.upsertQuestions(questions);
    await _repository.markOrphaned(
      questions.map((Question q) => q.id).toSet(),
      bankVersion: manifest.bankVersion,
    );
    await _repository.recordInstalledManifest(manifest, activeDir: assetRoot);
    logger?.info(
      'bank',
      '种子题库已安装：${questions.length} 题，版本 ${manifest.bankVersion}',
    );
    return true;
  }
}
