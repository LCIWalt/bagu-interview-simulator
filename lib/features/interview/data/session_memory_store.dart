import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:mockmate/core/db/app_database.dart' hide SessionMemory;
import 'package:path/path.dart' as p;

import '../domain/memory/memory_extractor.dart';
import '../domain/memory/session_memory.dart';

/// `session_memory` 读写与导出（T-043）。
class SessionMemoryStore {
  SessionMemoryStore(this._db);

  final AppDatabase _db;

  Future<SessionMemory?> load(String sessionId) async {
    final row =
        await (_db.select(_db.sessionMemory)
              ..where(($SessionMemoryTable t) => t.sessionId.equals(sessionId)))
            .getSingleOrNull();
    if (row == null) return null;
    try {
      final decoded = jsonDecode(row.memoryJson);
      if (decoded is! Map<String, dynamic>) return null;
      return SessionMemory.fromJson(decoded);
    } on FormatException {
      return null;
    }
  }

  Future<SessionMemory> merge(
    String sessionId,
    MemoryExtraction extraction, {
    required int turnSeq,
    required String questionId,
  }) async {
    final session = await (_db.select(
      _db.sessions,
    )..where((Sessions t) => t.id.equals(sessionId))).getSingleOrNull();
    if (session == null) throw StateError('session not found');
    var config = const <String, Object?>{};
    try {
      final decoded = jsonDecode(session.configJson);
      if (decoded is Map<String, dynamic>) config = decoded;
    } on FormatException {
      // 使用默认值。
    }
    final base =
        await load(sessionId) ??
        SessionMemory(
          sessionId: sessionId,
          role: config['role']?.toString() ?? '',
          level: config['level']?.toString() ?? '',
          mode: session.mode,
        );

    final projects = <MemoryProject>[...base.projects];
    for (final incoming in extraction.projects) {
      final index = projects.indexWhere(
        (MemoryProject p) => p.name == incoming.name,
      );
      if (index < 0) {
        projects.add(incoming);
      } else {
        final existing = projects[index];
        projects[index] = MemoryProject(
          name: existing.name,
          stack: <String>{
            ...existing.stack,
            ...incoming.stack,
          }.toList(growable: false),
          claims: <String>{
            ...existing.claims,
            ...incoming.claims,
          }.toList(growable: false),
        );
      }
    }
    final claims = <MemoryClaim>[...base.claims];
    for (final incoming in extraction.claims) {
      if (claims.any((MemoryClaim c) => c.text == incoming.text)) continue;
      claims.add(MemoryClaim(text: incoming.text, turnSeq: turnSeq));
    }

    final memory = base.copyWith(
      projects: projects,
      claims: claims,
      numbers: <String>{
        ...base.numbers,
        ...extraction.numbers,
      }.toList(growable: false),
      contradictions: <String>{
        ...base.contradictions,
        ...extraction.contradictions,
      }.toList(growable: false),
      unanswered: <String>{
        ...base.unanswered,
        ...extraction.unanswered,
      }.toList(growable: false),
      weakTopics: <String>{
        ...base.weakTopics,
        ...extraction.weakTopics,
      }.toList(growable: false),
      askedQuestionIds: <String>{
        ...base.askedQuestionIds,
        questionId,
      }.toList(growable: false),
    );
    await save(memory);
    return memory;
  }

  Future<void> save(SessionMemory memory) async {
    await _db
        .into(_db.sessionMemory)
        .insertOnConflictUpdate(
          SessionMemoryCompanion.insert(
            sessionId: memory.sessionId,
            memoryJson: memory.encode(),
            updatedAt: DateTime.now(),
          ),
        );
  }

  /// 导出 `sessions/<id>/memory.json`，返回文件路径。
  Future<String> export(String sessionId, Directory root) async {
    final memory = await load(sessionId);
    if (memory == null) throw StateError('memory not found');
    final file = File(p.join(root.path, 'sessions', sessionId, 'memory.json'));
    await file.parent.create(recursive: true);
    await file.writeAsString(memory.encode());
    return file.path;
  }

  /// 最近一场（不含当前）的记忆摘要，供下次面试加载。
  Future<String?> latestSummary({String? excludeSessionId}) async {
    final rows =
        await (_db.select(_db.sessionMemory)
              ..orderBy(<OrderClauseGenerator<$SessionMemoryTable>>[
                ($SessionMemoryTable t) => OrderingTerm.desc(t.updatedAt),
              ])
              ..limit(5))
            .get();
    for (final row in rows) {
      if (row.sessionId == excludeSessionId) continue;
      try {
        final decoded = jsonDecode(row.memoryJson);
        if (decoded is! Map<String, dynamic>) continue;
        final memory = SessionMemory.fromJson(decoded);
        final claims = memory.claims
            .map((MemoryClaim c) => c.text)
            .take(5)
            .join('；');
        final weak = memory.weakTopics.take(3).join('、');
        if (claims.isEmpty && weak.isEmpty) continue;
        return 'claims: $claims\nweakTopics: $weak';
      } on FormatException {
        continue;
      }
    }
    return null;
  }
}
