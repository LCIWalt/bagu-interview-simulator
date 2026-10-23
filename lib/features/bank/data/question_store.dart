import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';

/// 数据库行 ↔ 领域模型，集中处理 JSON 列的兼容。
abstract final class QuestionStoreTopics {
  static List<String> decode(String? raw) =>
      QuestionStore.decodeStringList(raw);
}

abstract final class QuestionStore {
  static List<String> decodeStringList(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const <String>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <String>[];
      return decoded.map((Object? item) => '$item').toList(growable: false);
    } on FormatException {
      return const <String>[];
    }
  }

  static QuestionType parseType(String raw) => switch (raw) {
    'behavioral' => QuestionType.behavioral,
    'system-design' => QuestionType.systemDesign,
    'coding' => QuestionType.coding,
    'project' => QuestionType.project,
    _ => QuestionType.knowledge,
  };

  static String encodeType(QuestionType type) =>
      type == QuestionType.systemDesign ? 'system-design' : type.name;

  static QuestionStatus parseStatus(String raw) => switch (raw) {
    'verified' => QuestionStatus.verified,
    'ai-draft' => QuestionStatus.aiDraft,
    'user' => QuestionStatus.user,
    'orphaned' => QuestionStatus.orphaned,
    _ => QuestionStatus.community,
  };

  static String encodeStatus(QuestionStatus status) => switch (status) {
    QuestionStatus.verified => 'verified',
    QuestionStatus.aiDraft => 'ai-draft',
    QuestionStatus.user => 'user',
    QuestionStatus.orphaned => 'orphaned',
    QuestionStatus.community => 'community',
  };

  static QuestionAnswer decodeAnswer(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const QuestionAnswer(summary: '', keyPoints: <String>[]);
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const QuestionAnswer(summary: '', keyPoints: <String>[]);
      }
      return QuestionAnswer(
        summary: decoded['summary']?.toString() ?? '',
        keyPoints: decodeStringList(
          jsonEncode(decoded['keyPoints'] ?? const <String>[]),
        ),
        pitfalls: decodeStringList(
          jsonEncode(decoded['pitfalls'] ?? const <String>[]),
        ),
      );
    } on FormatException {
      return const QuestionAnswer(summary: '', keyPoints: <String>[]);
    }
  }

  static String encodeAnswer(QuestionAnswer answer) =>
      jsonEncode(<String, Object?>{
        'summary': answer.summary,
        'keyPoints': answer.keyPoints,
        'pitfalls': answer.pitfalls,
      });

  static Question toDomain(QuestionRow row) {
    return Question(
      id: row.id,
      bankVersion: row.bankVersion,
      title: row.title,
      bodyMarkdown: row.bodyMd,
      topics: decodeStringList(row.topics),
      role: row.role,
      level: row.level,
      difficulty: row.difficulty,
      type: parseType(row.type),
      answer: decodeAnswer(row.answerJson),
      followups: decodeStringList(row.followupsJson),
      source: row.sourceUrl == null
          ? null
          : QuestionSource(
              url: row.sourceUrl!,
              title: row.sourceUrl!,
              license: row.license ?? 'unknown',
            ),
      status: parseStatus(row.status),
      updatedAt: row.updatedAt,
    );
  }

  static QuestionsCompanion toCompanion(Question question) {
    return QuestionsCompanion.insert(
      id: question.id,
      bankVersion: question.bankVersion,
      title: question.title,
      bodyMd: question.bodyMarkdown,
      topics: Value(jsonEncode(question.topics)),
      role: question.role,
      level: Value(question.level),
      difficulty: Value(question.difficulty),
      type: Value(encodeType(question.type)),
      answerJson: Value(encodeAnswer(question.answer)),
      followupsJson: Value(jsonEncode(question.followups)),
      sourceUrl: Value(question.source?.url),
      license: Value(question.source?.license),
      status: Value(encodeStatus(question.status)),
      updatedAt: question.updatedAt ?? DateTime.now().toUtc(),
    );
  }
}
