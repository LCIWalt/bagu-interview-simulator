import 'package:drift/drift.dart';
import 'package:mockmate/core/db/app_database.dart';

/// 用户覆盖层：笔记/收藏/隐藏/历史。题库更新永不改写此表。
class QuestionLocalRepository {
  QuestionLocalRepository(this._db);

  final AppDatabase _db;

  Future<QuestionLocalRow?> get(String questionId) {
    return (_db.select(_db.questionLocal)
          ..where((QuestionLocal t) => t.questionId.equals(questionId)))
        .getSingleOrNull();
  }

  Future<void> saveNote(String questionId, String noteMarkdown) async {
    final now = DateTime.now();
    await _db
        .into(_db.questionLocal)
        .insert(
          QuestionLocalCompanion.insert(
            questionId: questionId,
            noteMd: Value(noteMarkdown),
            updatedAt: now,
          ),
          onConflict: DoUpdate(
            (QuestionLocal old) => QuestionLocalCompanion(
              noteMd: Value(noteMarkdown),
              updatedAt: Value(now),
            ),
          ),
        );
  }

  Future<void> setStarred(String questionId, bool starred) async {
    final now = DateTime.now();
    await _db
        .into(_db.questionLocal)
        .insert(
          QuestionLocalCompanion.insert(
            questionId: questionId,
            starred: Value(starred),
            updatedAt: now,
          ),
          onConflict: DoUpdate(
            (QuestionLocal old) => QuestionLocalCompanion(
              starred: Value(starred),
              updatedAt: Value(now),
            ),
          ),
        );
  }

  Future<void> setHidden(String questionId, bool hidden) async {
    final now = DateTime.now();
    await _db
        .into(_db.questionLocal)
        .insert(
          QuestionLocalCompanion.insert(
            questionId: questionId,
            hidden: Value(hidden),
            updatedAt: now,
          ),
          onConflict: DoUpdate(
            (QuestionLocal old) => QuestionLocalCompanion(
              hidden: Value(hidden),
              updatedAt: Value(now),
            ),
          ),
        );
  }

  /// 最近作答记录（题目详情页「历史作答」）。
  Future<List<TurnRow>> historyFor(String questionId, {int limit = 10}) {
    return (_db.select(_db.turns)
          ..where((Turns t) => t.questionId.equals(questionId))
          ..orderBy(<OrderClauseGenerator<$TurnsTable>>[
            ($TurnsTable t) => OrderingTerm.desc(t.tSubmittedAt),
          ])
          ..limit(limit))
        .get();
  }

  /// 收藏列表（按本地更新时间倒序）。
  Future<List<String>> starredIds() async {
    final rows =
        await (_db.select(_db.questionLocal)
              ..where((QuestionLocal t) => t.starred.equals(true))
              ..orderBy(<OrderClauseGenerator<$QuestionLocalTable>>[
                ($QuestionLocalTable t) => OrderingTerm.desc(t.updatedAt),
              ]))
            .get();
    return rows
        .map((QuestionLocalRow row) => row.questionId)
        .toList(growable: false);
  }
}

extension QuestionLocalImport on QuestionLocalRepository {
  /// 用户导入/自建的题目标记为 user 来源，题库更新不会覆盖或下线。
  /// 标记来源（如 `github:owner/repo`），已存在则覆盖。
  Future<void> markOrigin(String questionId, String origin) async {
    final updated =
        await (_db.update(
          _db.questionLocal,
        )..where((QuestionLocal t) => t.questionId.equals(questionId))).write(
          QuestionLocalCompanion(
            origin: Value(origin),
            updatedAt: Value(DateTime.now()),
          ),
        );
    if (updated == 0) {
      await _db
          .into(_db.questionLocal)
          .insert(
            QuestionLocalCompanion.insert(
              questionId: questionId,
              origin: Value(origin),
              updatedAt: DateTime.now(),
            ),
          );
    }
  }

  Future<void> ensureUserOrigin(String questionId) async {
    final now = DateTime.now();
    await _db
        .into(_db.questionLocal)
        .insert(
          QuestionLocalCompanion.insert(
            questionId: questionId,
            origin: const Value('user'),
            updatedAt: now,
          ),
          onConflict: DoUpdate(
            (QuestionLocal old) => QuestionLocalCompanion(
              origin: const Value('user'),
              updatedAt: Value(now),
            ),
          ),
        );
  }

  /// 追加笔记（导入合并用），保留原有内容与收藏状态。
  Future<void> appendNote(String questionId, String addition) async {
    final existing = await get(questionId);
    final text = existing?.noteMd ?? '';
    final merged = text.isEmpty ? addition : '$text\n\n$addition';
    await saveNote(questionId, merged);
  }
}
