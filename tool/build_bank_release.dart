import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:mockmate/features/bank/data/bank_validator.dart';
import 'package:mockmate/features/bank/data/update/manifest_verifier.dart';
import 'package:path/path.dart' as p;

/// 构建题库 Release（T-019）：校验 → tar.zst → manifest → Ed25519 签名。
///
/// 用法：
///   BANK_SIGNING_KEY=`<base64 seed>` dart run tool/build_bank_release.dart \
///     assets/bank_seed 2026.10.2 build/bank-release
///
/// 私钥回退到 `.toolchain/bank_signing_key.txt` 第一行（本地开发）。
Future<void> main(List<String> args) async {
  if (args.length < 2) {
    stderr.writeln(
      '用法: dart run tool/build_bank_release.dart <题库目录> <版本> [输出目录]',
    );
    exitCode = 2;
    return;
  }
  final root = Directory(args[0]);
  final version = args[1];
  final output = Directory(args.length > 2 ? args[2] : 'build/bank-release');
  if (!root.existsSync()) {
    stderr.writeln('题库目录不存在: ${root.path}');
    exitCode = 2;
    return;
  }

  final report = const BankValidator().validateDirectory(root);
  if (!report.ok) {
    for (final issue in report.sortedIssues) {
      stderr.writeln(issue.format());
    }
    stderr.writeln('校验失败，未打包。');
    exitCode = 1;
    return;
  }

  final privateKey = _privateKey();
  if (privateKey == null) {
    stderr.writeln('缺少签名私钥：BANK_SIGNING_KEY 或 .toolchain/bank_signing_key.txt');
    exitCode = 2;
    return;
  }

  await output.create(recursive: true);
  final files = _collectFiles(root);
  final archive = Archive();
  for (final file in files) {
    final bytes = await file.readAsBytes();
    archive.addFile(
      ArchiveFile(_relative(file.path, root.path), bytes.length, bytes),
    );
  }
  final tarBytes = Uint8List.fromList(TarEncoder().encode(archive));
  final tmpTar = File(p.join(Directory.systemTemp.path, 'bank-$version.tar'));
  await tmpTar.writeAsBytes(tarBytes, flush: true);
  final archiveName = 'bank-$version.tar.zst';
  final archivePath = p.join(output.path, archiveName);
  final zstd = await Process.run('zstd', <String>[
    '-19',
    '-f',
    '-o',
    archivePath,
    tmpTar.path,
  ]);
  await tmpTar.delete();
  if (zstd.exitCode != 0) {
    stderr.writeln('zstd 压缩失败（需要本机安装 zstd）：${zstd.stderr}');
    exitCode = 2;
    return;
  }
  final archiveBytes = await File(archivePath).readAsBytes();

  final manifest = <String, Object?>{
    'schemaVersion': 1,
    'bankVersion': version,
    'minAppVersion': '0.5.0',
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'gitCommit': Platform.environment['GIT_COMMIT'] ?? 'local',
    'counts': <String, Object?>{
      'questions': report.questionCount,
      'experiences': files
          .where((File f) => f.path.contains('/experiences/'))
          .length,
    },
    'files': <Object?>[
      for (final file in files)
        <String, Object?>{
          'path': _relative(file.path, root.path),
          'sha256': sha256.convert(await file.readAsBytes()).toString(),
          'bytes': await file.length(),
        },
    ],
    'assets': <Object?>[
      <String, Object?>{
        'name': archiveName,
        'sha256': sha256.convert(archiveBytes).toString(),
        'bytes': archiveBytes.length,
      },
    ],
    'signature': '',
  };
  manifest['signature'] = await signManifest(
    manifest: manifest,
    privateKeyBytes: privateKey,
  );
  final manifestFile = File(p.join(output.path, 'manifest.json'));
  await manifestFile.writeAsString(
    '${const JsonEncoder.withIndent('  ').convert(manifest)}\n',
  );
  stdout
    ..writeln('题库发布包已生成：')
    ..writeln('  ${manifestFile.path}')
    ..writeln(
      '  $archivePath（${(archiveBytes.length / 1024 / 1024).toStringAsFixed(2)} MB）',
    )
    ..writeln('  题目：${report.questionCount}，文件：${files.length}');
}

List<int>? _privateKey() {
  final env = Platform.environment['BANK_SIGNING_KEY'];
  if (env != null && env.trim().isNotEmpty) {
    try {
      return base64Decode(env.trim());
    } on FormatException {
      return null;
    }
  }
  final file = File('.toolchain/bank_signing_key.txt');
  if (!file.existsSync()) return null;
  final lines = file.readAsLinesSync();
  final first = lines.isEmpty ? null : lines.first.trim();
  if (first == null || first.isEmpty) return null;
  try {
    return base64Decode(first);
  } on FormatException {
    return null;
  }
}

List<File> _collectFiles(Directory root) {
  final files = <File>[];
  for (final entity in root.listSync(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    if (p.basename(entity.path) == 'manifest.json') continue;
    if (entity.path.contains('${p.separator}.git${p.separator}')) continue;
    files.add(entity);
  }
  files.sort((File a, File b) => a.path.compareTo(b.path));
  return files;
}

String _relative(String path, String root) {
  final normalized = root.endsWith(p.separator) ? root : '$root${p.separator}';
  return path.startsWith(normalized) ? path.substring(normalized.length) : path;
}
