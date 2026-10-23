import 'dart:convert';

import 'package:mockmate/core/contracts/contracts.dart';

import '../bank_issue.dart';
import '../bank_parser.dart';
import '../bank_repository_impl.dart';
import '../dedup/similar_question_detector.dart';
import '../import/bank_import_service.dart' show ImportConflictPolicy;
import '../question_local_repository.dart';
import 'bulk_question_codec.dart';

enum BulkFormat { yaml, json, csv, markdown }

class BulkImportItem {
  const BulkImportItem({
    required this.index,
    required this.line,
    this.question,
    this.issues = const <String>[],
    this.existingTitle,
    this.similarTitle,
    this.similarity = 0,
  });

  final int index;
  final int line;
  final Question? question;
  final List<String> issues;
  final String? existingTitle;
  final String? similarTitle;
  final double similarity;

  bool get valid => question != null && issues.isEmpty;
  bool get hasConflict => existingTitle != null || similarTitle != null;
}

class BulkImportPreview {
  const BulkImportPreview({required this.format, required this.items});

  final BulkFormat format;
  final List<BulkImportItem> items;

  int get validCount => items.where((BulkImportItem item) => item.valid).length;
  int get invalidCount => items.length - validCount;
  int get conflictCount => items
      .where((BulkImportItem item) => item.valid && item.hasConflict)
      .length;
  bool get canImport => items.isNotEmpty && invalidCount == 0;
}

class BulkImportOutcome {
  const BulkImportOutcome({
    this.created = 0,
    this.overwritten = 0,
    this.merged = 0,
    this.skipped = 0,
    this.failed = 0,
  });

  final int created;
  final int overwritten;
  final int merged;
  final int skipped;
  final int failed;

  int get total => created + overwritten + merged + skipped + failed;
}

/// 批量导入（T-021）：YAML / JSON / CSV / Markdown → 预览 → 冲突策略 → 事务写入。
class BulkImportService {
  BulkImportService(
    this._repository,
    this._local, {
    this.detector = const SimilarQuestionDetector(),
  });

  final BankRepositoryImpl _repository;
  final QuestionLocalRepository _local;
  final SimilarQuestionDetector detector;

  static const String importBankVersion = 'user-import';

