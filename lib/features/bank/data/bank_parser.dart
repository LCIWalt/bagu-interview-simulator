import 'package:mockmate/core/contracts/contracts.dart';
import 'package:yaml/yaml.dart';

import 'bank_issue.dart';

/// 单个题库 YAML 的解析结果。
class ParsedQuestion {
  const ParsedQuestion({
    required this.file,
    this.question,
    required this.issues,
  });

  final String file;
  final Question? question;
  final List<BankIssue> issues;

  bool get ok => question != null && issues.isEmpty;
}

/// 题目 YAML → [Question]。文件名必须与 `id` 一致。
class BankQuestionParser {
  const BankQuestionParser({
    this.bankVersion = 'seed',
    this.enforceFileId = true,
  });

  final String bankVersion;

  /// 导入粘贴内容没有可信文件名，可关闭 id==文件名 校验。
  final bool enforceFileId;

  static const Set<String> supportedTypes = <String>{
    'knowledge',
    'behavioral',
    'system-design',
    'coding',
    'project',
  };

  static const Set<String> supportedStatuses = <String>{
    'verified',
    'community',
    'ai-draft',
    'user',
    'orphaned',
  };

  static const Map<String, int> levelMap = <String, int>{
    'junior': 1,
    'mid': 3,
    'senior': 4,
    'staff': 5,
  };

  ParsedQuestion parse(String content, String file) {
    final (:map, :issues) = parseYamlDocument(content, file);
    if (map == null) return ParsedQuestion(file: file, issues: issues);

    final id = readString(map, 'id', file, 'id', issues);
    final title = readString(map, 'title', file, 'title', issues);
    final body =
        readString(map, 'body', file, 'body', issues, required: false) ?? title;
    final topics = readStringList(
      map,
      'topics',
      file,
      'topics',
      issues,
      required: true,
      minLength: 1,
    );
    final role = readString(map, 'role', file, 'role', issues);
    final difficulty = readInt(
      map,
      'difficulty',
      file,
      'difficulty',
      issues,
      min: 1,
      max: 5,
    );
    final level = _readLevel(map, file, issues);
    final type = _readEnum(
      map,
      'type',
      file,
      issues,
      supportedTypes,
      fallback: QuestionType.knowledge,
    );
    final status = _readStatus(map, file, issues);
    final updatedAt = _readDate(map, 'updatedAt', file, issues, required: true);
    final followups =
        readStringList(map, 'followups', file, 'followups', issues) ??
        const <String>[];
    final source = readSource(map, file, issues);
    final answer = _readAnswer(map, file, issues);

    if (id != null) {
      final stem = _fileStem(file);
      if (enforceFileId && stem != id) {
        issues.add(
          issueAt(file, 'id', 'id 必须与文件名一致（文件名 $stem.yaml）', map.nodes['id']),
        );
      }
      if (!RegExp(r'^[a-z0-9][a-z0-9-]{2,63}$').hasMatch(id)) {
        issues.add(
          issueAt(file, 'id', 'id 仅允许小写字母/数字/连字符，长度 3–64', map.nodes['id']),
        );
      }
    }

    if (issues.isNotEmpty ||
        id == null ||
        title == null ||
        topics == null ||
        role == null) {
      return ParsedQuestion(file: file, issues: issues);
    }

    final question = Question(
      id: id,
      bankVersion: bankVersion,
      title: title,
      bodyMarkdown: body ?? title,
      topics: topics,
      role: role,
      level: level ?? 3,
      difficulty: difficulty ?? 3,
      type: type ?? QuestionType.knowledge,
      answer:
          answer ?? const QuestionAnswer(summary: '', keyPoints: <String>[]),
      followups: followups,
      source: source == null
          ? null
          : QuestionSource(
              url: source['url']! as String,
              title: source['title']! as String,
              license: source['license']! as String,
              retrievedAt: source['retrievedAt'] as DateTime?,
            ),
      status: status ?? QuestionStatus.community,
      updatedAt: updatedAt,
    );
    return ParsedQuestion(file: file, question: question, issues: issues);
  }

