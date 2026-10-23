import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// 为内置种子题库生成 manifest.json（T-010/T-012 的本地工具）。
///
/// 用法：dart run tool/generate_seed_manifest.dart [目录] [bankVersion]
/// 说明：`signature` 为开发占位；正式发布由 T-016 用 Ed25519 私钥签名。
Future<void> main(List<String> args) async {
  final root = Directory(args.isNotEmpty ? args[0] : 'assets/bank_seed');
  final version = args.length > 1 ? args[1] : '2026.10.1';
  if (!root.existsSync()) {
    stderr.writeln('目录不存在: ${root.path}');
    exitCode = 2;
    return;
  }

  final questionsDir = Directory('${root.path}/questions');
  final files = <File>[];
  if (questionsDir.existsSync()) {
    for (final entity in questionsDir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.yaml')) files.add(entity);
    }
  }
  files.sort((File a, File b) => a.path.compareTo(b.path));

  final entries = <Map<String, Object?>>[];
  for (final file in files) {
    final bytes = file.readAsBytesSync();
    entries.add(<String, Object?>{
      'path': _relative(file.path, root.path),
      'sha256': sha256.convert(bytes).toString(),
      'bytes': bytes.length,
    });
  }

  final manifest = <String, Object?>{
    'schemaVersion': 1,
    'bankVersion': version,
    'minAppVersion': '0.5.0',
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'gitCommit': Platform.environment['GIT_COMMIT'] ?? 'seed',
    'counts': <String, Object?>{'questions': files.length, 'experiences': 0},
    'files': entries,
    'assets': <Object?>[],
    'signature': 'ed25519:seed-dev',
  };
  final manifestFile = File('${root.path}/manifest.json');
  manifestFile.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(manifest)}\n',
  );
  stdout.writeln(
    '已写入 ${manifestFile.path}: ${files.length} 道题, version=$version',
  );
}

String _relative(String path, String root) {
  final normalizedRoot = root.endsWith('/') ? root : '$root/';
  return path.startsWith(normalizedRoot)
      ? path.substring(normalizedRoot.length)
      : path;
}
