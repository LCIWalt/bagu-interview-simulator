import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/features/bank/data/bank_issue.dart';
import 'package:mockmate/features/bank/data/bank_parser.dart';
import 'package:mockmate/features/bank/data/bank_validator.dart';

const String validQuestion = '''
id: be-go-001
title: Go 的 GMP 模型里，为什么需要 P？
topics: [go, runtime]
role: backend
level: mid
difficulty: 3
type: knowledge
answer:
  summary: P 提供执行上下文与本地队列。
  keyPoints:
    - M 与 P 解耦
    - 本地运行队列与 work stealing
  pitfalls: [只背结论]
followups:
  - GOMAXPROCS 设大很多会怎样？
source:
  url: https://go.dev/doc/effective_go
  title: Effective Go
  license: BSD-3-Clause
  retrievedAt: 2026-10-01
status: verified
updatedAt: 2026-10-01
''';

Map<String, Object?> validManifest({
  List<String> paths = const <String>['questions/backend/be-go-001.yaml'],
}) {
  return <String, Object?>{
    'schemaVersion': 1,
    'bankVersion': '2026.10.1',
    'minAppVersion': '0.5.0',
    'generatedAt': '2026-10-22T02:00:00Z',
    'gitCommit': 'abc1234',
    'counts': <String, Object?>{'questions': paths.length, 'experiences': 0},
    'files': paths
        .map(
          (String path) => <String, Object?>{
            'path': path,
            'sha256': 'a' * 64,
            'bytes': 100,
          },
        )
        .toList(),
    'assets': <Object?>[],
    'signature': 'ed25519:placeholder',
  };
}

Directory _tempBank(Map<String, String> files) {
  final root = Directory.systemTemp.createTempSync('bank_validate_');
  for (final entry in files.entries) {
    final file = File('${root.path}/${entry.key}');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(entry.value);
  }
  addTearDown(() => root.deleteSync(recursive: true));
  return root;
}

void main() {
  group('BankQuestionParser', () {
    test('parses a valid question into the contract model', () {
      final result = BankQuestionParser(bankVersion: '2026.10.1')
          .parse(validQuestion, 'questions/backend/be-go-001.yaml');
      expect(result.issues, isEmpty, reason: result.issues.join('\n'));
      final question = result.question!;
      expect(question.id, 'be-go-001');
      expect(question.topics, <String>['go', 'runtime']);
      expect(question.level, 3);
      expect(question.answer.keyPoints, hasLength(2));
      expect(question.source!.license, 'BSD-3-Clause');
      expect(question.status.name, 'verified');
      expect(question.bankVersion, '2026.10.1');
    });

    test('reports missing fields with line numbers', () {
      const invalid = '''
id: bad-001
title: 缺少评分点
topics: [go]
role: backend
level: 9
difficulty: 3
type: knowledge
answer:
  summary: s
  keyPoints: []
status: verified
updatedAt: 2026-10-01
''';
      final result = BankQuestionParser().parse(
        invalid,
        'questions/go/bad-001.yaml',
      );
      expect(result.question, isNull);
      expect(
        result.issues.map((BankIssue e) => e.field),
        containsAll(<String>['level', 'answer.keyPoints', 'source']),
      );
      expect(result.issues.any((BankIssue e) => e.line > 0), isTrue);
      expect(result.issues.first.format(), contains('bad-001.yaml:'));
    });

    test('rejects id/filename mismatch and bad enums', () {
      final result = BankQuestionParser().parse(
        validQuestion
            .replaceAll('be-go-001', 'be-go-002')
            .replaceAll('type: knowledge', 'type: essay'),
        'questions/backend/be-go-001.yaml',
      );
      expect(
        result.issues.map((BankIssue e) => e.field),
        containsAll(<String>['id', 'type']),
      );
    });

    test('rejects duplicate keyPoints and non-http source', () {
      final result = BankQuestionParser().parse(
        validQuestion
            .replaceAll('    - 本地运行队列与 work stealing', '    - M 与 P 解耦')
            .replaceAll('https://go.dev/doc/effective_go', 'ftp://go.dev/x'),
        'questions/backend/be-go-001.yaml',
      );
      expect(
        result.issues.map((BankIssue e) => e.field),
        containsAll(<String>['answer.keyPoints', 'source.url']),
      );
    });
  });

  group('BankValidator', () {
    test('accepts a valid directory and counts questions', () {
      final root = _tempBank(<String, String>{
        'manifest.json': jsonEncode(validManifest()),
        'questions/backend/be-go-001.yaml': validQuestion,
      });
      final report = const BankValidator().validateDirectory(root);
      expect(report.ok, isTrue, reason: report.sortedIssues.join('\n'));
      expect(report.questionCount, 1);
      expect(report.bankVersion, '2026.10.1');
    });

    test('collects every issue instead of failing fast', () {
      final root = _tempBank(<String, String>{
        'manifest.json': jsonEncode(validManifest()),
        'questions/backend/be-go-001.yaml': validQuestion,
        'questions/frontend/be-go-001.yaml': validQuestion,
        'questions/backend/be-go-003.yaml': 'id: broken\n',
      });
      final report = const BankValidator().validateDirectory(root);
      expect(report.ok, isFalse);
      expect(report.sortedIssues.length, greaterThan(3));
      expect(
        report.sortedIssues.map((BankIssue e) => e.message).join(),
        contains('重复 id'),
      );
      expect(
        report.sortedIssues.map((BankIssue e) => e.field),
        contains('answer'),
      );
    });

    test('flags missing manifest and empty questions directory', () {
      final root = _tempBank(<String, String>{});
      final report = const BankValidator().validateDirectory(root);
      expect(report.ok, isFalse);
      expect(
        report.sortedIssues.map((BankIssue e) => e.message).join(),
        contains('manifest.json'),
      );
      expect(
        report.sortedIssues.map((BankIssue e) => e.message).join(),
        contains('题目 YAML'),
      );
    });

    test('flags malformed manifest and bad hashes', () {
      final manifest = validManifest()
        ..['files'] = <Object?>[
          <String, Object?>{'path': 'a.yaml', 'sha256': 'nope', 'bytes': 0},
        ];
      final root = _tempBank(<String, String>{
        'manifest.json': jsonEncode(manifest),
        'questions/backend/be-go-001.yaml': validQuestion,
      });
      final report = const BankValidator().validateDirectory(root);
      final text = report.sortedIssues
          .map((BankIssue e) => e.message)
          .join('\n');
      expect(text, contains('sha256'));
      expect(text, contains('bytes'));
    });
  });
}