  BulkFormat detectFormat(String content) {
    final trimmed = content.trimLeft();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      return BulkFormat.json;
    }
    if (trimmed.startsWith('## ') || trimmed.contains('\n## ')) {
      return BulkFormat.markdown;
    }
    final firstLine = trimmed.split('\n').first;
    if (firstLine.contains(',') &&
        RegExp(
          r'\b(title|题干|name)\b',
          caseSensitive: false,
        ).hasMatch(firstLine)) {
      return BulkFormat.csv;
    }
    return BulkFormat.yaml;
  }

  Future<BulkImportPreview> preview(
    String content, {
    BulkFormat? format,
  }) async {
    final resolved = format ?? detectFormat(content);
    final rawItems = switch (resolved) {
      BulkFormat.yaml => _parseYaml(content),
      BulkFormat.json => _parseJson(content),
      BulkFormat.csv => _parseCsv(content),
      BulkFormat.markdown => _parseMarkdown(content),
    };
    final existing = await _repository.search(const QuestionQuery(limit: 5000));
    final items = <BulkImportItem>[];
    for (var i = 0; i < rawItems.length; i++) {
      final raw = rawItems[i];
      final question = raw.question;
      if (question == null) {
        items.add(
          BulkImportItem(
            index: i,
            line: raw.line,
            issues: raw.issues
                .map((BankIssue issue) => issue.format())
                .toList(growable: false),
          ),
        );
        continue;
      }
      final existingQuestion = existing
          .where((Question q) => q.id == question.id)
          .firstOrNull;
      SimilarMatch? match;
      if (existingQuestion == null) {
        final matches = detector.findSimilar(question, existing);
        if (matches.isNotEmpty) match = matches.first;
      }
      items.add(
        BulkImportItem(
          index: i,
          line: raw.line,
          question: question,
          issues: raw.issues
              .map((BankIssue issue) => issue.format())
              .toList(growable: false),
          existingTitle: existingQuestion?.title,
          similarTitle: match?.question.title,
          similarity: match?.similarity ?? 0,
        ),
      );
    }
    return BulkImportPreview(format: resolved, items: items);
  }

  Future<BulkImportOutcome> commit(
    BulkImportPreview preview, {
    required ImportConflictPolicy policy,
    String origin = 'user',
  }) async {
    if (!preview.canImport) {
      return BulkImportOutcome(failed: preview.items.length);
    }
    final toWrite = <Question>[];
    var skipped = 0;
    var merged = 0;
    for (final item in preview.items) {
      final question = item.question!;
      if (item.hasConflict) {
        if (policy == ImportConflictPolicy.skip) {
          skipped++;
          continue;
        }
        if (policy == ImportConflictPolicy.merge) {
          final summary = question.answer.summary.trim();
          if (summary.isNotEmpty) {
            await _local.appendNote(question.id, '[批量导入] $summary');
          }
          await _local.markOrigin(question.id, origin);
          merged++;
          continue;
        }
      }
      toWrite.add(question);
    }
    if (toWrite.isNotEmpty) {
      await _repository.importBatch(toWrite, origin: origin);
    }
    return BulkImportOutcome(
      created: toWrite.length,
      merged: merged,
      skipped: skipped,
    );
  }

  // ---- 各格式解析 ----

  List<_RawItem> _parseYaml(String content) {
    final docs = content
        .replaceAll('\r\n', '\n')
        .split(RegExp(r'^---\s*$', multiLine: true))
        .map((String doc) => doc.trim())
        .where((String doc) => doc.isNotEmpty)
        .toList();
    var line = 1;
    final result = <_RawItem>[];
    for (var i = 0; i < docs.length; i++) {
      final parsed = BankQuestionParser(
        bankVersion: importBankVersion,
        enforceFileId: false,
      ).parse(docs[i], 'bulk-$i.yaml');
      result.add(
        _RawItem(line: line, question: parsed.question, issues: parsed.issues),
      );
      line += docs[i].split('\n').length + 1;
    }
    return result;
  }

  List<_RawItem> _parseJson(String content) {
    final decoded = jsonDecode(content);
    final list = decoded is Map<String, dynamic>
        ? decoded['questions']
        : decoded;
    if (list is! List) {
      return <_RawItem>[
        _RawItem(
          line: 1,
          issues: <BankIssue>[
            const BankIssue(
              file: 'json',
              message: 'JSON 必须是数组或 {questions: []}',
            ),
          ],
        ),
      ];
    }
    final result = <_RawItem>[];
    for (var i = 0; i < list.length; i++) {
      final raw = list[i];
      if (raw is! Map<String, dynamic>) {
        result.add(
          _RawItem(
            line: i + 1,
            issues: <BankIssue>[BankIssue(file: 'json', message: '第 $i 项不是对象')],
          ),
        );
        continue;
      }
      final map = _normalizeMap(raw, index: i);
      result.add(_parseMap(map, 'json[${i + 1}]'));
    }
    return result;
  }

  List<_RawItem> _parseCsv(String content) {
    final rows = parseCsv(content);
    if (rows.isEmpty) return const <_RawItem>[];
    final headers = rows.first.map(_normalizeHeader).toList();
    final result = <_RawItem>[];
    for (var r = 1; r < rows.length; r++) {
      final row = rows[r];
      if (row.every((String cell) => cell.trim().isEmpty)) continue;
      final raw = <String, Object?>{};
      for (var c = 0; c < headers.length && c < row.length; c++) {
        raw[headers[c]] = row[c].trim();
      }
      final map = _normalizeMap(raw, index: r - 1);
      result.add(_parseMap(map, 'csv:${r + 1}', line: r + 1));
    }
    return result;
  }

  List<_RawItem> _parseMarkdown(String content) {
    final maps = parseMarkdownQuestions(content);
    return <_RawItem>[
      for (var i = 0; i < maps.length; i++)
        _parseMap(
          _normalizeMap(maps[i], index: i),
          'markdown[${i + 1}]',
          line: i + 1,
        ),
    ];
  }

  _RawItem _parseMap(Map<String, Object?> map, String label, {int line = 1}) {
    final yaml = questionMapToYaml(map);
    final parsed = BankQuestionParser(
      bankVersion: importBankVersion,
      enforceFileId: false,
    ).parse(yaml, '$label.yaml');
    return _RawItem(
      line: line,
      question: parsed.question,
      issues: parsed.issues,
    );
  }

  Map<String, Object?> _normalizeMap(
    Map<String, dynamic> raw, {
    required int index,
  }) {
    final normalized = <String, Object?>{};
    for (final entry in raw.entries) {
      normalized[_normalizeHeader(entry.key)] = entry.value;
    }
    String? read(List<String> keys) {
      for (final key in keys) {
        final value = normalized[key];
        if (value != null && '$value'.trim().isNotEmpty) return '$value'.trim();
      }
      return null;
    }

    List<String> listRead(List<String> keys) {
      Object? rawValue;
      for (final key in keys) {
        if (normalized[key] != null) {
          rawValue = normalized[key];
          break;
        }
      }
      if (rawValue is List) {
        return rawValue
            .map((Object? item) => '$item'.trim())
            .where((String item) => item.isNotEmpty)
            .toList(growable: false);
      }
      final value = read(keys);
      if (value == null) return const <String>[];
      if (value.startsWith('[') && value.endsWith(']')) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) {
            return decoded
                .map((Object? item) => '$item'.trim())
                .where((String item) => item.isNotEmpty)
                .toList(growable: false);
          }
        } on FormatException {
          // fall through to delimiter split
        }
      }
      return value
          .split(RegExp(r'[|;,\n]'))
          .map((String item) => item.trim())
          .where((String item) => item.isNotEmpty)
          .toList(growable: false);
    }

    final id =
        read(<String>['id']) ??
        'imp-${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}-$index';
    final topics = listRead(<String>['topics', 'topic']);
    final keyPoints = listRead(<String>['keypoints', 'key_points', 'points']);
    final summary = read(<String>['summary', 'answer', 'reference']) ?? '';
    final answerRaw = normalized['answer'];
    var answerSummary = summary;
    var answerPoints = keyPoints;
    if (answerRaw is Map) {
      answerSummary = answerRaw['summary']?.toString() ?? answerSummary;
      final points = answerRaw['keyPoints'];
      if (points is List) {
        answerPoints = points
            .map((Object? p) => '$p'.trim())
            .where((String p) => p.isNotEmpty)
            .toList();
      }
    }
    var sourceUrl = read(<String>['sourceurl', 'source_url', 'url']);
    var sourceTitle =
        read(<String>['sourcetitle', 'source_title']) ?? sourceUrl ?? '';
    var license = read(<String>['license']) ?? 'user';
    final sourceRaw = normalized['source'];
    if (sourceRaw is Map) {
      sourceUrl = sourceRaw['url']?.toString().trim() ?? sourceUrl;
      sourceTitle = sourceRaw['title']?.toString().trim() ?? sourceTitle;
      license = sourceRaw['license']?.toString().trim() ?? license;
    }
    final status = read(<String>['status']) ?? 'user';
    final level = read(<String>['level']) ?? 'mid';
    final difficulty = read(<String>['difficulty']) ?? '3';
    final type = read(<String>['type']) ?? 'knowledge';
    final role = read(<String>['role']) ?? 'backend';

    return <String, Object?>{
      'id': id,
      'title': read(<String>['title', 'name']) ?? '',
      'body': read(<String>['body', 'description']) ?? '',
      'topics': topics,
      'role': role,
      'level': level,
      'difficulty': difficulty,
      'type': type,
      'answer': <String, Object?>{
        'summary': answerSummary,
        'keyPoints': answerPoints,
        'pitfalls': listRead(<String>['pitfalls']),
      },
      'followups': listRead(<String>['followups', 'follow_ups']),
      if (sourceUrl != null)
        'source': <String, Object?>{
          'url': sourceUrl,
          'title': sourceTitle,
          'license': license,
        },
      'status': status,
      'updatedAt': DateTime.now().toUtc().toIso8601String().substring(0, 10),
    };
  }

  String _normalizeHeader(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[\s_\-]'), '');
}

class _RawItem {
  const _RawItem({
    required this.line,
    this.question,
    this.issues = const <BankIssue>[],
  });

  final int line;
  final Question? question;
  final List<BankIssue> issues;
}
