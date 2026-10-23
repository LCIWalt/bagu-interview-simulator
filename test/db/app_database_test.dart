import 'package:drift/drift.dart' show QueryRow, Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/db/app_database.dart';

Future<void> _insert(
  AppDatabase db, {
  required String id,
  required String title,
  required String body,
  String topics = '["go"]',
}) {
  return db
      .into(db.questions)
      .insert(
        QuestionsCompanion.insert(
          id: id,
          bankVersion: '2026.10.1',
          title: title,
          bodyMd: body,
          topics: Value(topics),
          role: 'backend',
          level: const Value(3),
          difficulty: const Value(3),
          updatedAt: DateTime.utc(2026),
        ),
      );
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.memory());
  tearDown(() => db.close());

  test('schema creates all §6.1 tables plus FTS', () async {
    final rows = await db
        .customSelect(
          "SELECT name, type FROM sqlite_master WHERE type IN ('table','trigger')",
        )
        .get();
    final names = rows
        .map((QueryRow row) => row.data['name'] as String)
        .toSet();
    const expected = <String>{
      'settings',
      'providers',
      'questions',
      'question_local',
      'experiences',
      'sessions',
      'turns',
      'messages',
      'session_memory',
      'session_scores',
      'search_cache',
      'fact_checks',
      'doc_sources',
      'question_embeddings',
      'question_edges',
      'cluster_members',
      'bank_sources',
      'llm_calls',
      'bank_meta',
      'fts_questions',
      'questions_ai',
      'questions_ad',
      'questions_au',
    };
    expect(names, containsAll(expected));
  });

  test('FTS5 trigram indexes Chinese substring', () async {
    await _insert(db, id: 'q1', title: '数据库索引为什么用 B+ 树', body: '数据库索引优化与页分裂');
    await _insert(db, id: 'q2', title: 'TCP 三次握手', body: 'SYN 与 ACK');

    final hits = await db.searchFts('数据库索引');
    expect(hits.map((QuestionRow r) => r.id), <String>['q1']);
  });

  test('triggers keep FTS in sync on insert, update and delete', () async {
    await _insert(db, id: 'q1', title: '闭包与作用域', body: 'JavaScript 闭包');
    expect((await db.searchFts('作用域')).map((QuestionRow r) => r.id), <String>[
      'q1',
    ]);

    await (db.update(db.questions)..where((Questions t) => t.id.equals('q1')))
        .write(const QuestionsCompanion(bodyMd: Value('改为 goroutine 调度')));
    expect(await db.searchFts('JavaScript'), isEmpty);
    expect((await db.searchFts('作用域')).map((QuestionRow r) => r.id), <String>[
      'q1',
    ]);
    expect(
      (await db.searchFts('goroutine')).map((QuestionRow r) => r.id),
      <String>['q1'],
    );

    await (db.delete(
      db.questions,
    )..where((Questions t) => t.id.equals('q1'))).go();
    expect(await db.searchFts('goroutine'), isEmpty);
  });

  test('empty query returns no rows without touching FTS syntax', () async {
    await _insert(db, id: 'q1', title: '任意题目', body: '内容');
    expect(await db.searchFts('   '), isEmpty);
  });

  test('foreign keys cascade turns when a session is deleted', () async {
    await db
        .into(db.sessions)
        .insert(
          SessionsCompanion.insert(
            id: 's1',
            mode: 'drill',
            configJson: '{}',
            startedAt: DateTime.utc(2026),
          ),
        );
    await db
        .into(db.turns)
        .insert(
          TurnsCompanion.insert(
            id: 't1',
            sessionId: 's1',
            seq: 1,
            tStartedAt: DateTime.utc(2026),
            tSubmittedAt: DateTime.utc(2026),
            createdAt: DateTime.utc(2026),
          ),
        );
    await (db.delete(
      db.sessions,
    )..where((Sessions t) => t.id.equals('s1'))).go();
    expect(await db.select(db.turns).get(), isEmpty);
  });
}