  QuestionAnswer? _readAnswer(
    YamlMap map,
    String file,
    List<BankIssue> issues,
  ) {
    final node = map.nodes['answer'];
    if (node == null) {
      issues.add(issueAt(file, 'answer', '缺少答案与评分点', map));
      return null;
    }
    if (node.value is! YamlMap) {
      issues.add(issueAt(file, 'answer', '必须是对象', node));
      return null;
    }
    final answerMap = node.value as YamlMap;
    final summary = readString(
      answerMap,
      'summary',
      file,
      'answer.summary',
      issues,
    );
    final keyPoints = readStringList(
      answerMap,
      'keyPoints',
      file,
      'answer.keyPoints',
      issues,
      required: true,
      minLength: 1,
    );
    final pitfalls =
        readStringList(
          answerMap,
          'pitfalls',
          file,
          'answer.pitfalls',
          issues,
        ) ??
        const <String>[];
    if (summary == null || keyPoints == null) return null;
    return QuestionAnswer(
      summary: summary,
      keyPoints: keyPoints,
      pitfalls: pitfalls,
    );
  }

  int? _readLevel(YamlMap map, String file, List<BankIssue> issues) {
    final node = map.nodes['level'];
    if (node == null) {
      issues.add(issueAt(file, 'level', '缺少必填字段', map));
      return null;
    }
    final value = node.value;
    if (value is int) {
      if (value < 1 || value > 5) {
        issues.add(issueAt(file, 'level', '必须在 1–5 之间', node));
        return null;
      }
      return value;
    }
    if (value is String && levelMap.containsKey(value)) return levelMap[value];
    issues.add(
      issueAt(file, 'level', '必须是 1–5 或 junior/mid/senior/staff', node),
    );
    return null;
  }

  QuestionType? _readEnum(
    YamlMap map,
    String key,
    String file,
    List<BankIssue> issues,
    Set<String> allowed, {
    required QuestionType fallback,
  }) {
    final value = readString(map, key, file, key, issues);
    if (value == null) return null;
    if (!allowed.contains(value)) {
      issues.add(
        issueAt(file, key, '必须是 ${allowed.join(' / ')} 之一', map.nodes[key]),
      );
      return null;
    }
    return switch (value) {
      'behavioral' => QuestionType.behavioral,
      'system-design' => QuestionType.systemDesign,
      'coding' => QuestionType.coding,
      'project' => QuestionType.project,
      _ => fallback,
    };
  }

  QuestionStatus? _readStatus(
    YamlMap map,
    String file,
    List<BankIssue> issues,
  ) {
    final value = readString(map, 'status', file, 'status', issues);
    if (value == null) return null;
    if (!supportedStatuses.contains(value)) {
      issues.add(
        issueAt(
          file,
          'status',
          '必须是 ${supportedStatuses.join(' / ')} 之一',
          map.nodes['status'],
        ),
      );
      return null;
    }
    return switch (value) {
      'verified' => QuestionStatus.verified,
      'ai-draft' => QuestionStatus.aiDraft,
      'user' => QuestionStatus.user,
      'orphaned' => QuestionStatus.orphaned,
      _ => QuestionStatus.community,
    };
  }

  DateTime? _readDate(
    YamlMap map,
    String key,
    String file,
    List<BankIssue> issues, {
    required bool required,
  }) {
    final value = readString(map, key, file, key, issues, required: required);
    if (value == null) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      issues.add(issueAt(file, key, '必须是 ISO 日期（YYYY-MM-DD）', map.nodes[key]));
      return null;
    }
    return parsed;
  }

  static String _fileStem(String file) {
    final name = file.split(RegExp(r'[/\\]')).last;
    return name.endsWith('.yaml')
        ? name.substring(0, name.length - 5)
        : name.endsWith('.yml')
        ? name.substring(0, name.length - 4)
        : name;
  }
}
