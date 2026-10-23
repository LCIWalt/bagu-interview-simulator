import 'dart:convert';
import 'dart:io';

import 'bank_issue.dart';
import 'bank_parser.dart';

class BankValidationReport {
  BankValidationReport({
    required this.root,
    required this.parsed,
    required this.issues,
    this.bankVersion = 'seed',
  });

  final String root;
  final List<ParsedQuestion> parsed;
  final List<BankIssue> issues;
  final String bankVersion;

  int get questionCount =>
      parsed.where((ParsedQuestion p) => p.question != null).length;

  bool get ok => issues.isEmpty;

  Iterable<BankIssue> get sortedIssues {
    final list = List<BankIssue>.of(issues)
      ..sort((BankIssue a, BankIssue b) {
        final byFile = a.file.compareTo(b.file);
        if (byFile != 0) return byFile;
        final byLine = a.line.compareTo(b.line);
        return byLine != 0 ? byLine : a.column.compareTo(b.column);
      });
    return list;
  }
}

/// 校验一个题库目录（`questions/**/*.yaml` + 可选 `manifest.json`）。
class BankValidator {
  const BankValidator();

  BankValidationReport validateDirectory(Directory root) {
    final issues = <BankIssue>[];
    final questionsDir = Directory('${root.path}/questions');
    final files = <File>[];
    if (questionsDir.existsSync()) {
      for (final entity in questionsDir.listSync(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File &&
            (entity.path.endsWith('.yaml') || entity.path.endsWith('.yml'))) {
          files.add(entity);
        }
      }
    }
    files.sort((File a, File b) => a.path.compareTo(b.path));

    var bankVersion = 'seed';
    final manifestFile = File('${root.path}/manifest.json');
    if (manifestFile.existsSync()) {
      final parsedManifest = _validateManifest(manifestFile, issues);
      if (parsedManifest != null) bankVersion = parsedManifest;
    } else {
      issues.add(
        BankIssue(
          file: manifestFile.path,
          message: '缺少 manifest.json（题库版本与校验信息）',
        ),
      );
    }

    if (files.isEmpty) {
      issues.add(BankIssue(file: questionsDir.path, message: '没有找到任何题目 YAML'));
    }

    final parser = BankQuestionParser(bankVersion: bankVersion);
    final parsed = <ParsedQuestion>[];
    final seen = <String, String>{};
    for (final file in files) {
      final result = parser.parse(file.readAsStringSync(), file.path);
      parsed.add(result);
      issues.addAll(result.issues);
      final question = result.question;
      if (question == null) continue;
      final previous = seen[question.id];
      if (previous != null) {
        issues.add(
          BankIssue(
            file: file.path,
            message: '重复 id `${question.id}`（已在 $previous 定义）',
            field: 'id',
          ),
        );
      } else {
        seen[question.id] = file.path;
      }
    }

    return BankValidationReport(
      root: root.path,
      parsed: parsed,
      issues: issues,
      bankVersion: bankVersion,
    );
  }

  /// 返回 manifest 中的 bankVersion（合法时）；问题写入 [issues]。
  String? _validateManifest(File file, List<BankIssue> issues) {
    final Object? decoded;
    try {
      decoded = jsonDecode(file.readAsStringSync());
    } on FormatException catch (error) {
      issues.add(
        BankIssue(
          file: file.path,
          message: 'manifest.json 不是合法 JSON：${error.message}',
        ),
      );
      return null;
    }
    if (decoded is! Map<String, dynamic>) {
      issues.add(BankIssue(file: file.path, message: 'manifest.json 根节点必须是对象'));
      return null;
    }
    final schemaVersion = decoded['schemaVersion'];
    if (schemaVersion != 1) {
      issues.add(
        BankIssue(
          file: file.path,
          message: 'schemaVersion 必须为 1',
          field: 'schemaVersion',
        ),
      );
    }
    final bankVersion = decoded['bankVersion'];
    if (bankVersion is! String ||
        !RegExp(r'^\d{4}\.\d{1,2}\.\d{1,3}$').hasMatch(bankVersion)) {
      issues.add(
        BankIssue(
          file: file.path,
          message: 'bankVersion 必须形如 YYYY.M.P',
          field: 'bankVersion',
        ),
      );
    }
    final minAppVersion = decoded['minAppVersion'];
    if (minAppVersion is! String || minAppVersion.isEmpty) {
      issues.add(
        BankIssue(
          file: file.path,
          message: '缺少 minAppVersion',
          field: 'minAppVersion',
        ),
      );
    }
    final files = decoded['files'];
    if (files is! List || files.isEmpty) {
      issues.add(
        BankIssue(file: file.path, message: 'files 必须是非空数组', field: 'files'),
      );
    } else {
      for (var i = 0; i < files.length; i++) {
        final entry = files[i];
        if (entry is! Map<String, dynamic>) {
          issues.add(
            BankIssue(
              file: file.path,
              message: 'files[$i] 必须是对象',
              field: 'files',
            ),
          );
          continue;
        }
        final path = entry['path'];
        final sha = entry['sha256'];
        final bytes = entry['bytes'];
        if (path is! String || path.isEmpty) {
          issues.add(
            BankIssue(
              file: file.path,
              message: 'files[$i].path 缺失',
              field: 'files',
            ),
          );
        }
        if (sha is! String || !RegExp(r'^[a-f0-9]{64}$').hasMatch(sha)) {
          issues.add(
            BankIssue(
              file: file.path,
              message: 'files[$i].sha256 必须是 64 位小写 hex',
            ),
          );
        }
        if (bytes is! int || bytes <= 0) {
          issues.add(
            BankIssue(file: file.path, message: 'files[$i].bytes 必须大于 0'),
          );
        }
      }
    }
    final signature = decoded['signature'];
    if (signature is! String || !signature.startsWith('ed25519:')) {
      issues.add(
        BankIssue(
          file: file.path,
          message: 'signature 必须形如 ed25519:…',
          field: 'signature',
        ),
      );
    }
    return bankVersion is String ? bankVersion : null;
  }
}
